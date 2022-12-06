''
import requests
import json
import hashlib
import uuid
import time
import os

app_id = str(uuid.getnode()).encode()
md5_app_id = hashlib.md5(app_id).hexdigest()
data = {
    'cmd': 'sensorsValues',
    'uuid': md5_app_id,
    'sensors': '81392',
    'lang': 'ru'
}
headers = {
    'User-Agent': 'ataraxiadev.com',
    'Accept-Encoding': 'gzip, deflate'
}


def read_key(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        return file.readline().split()[0]


def read_temp(filename):
    try:
        file = open(filename, 'r', encoding='utf-8')
    except FileNotFoundError:
        return None
    else:
        read_time = int(file.readline()) // 1000000000
        current_time = time.time_ns()
        # 10 minutes
        if (current_time - read_time < 600):
            return None
        else:
            return file.readline().split()[0]


def write_temp(filename, temp):
    with open(filename, 'w', encoding='utf-8') as file:
        timestamp = time.time_ns()
        print(timestamp, file=file)
        print(temp, file=file)


def print_page(text, **args):
    print('Content-Type: text/plain')
    print("")
    if args:
        print(text, args)
    else:
        print(text)


try:
    tmpdir = os.getenv('TMP') or os.getenv('TMPDIR') or '/tmp'
    temp_file = os.path.join(tmpdir, "narodmon-temp")
    temp = read_temp(temp_file)
    if temp is not None:
        print_page(temp)
        raise SystemExit(0)
    api_key = read_key('/var/secrets/narodmon-key')
    data['api_key'] = api_key
    response = requests.post(
        'http://narodmon.com/api',
        json=data,
        headers=headers
    )
    result = json.loads(response.text)
    temp = result['sensors'][0]['value']
    print_page(temp)
    write_temp(temp_file, temp)
except requests.RequestException as e:
    print_page('Request error:', e)
except (ValueError, TypeError) as e:
    print_page('JSON error:', e)
except (FileNotFoundError, OSError, IOError) as e:
    print_page("I/O error({0}): {1}".format(e.errno, e.strerror))
except Exception as e:
    print_page("Unexpected error({0}): {1}".format(e.errno, e.strerror))
''
