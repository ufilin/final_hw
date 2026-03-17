# /home/debian/netology/terraform/final_hw/app/app.py
from flask import Flask, jsonify, render_template_string
import mysql.connector
from mysql.connector import Error
import os
import time

app = Flask(__name__)

DB_HOST = os.environ.get('DB_HOST')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = os.environ.get('DB_NAME')
DB_PORT = int(os.environ.get('DB_PORT', 3306))
PORT = int(os.environ.get('PORT', 5000))

def get_db_connection():
    """Создание подключения к БД с повторными попытками"""
    max_retries = 5
    retry_delay = 2
    
    for attempt in range(max_retries):
        try:
            connection = mysql.connector.connect(
                host=DB_HOST,
                database=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD,
                port=DB_PORT,
                connection_timeout=10
            )
            return connection
        except Error as e:
            if attempt < max_retries - 1:
                time.sleep(retry_delay)
                continue
            else:
                raise e
    return None

def init_database():
    """Инициализация БД при старте"""
    try:
        connection = get_db_connection()
        if connection:
            cursor = connection.cursor()
            
            # Создание таблицы messages, если не существует
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS messages (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    title VARCHAR(200) NOT NULL,
                    content TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Проверяем, есть ли уже данные
            cursor.execute("SELECT COUNT(*) FROM messages")
            count = cursor.fetchone()[0]
            
            # Если таблица пустая, добавляем тестовые данные
            if count == 0:
                test_messages = [
                    ('Welcome Message', 'Hello from Docker container!'),
                    ('Database Info', f'Connected to {DB_HOST}'),
                    ('Current Time', f'Server time: {time.strftime("%Y-%m-%d %H:%M:%S")}')
                ]
                cursor.executemany(
                    "INSERT INTO messages (title, content) VALUES (%s, %s)",
                    test_messages
                )
                connection.commit()
                print("✅ Тестовые данные добавлены")
            
            cursor.close()
            connection.close()
            return True
    except Error as e:
        print(f"❌ Ошибка инициализации БД: {e}")
        return False

# HTML шаблон для отображения страницы
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Docker App with MySQL</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
        .status { padding: 10px; border-radius: 5px; margin: 20px 0; }
        .connected { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .disconnected { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background: #4CAF50; color: white; padding: 10px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background: #f5f5f5; }
        .info { background: #e7f3fe; border-left: 4px solid #2196F3; padding: 10px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Docker + MySQL в Yandex Cloud</h1>
        
        <div class="status {{ 'connected' if db_status else 'disconnected' }}">
            <strong>Статус БД:</strong> {{ '✅ Подключено' if db_status else '❌ Нет подключения' }}
            {% if db_status %}
            <br><strong>Хост:</strong> {{ db_host }}
            <br><strong>База данных:</strong> {{ db_name }}
            {% endif %}
        </div>
        
        <div class="info">
            <strong>📌 Информация:</strong> Приложение подключено к Managed MySQL в Yandex Cloud.<br>
            <strong>🕒 Время сервера:</strong> {{ current_time }}
        </div>
        
        <h2>📝 Сообщения из базы данных</h2>
        
        {% if messages %}
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Заголовок</th>
                    <th>Содержание</th>
                    <th>Создано</th>
                </tr>
            </thead>
            <tbody>
                {% for msg in messages %}
                <tr>
                    <td>{{ msg[0] }}</td>
                    <td><strong>{{ msg[1] }}</strong></td>
                    <td>{{ msg[2] }}</td>
                    <td>{{ msg[3] }}</td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
        {% else %}
        <p>Нет сообщений в базе данных</p>
        {% endif %}
        
        <p style="margin-top: 20px; color: #666; font-size: 0.9em; text-align: center;">
            🚀 Работает в Docker контейнере • Данные хранятся в {{ db_name }} на {{ db_host }}
        </p>
    </div>
</body>
</html>
"""

@app.route('/')
def index():
    """Главная страница с отображением данных из БД"""
    messages = []
    db_status = False
    
    try:
        connection = get_db_connection()
        if connection and connection.is_connected():
            cursor = connection.cursor(dictionary=False)
            cursor.execute("SELECT id, title, content, created_at FROM messages ORDER BY created_at DESC")
            messages = cursor.fetchall()
            cursor.close()
            connection.close()
            db_status = True
    except Error as e:
        print(f"Database error: {e}")
    
    return render_template_string(
        HTML_TEMPLATE,
        messages=messages,
        db_status=db_status,
        db_host=DB_HOST,
        db_name=DB_NAME,
        current_time=time.strftime("%Y-%m-%d %H:%M:%S")
    )

@app.route('/health')
def health():
    """Проверка здоровья"""
    return jsonify({'status': 'healthy'})

@app.route('/db-test')
def db_test():
    """Тест подключения к БД"""
    try:
        connection = get_db_connection()
        if connection and connection.is_connected():
            cursor = connection.cursor()
            cursor.execute("SELECT COUNT(*) FROM messages")
            count = cursor.fetchone()[0]
            cursor.close()
            connection.close()
            return jsonify({
                'status': 'connected',
                'database': DB_NAME,
                'host': DB_HOST,
                'messages_count': count
            })
    except Error as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/health/db')
def db_health():
    """Проверка здоровья БД"""
    return db_test()

# Инициализация БД при запуске
with app.app_context():
    init_database()
    print("✅ Приложение готово к работе")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT)