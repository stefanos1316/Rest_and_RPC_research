from flask import Flask
from flask_jsonrpc import JSONRPC

app = Flask(__name__)
jsonrpc = JSONRPC(app, '/helloWord')

@jsonrpc.method('App.helloWord')
def helloWord():
    return 'Hello word'

if __name__ == '__main__':
    app.run(host='192.168.1.12', port=8000)
