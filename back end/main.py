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

app = Flask(__name__)



firebase = pyrebase.initialize_app(config)
client = speech_v1.SpeechClient()
r = sr.Recognizer()
session_client = dialogflow.SessionsClient()

@app.route('/register', methods=['POST'])
def register_user():
	auth = firebase.auth()

	try:
		user = auth.create_user_with_email_and_password(request.json['email'], request.json['password'])

		db = firebase.database()

		data = {
		    "firstName": request.json['firstName'],
		    "secondName": request.json['secondName']
		}

		results = db.child("users").child(user['localId']).child("userDetails").set(data, user['idToken'])
		return jsonify(message="User Created Successfully")
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

@app.route('/signin', methods=['POST'])
def sign_in_user():
	auth = firebase.auth()

	try:
		user = auth.sign_in_with_email_and_password(request.json['email'], request.json['password'])

		db = firebase.database()

		results = db.child("users").child(user['localId']).child("userDetails").get(user['idToken'])
		return jsonify(message=results.val(), id=user['localId'], token=user['idToken'], refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

@app.route('/photo', methods=['POST'])
def upload_photo():
	auth = firebase.auth()

	try:
		storage = firebase.storage()
		db = firebase.database()

		user = auth.refresh(request.form['refreshToken'])

		results = storage.child("users").child(user['userId']).child(request.files['file'].filename).put(request.files['file'], user['idToken'])
		url = storage.child(results['name']).get_url(results['downloadTokens'])

		data = {
		    "url": str(url)
		}

		print(results['name'])

		fullFilename = results['name'].split('/')
		name = fullFilename[len(fullFilename) - 1].split('.')[1]

		addUrl = db.child("users").child(user['userId']).child("images").child(str(random.randint(1,101))).set(data, user['idToken'])

		return jsonify(refreshToken=user['refreshToken'], url=url)
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)

@app.route('/photos', methods=['GET'])
def get_photos():
	auth = firebase.auth()

	try:
		storage = firebase.storage()
		db = firebase.database()

		user = auth.refresh(request.args['refreshToken'])

		results = db.child("users").child(user['userId']).child("images").get(user['idToken'])

		return jsonify(images=results.val(), refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)


@app.route('/command', methods=['POST'])
def get_command_keywords():
	try:
		raw_audio = AudioSegment.from_file(request.files['file'])

		wav_path = "./sample.wav"
		raw_audio.export(wav_path, format="wav")

		with sr.AudioFile(wav_path) as source:
			audio = r.record(source)

		

		day = ""
		funct = ""

		try:
		    text = r.recognize_google_cloud(audio, credentials_json=GOOGLE_CLOUD_SPEECH_CREDENTIALS)

		    session = session_client.session_path("mystudentlife-220716", "1")
		    text_input = dialogflow.types.TextInput(text=text, language_code="en-US")
		    query_input = dialogflow.types.QueryInput(text=text_input)

		    response = session_client.detect_intent(session=session, query_input=query_input)
		    responseObject = MessageToDict(response)

		    payload = responseObject['queryResult']['fulfillmentMessages'][1]['payload']

		    funct = payload['function']

		    dayInfo = payload['date'].split('-')
		    date = datetime.date(int(dayInfo[0]), int(dayInfo[1]), int(dayInfo[2]))

		    day = date.strftime("%A")
		except sr.UnknownValueError:
		    print("Google Cloud Speech could not understand audio")
		except sr.RequestError as e:
		    print("Could not request results from Google Cloud Speech service; {0}".format(e))

		return jsonify(function=funct, day=day)
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)


@app.route('/font', methods=['POST'])
def put_font():
	auth = firebase.auth()

	try:
		user = auth.refresh(request.form['refreshToken'])

		db = firebase.database()

		result = db.child("users").child(user['localId']).child("design").child("font").push(request.form['font'], user['idToken'])
		return jsonify(message="Success", refreshToken=user['refreshToken'])
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)



if __name__ == '__main__':
	app.run(debug=True)
