import requests
import sys
import json
import time
namerequests = 'http://147.135.80.138:80/api/set_sinal'


def send_db(send):
    global namerequests
    try:
        fd = requests.post(namerequests,data = send+'f')
        print(fd.json())
    except Exception as jk:
        print(jk)
data_messagem= []
while True:
    print('pego')
    with open('arquivosdesinais.txt', 'r+') as f:
        data_messagem = f.read().split('\n')
        print(f.read().split('\n') , len(data_messagem))
        if  len(f.read().split('\n')) >0:
            print('sss')
            for g in f.read().split('\n'):
                data_messagem.append(g)
    
    if len(data_messagem) > 1 or data_messagem !='':
        open('arquivosdesinais.txt', 'w').close()
        for msg in data_messagem:
            print(msg)
            if msg !='':
                send_db(msg)
        data_messagem.clear()
    time.sleep(2)