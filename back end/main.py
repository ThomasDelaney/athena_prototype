from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/mainpage/')
def mainpage():
	return jsonify(title="BACK END SAYS HELLO!")

if __name__ == '__main__':
	app.run(debug=True)