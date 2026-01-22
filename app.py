from flask import Flask, render_template, request
import requests
import socket

app = Flask(__name__)

def get_server_public_ip():
    try:
        # Attempt to get the server's own public IP
        response = requests.get('https://api.ipify.org?format=json', timeout=2)
        return response.json().get('ip', 'Unknown')
    except:
        return 'Unavailable'

@app.route('/')
def index():
    # Visitor's IP as seen by the server (this is the Global/VPN IP if tunneled)
    visitor_ip = request.remote_addr
    
    # Check for X-Forwarded-For header in case of proxy
    if request.headers.getlist("X-Forwarded-For"):
        visitor_ip = request.headers.getlist("X-Forwarded-For")[0]

    # Server's Public IP (Global)
    server_global_ip = get_server_public_ip()
    
    # Server's Local IP (Container IP)
    hostname = socket.gethostname()
    server_local_ip = socket.gethostbyname(hostname)

    return render_template(
        'index.html', 
        visitor_ip=visitor_ip, 
        server_global_ip=server_global_ip,
        server_local_ip=server_local_ip
    )

if __name__ == '__main__':
    app.run(host='10.60.0.0', port=80)
