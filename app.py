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
    # Visitor's IP as seen by the server
    # When using Hysteria2/Xray on the same server, this will often be 127.0.0.1
    # because the VPN server acts as a local proxy.
    visitor_ip = request.remote_addr
    
    # Check for X-Forwarded-For header in case of proxy (Nginx etc)
    forwarded_ip = None
    if request.headers.getlist("X-Forwarded-For"):
        forwarded_ip = request.headers.getlist("X-Forwarded-For")[0]

    # Server's Public IP (Global)
    server_global_ip = get_server_public_ip()
    
    # Server's Local IP
    hostname = socket.gethostname()
    server_local_ip = socket.gethostbyname(hostname)

    # Get all headers for debug
    headers = dict(request.headers)

    return render_template(
        'index.html', 
        visitor_ip=visitor_ip, 
        forwarded_ip=forwarded_ip,
        server_global_ip=server_global_ip,
        server_local_ip=server_local_ip,
        headers=headers
    )

if __name__ == '__main__':
    # Для HTTPS нужен SSL контекст
    app.run(
        host='0.0.0.0', 
        port=80,
        ssl_context=('/app/certs/cert.pem', '/app/certs/key.pem')
    )
