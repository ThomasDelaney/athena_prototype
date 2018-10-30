from flask import Flask, jsonify, request, abort
import pyrebase
import requests
import logging

app = Flask(__name__)

firebase = pyrebase.initialize_app(config)

@app.route('/mainpage/')
def mainpage():
	return jsonify(title="BACK END SAYS HELLO!")

@app.route('/user', methods=['POST'])
def register_user():
	auth = firebase.auth()

	try:
		user = auth.create_user_with_email_and_password(request.json['email'], request.json['password'])

		logging.debug(user)

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

if __name__ == '__main__':
	app.run(debug=True)