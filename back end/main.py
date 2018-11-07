from flask import Flask, jsonify, request, abort
import pyrebase
import requests
import logging
import json
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

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

		user = auth.refresh(request.form['refreshToken'])

		results = storage.child("users").child(user['userId']).child(request.files['file'].filename).put(request.files['file'], user['idToken'])
		return jsonify(message="Success")
	except requests.exceptions.HTTPError as e:
		new = str(e).replace("\n", '')
		parsedError = new[new.index("{"):]
		return jsonify(response=parsedError)


if __name__ == '__main__':
	app.run(debug=True)