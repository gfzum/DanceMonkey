#!/bin/bash
set -e

echo "Starting dance-monkey backend service..."

# 升级pip
echo "Upgrading pip..."
python3 -m pip install --upgrade pip

# 安装依赖
echo "Installing dependencies..."
python3 -m pip install -e .

# 等待数据库
echo "Waiting for database..."
python3 -c "
import time
import psycopg2
import os

db_url = os.getenv('DATABASE_URL')
max_retries = 30
retry_interval = 2

for i in range(max_retries):
    try:
        conn = psycopg2.connect(db_url)
        conn.close()
        print('Database is ready!')
        break
    except psycopg2.OperationalError as e:
        if i == max_retries - 1:
            print('Could not connect to database after', max_retries, 'attempts')
            raise e
        print('Waiting for database...', i + 1, '/', max_retries)
        time.sleep(retry_interval)
"

# 运行数据库迁移
echo "Running database migrations..."
alembic upgrade head

# 初始化数据
echo "Initializing data..."
python3 app/seed_data.py

# 启动应用
echo "Starting application..."
exec python3 -m gunicorn app.main:app \
    --config gunicorn.conf.py \
    --access-logfile - \
    --error-logfile - \
    --log-level info
