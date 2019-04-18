from flask import Flask

app = Flask(__name__)

#@app.run(host='195.251.251.27', port=5000)
@app.route("/", methods=['GET'])
def hello():
    return "Hello World!"


if __name__ == '__main__':
    app.run(host='195.251.251.27' , port=8080)
