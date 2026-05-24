#!/usr/bin/env bash
set -e

echo "⏳ Esperando a PostgreSQL en ${POSTGRES_HOST:-db}:${POSTGRES_PORT:-5432}..."
until python -c "import socket,os,sys; s=socket.socket(); s.settimeout(2); \
  s.connect((os.getenv('POSTGRES_HOST','db'), int(os.getenv('POSTGRES_PORT','5432'))))" 2>/dev/null; do
  sleep 1
done
echo "✅ PostgreSQL disponible."

python manage.py migrate --noinput
python manage.py seed || true

echo "🚀 Iniciando servidor en :8000"
exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 3 --reload
