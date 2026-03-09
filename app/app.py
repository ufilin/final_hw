import os
from flask import Flask, jsonify
import pymysql
import time

app = Flask(__name__)

# Получение параметров подключения к БД из переменных окружения
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_PORT = int(os.environ.get('DB_PORT', 3306))
DB_USER = os.environ.get('DB_USER', 'app_user')
DB_PASSWORD = os.environ.get('DB_PASSWORD', '')
DB_NAME = os.environ.get('DB_NAME', 'app_db')

def get_db_connection():
    """Функция для подключения к БД"""
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except Exception as e:
        print(f"Ошибка подключения к БД: {e}")
        return None

@app.route('/')
def index():
    return jsonify({
        'message': 'Hello from Docker container!',
        'status': 'running',
        'db_configured': bool(DB_HOST != 'localhost')
    })

@app.route('/health')
def health():
    """Endpoint для проверки здоровья"""
    return jsonify({'status': 'healthy'}), 200

@app.route('/db-test')
def db_test():
    """Тестирование подключения к БД"""
    conn = get_db_connection()
    if conn:
        try:
            with conn.cursor() as cursor:
                cursor.execute('SELECT 1 as test')
                result = cursor.fetchone()
            conn.close()
            return jsonify({
                'status': 'success',
                'message': 'Database connection successful',
                'data': result
            })
        except Exception as e:
            return jsonify({
                'status': 'error',
                'message': f'Database query failed: {str(e)}'
            }), 500
    else:
        return jsonify({
            'status': 'error',
            'message': 'Could not connect to database'
        }), 500

@app.route('/health/db')
def db_health():
    """Проверка здоровья БД"""
    conn = get_db_connection()
    if conn:
        conn.close()
        return jsonify({'status': 'healthy', 'db': 'connected'}), 200
    return jsonify({'status': 'unhealthy', 'db': 'disconnected'}), 503

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)