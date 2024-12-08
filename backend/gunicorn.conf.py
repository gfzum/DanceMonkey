import multiprocessing
import os

# Server socket
bind = os.getenv("GUNICORN_BIND", "0.0.0.0:8000")
backlog = 2048

# Worker processes
workers = int(os.getenv("GUNICORN_WORKERS", (multiprocessing.cpu_count() * 2) + 1))
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 1000
timeout = 600
keepalive = 2

# Process naming
proc_name = "dance-monkey"
pythonpath = "."

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Process management
daemon = False
pidfile = None
umask = 0
user = None
group = None
tmp_upload_dir = None

# SSL
keyfile = None
certfile = None

# Server mechanics
chdir = "."
reload = False
reload_engine = "auto"
spew = False
check_config = False

# Server hooks
def on_starting(server):
    """Log that Gunicorn is starting."""
    server.log.info("Starting dance-monkey server")

def on_reload(server):
    """Log that Gunicorn is reloading."""
    server.log.info("Reloading dance-monkey server")

def on_exit(server):
    """Log that Gunicorn is shutting down."""
    server.log.info("Shutting down dance-monkey server")
