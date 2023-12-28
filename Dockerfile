# official docker python image
FROM python:3.11-bullseye

# environment variables
ENV PORT=8000

# non-root user creation
RUN adduser --disabled-password devsuuser

# set the working directory
WORKDIR /

# copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy app files
COPY manage.py .
COPY / ./


# switch back to the non-root user
USER devsuuser

# run migrations
CMD ["sh", "-c", "python manage.py makemigrations && python manage.py migrate && gunicorn -b 0.0.0.0:$PORT manage:app"]










