FROM python:3.11-bullseye

LABEL Name="Demo DevOps Python" Version=1.0.0
LABEL org.opencontainers.image.source = "https://bitbucket.org/devsu/demo-devops-python"

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY manage.py .
COPY app ./app
RUN python manage.py makemigrations
RUN python manage.py migrate

EXPOSE 8000

CMD ["gunicorn", "-b", "0.0.0.0:8000", "manage:app"]
