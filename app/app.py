from flask import Flask
import os
import psycopg2

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "db")
DB_NAME = os.getenv("POSTGRES_DB", "devopsdb")
DB_USER = os.getenv("POSTGRES_USER", "devops")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "devopspass")


@app.route("/")
def home():
    return """
    <html>
        <head>
            <title>Techkraft DevOps Assignment</title>
        </head>
        <body>
            <h1>IT Infrastructure & DevOps Assignment</h1>
            <p>Flask application is running successfully.</p>
            <p>Nginx reverse proxy is working.</p>
            <p>PostgreSQL backend configured.</p>
        </body>
    </html>
    """


@app.route("/health")
def health():
    return {
        "status": "UP",
        "service": "flask-app"
    }


@app.route("/db-health")
def db_health():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        conn.close()

        return {
            "status": "UP",
            "database": "PostgreSQL"
        }

    except Exception as e:
        return {
            "status": "DOWN",
            "error": str(e)
        }, 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
