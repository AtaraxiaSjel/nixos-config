''
import datetime
import requests
import json
import io
import sqlite3
from sqlite3 import Error
from requests.exceptions import RequestException


database = "/srv/yandex.db"
params_file = "/var/secrets/yandex-token"


def create_connection(db_file):
    conn = None
    try:
        conn = sqlite3.connect(db_file,
                               detect_types=sqlite3.PARSE_DECLTYPES |
                               sqlite3.PARSE_COLNAMES)
    except Error as e:
        SystemExit(e)
    return conn


def create_ride(conn):
    sql = """ CREATE TABLE IF NOT EXISTS RIDE (
                distance REAL NOT NULL,
                class_name TEXT NOT NULL,
                min_price INT NOT NULL,
                price INT NOT NULL,
                waiting_time INT NOT NULL,
                time INT NOT NULL,
                timestamp TIMESTAMP NOT NULL) """
    cur = conn.cursor()
    cur.execute(sql)
    conn.commit()
    return cur.lastrowid


def insert_ride(conn, ride):
    sql = """ INSERT INTO ride(distance,class_name,min_price,
              price,waiting_time,time,timestamp)
              VALUES(?,?,?,?,?,?,?) """
    cur = conn.cursor()
    cur.execute(sql, ride)
    conn.commit()
    return cur.lastrowid


def get_api_json(json_data):
    headers = json_data['headers']
    params = json_data['params']
    uri = 'https://taxi-routeinfo.taxi.yandex.net/taxi_info'

    try:
        r = requests.get(uri, params=params, headers=headers)
    except RequestException as e:
        raise SystemExit(e)
    return r.json()


def read_params(filename):
    try:
        with io.open(filename, 'r', encoding='utf-8') as in_file:
            json_data = json.load(in_file)
    except Exception as e:
        SystemExit(e)
    return json_data


def main():
    conn = create_connection(database)
    with conn:
        create_ride(conn)

        params_json = read_params(params_file)
        json_data = get_api_json(params_json)
        currentDateTime = datetime.datetime.now()

        for i in range(2):
            opt = json_data['options'][i]
            ride = (json_data['distance'], opt['class_name'],
                    opt['min_price'], opt['price'],
                    opt['waiting_time'], json_data['time'],
                    currentDateTime)
            insert_ride(conn, ride)


if __name__ == '__main__':
    main()
''
