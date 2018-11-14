from flask import Flask, jsonify, request, abort
import pyrebase
import requests
import logging
import json
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
import random

app = Flask(__name__)


firebase = pyrebase.initialize_app(config)

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

		name = results['name'].split('/').split('.')

		print(name)

		print(name[len(name)-1])

		addUrl = db.child("users").child(user['userId']).child("images").child(str(random.randint(1,101))).set(data, user['idToken'])

		print(user)

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


if __name__ == '__main__':
	app.run(debug=True)