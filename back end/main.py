from flask import Flask, jsonify, request, abort
import pyrebase
import requests
import logging
import json
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
import random
from google.cloud import speech_v1
from pydub import AudioSegment
import speech_recognition as sr
import dialogflow_v2 as dialogflow
from google.protobuf.json_format import MessageToDict
import datetime

#create flask app
app = Flask(__name__)


#initalise firebase app using config, pyrebase library will be used
firebase = pyrebase.initialize_app(config)

#client for googles speech to text api
client = speech_v1.SpeechClient()

#recognizer for speech recognition
r = sr.Recognizer()

#dialogflow session client
session_client = dialogflow.SessionsClient()

#register user route
@app.route('/register', methods=['POST'])
def register_user():
	#retreive firebase authentication
	auth = firebase.auth()

	try:
		#use posted email and password to create user account
		user = auth.create_user_with_email_and_password(request.json['email'], request.json['password'])

		db = firebase.database()

		data = {
		    "firstName": request.json['firstName'],
		    "secondName": request.json['secondName']
		}

		#upload their first name and second name to the database
		results = db.child("users").child(user['localId']).child("userDetails").set(data, user['idToken'])
		#return success message
		return jsonify(message="User Created Successfully")
	#catch exception and handle error
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#sign in user route
@app.route('/signin', methods=['POST'])
def sign_in_user():
	auth = firebase.auth()

	try:
		#sign user in with posted email and password
		user = auth.sign_in_with_email_and_password(request.json['email'], request.json['password'])

		db = firebase.database()

		#retrieve user details from database
		results = db.child("users").child(user['localId']).child("userDetails").get(user['idToken'])
		#return user data, id, token and refresh token
		return jsonify(message=results.val(), id=user['localId'], token=user['idToken'], refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route for uploading a photo
@app.route('/photo', methods=['POST'])
def upload_photo():
	auth = firebase.auth()

	try:
		#create an instance of firebase storage
		storage = firebase.storage()
		db = firebase.database()

		user = auth.refresh(request.form['refreshToken'])

		#stiore posted image under posted filename
		results = storage.child("users").child(user['userId']).child(request.files['file'].filename).put(request.files['file'], user['idToken'])
		#get url from posted image
		url = storage.child(results['name']).get_url(results['downloadTokens'])

		data = {
		    "url": str(url)
		}

		#split file name from the posted file
		fullFilename = results['name'].split('/')
		name = fullFilename[len(fullFilename) - 1].split('.')[1]

		#add the url to the database under the images node for the user, give random int as the node for now, will be changed later
		addUrl = db.child("users").child(user['userId']).child("images").child(str(random.randint(1,101))).set(data, user['idToken'])

		#return the refresh token and the image url
		return jsonify(refreshToken=user['refreshToken'], url=url)
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route to get all user photos
@app.route('/photos', methods=['GET'])
def get_photos():
	auth = firebase.auth()

	try:
		storage = firebase.storage()
		db = firebase.database()

		user = auth.refresh(request.args['refreshToken'])

		#get all image urls from database for the specific user
		results = db.child("users").child(user['userId']).child("images").get(user['idToken'])

		#return the images as a list
		return jsonify(images=results.val(), refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#route to deal with voice command, currently only works with timetable
@app.route('/command', methods=['POST'])
def get_command_keywords():
	try:
		#use audio segment to get the raw audio from the posted file (which is in a .mp4 format)
		raw_audio = AudioSegment.from_file(request.files['file'])

		#use ffmpeg to convert the file to wav, which is a filetype accepted by google speech to text
		wav_path = "./sample.wav"
		raw_audio.export(wav_path, format="wav")

		#use the audio recorder to convert the new wav file as raw audio
		with sr.AudioFile(wav_path) as source:
			audio = r.record(source)



		day = ""
		funct = ""

		try:
			#use google speech to text api to retrieve the text from the audio
		    text = r.recognize_google_cloud(audio, credentials_json=GOOGLE_CLOUD_SPEECH_CREDENTIALS)

		    #set up dialogflow session, and create a dialogflow query with the text input
		    session = session_client.session_path("mystudentlife-220716", "1")
		    text_input = dialogflow.types.TextInput(text=text, language_code="en-US")
		    query_input = dialogflow.types.QueryInput(text=text_input)

		    #detect the intent via dialogflow by passing in the query from the current session, and retreive the response
		    response = session_client.detect_intent(session=session, query_input=query_input)
		    #convert the reponse to a dictionary
		    responseObject = MessageToDict(response)

		    #get the payload from the response, which returns the intent
		    payload = responseObject['queryResult']['fulfillmentMessages'][1]['payload']

		    #get function from payload, e.g "timetables"
		    funct = payload['function']

		    #get date from payload, and convert it to a datetime object
		    dayInfo = payload['date'].split('-')
		    date = datetime.date(int(dayInfo[0]), int(dayInfo[1]), int(dayInfo[2]))

		    #get the day of the week from the datetime object
		    day = date.strftime("%A")
		except sr.UnknownValueError:
		    print("Google Cloud Speech could not understand audio")
		except sr.RequestError as e:
		    print("Could not request results from Google Cloud Speech service; {0}".format(e))

		    #return the function and day
		return jsonify(function=funct, day=day)
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)


#route to change font
@app.route('/font', methods=['POST'])
def put_font():
	auth = firebase.auth()

	try:
		user = auth.refresh(request.form['refreshToken'])

		db = firebase.database()

		#set posted font under the design node
		result = db.child("users").child(user['userId']).child("design").child("font").set(request.form['font'], user['idToken'])
		#return refresh token if successfull
		return jsonify(refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

#run app
if __name__ == '__main__':
	app.run(debug=True)
