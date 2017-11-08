from flask import Flask
from flask import request


server = Flask(__name__)

# A route to handle the logic for phone calls.
@server.route('/register', methods=['POST'])
def register():
    print(request.data)
    return 'success'

if __name__ == '__main__':
    server.run(host='0.0.0.0', debug=True, port=8000);
