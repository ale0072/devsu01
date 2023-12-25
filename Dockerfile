#official docker python image
FROM python:3.11-bullseye
#environment variables
ENV PORT=8000
#app labels
LABEL Name="Demo DevOps Python" Version=1.0.0
LABEL org.opencontainers.image.source = "https://bitbucket.org/devsu/demo-devops-python"
#working app directory && copy requierments && install 
WORKDIR /
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
#copy app files && run migrations
COPY manage.py .
COPY / ./
RUN python manage.py makemigrations
RUN python manage.py migrate
#expose the app to a port
EXPOSE $PORT
#defined healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost:$PORT/ || exit 1
#default params to run the app
CMD ["gunicorn", "-b", "0.0.0.0:$PORT", "manage:app"]
