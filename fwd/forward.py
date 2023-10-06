import os
import socket
import argparse
import threading

parser=argparse.ArgumentParser(description='socks/ssh forward')
parser.add_argument('--mode', type=str, help='select mode socks or ssh', required=True)
args = parser.parse_args()

if args.mode=='socks':
    public_port=int(os.environ['EXTERNAL_SOCKS5_PORT'])
    forward_port=1080 #internal port of socks5 container
elif args.mode=='ssh':
    public_port=int(os.environ['EXTERNAL_SSH_PORT'])
    forward_port=2222 #internal port of ssh container

log=True if os.environ['LOG'] == 'true' else False


def forward(source_port, target_host, target_port):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        server.bind(('0.0.0.0', source_port))
    except Exception as e:
        if log:print(f"Failed to bind on port {source_port}: {str(e)}")
        return

    server.listen(5)
    if log:print(f"Port forwarding on port {source_port} to {target_host}:{target_port}")

    while True:
        client_socket, addr = server.accept()
        if log:print(f"Accepted connection from {addr[0]}:{addr[1]}")
        target = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        target.connect((target_host, target_port))
        forward_thread1 = threading.Thread(target=forward_data, args=(client_socket, target))
        forward_thread2 = threading.Thread(target=forward_data, args=(target, client_socket))
        forward_thread1.start()
        forward_thread2.start()

def forward_data(source, target):
    while True:
        data = source.recv(1024)
        if len(data) == 0:
            break
        target.send(data)
    
    source.close()
    target.close()

if __name__ == '__main__':
    forward(public_port, 'vpnclient', forward_port)
    #forwarding to vpnclient as both socks5 and ssh is in network_mode
