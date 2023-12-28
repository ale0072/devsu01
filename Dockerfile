#official docker python image
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

# create directories for static and media if they don't exist
RUN mkdir -p /static /media

# grant permissions to the user
RUN chown -R devsuuser:devsuuser /static /media

# switch back to the non-root user
USER devsuuser

# run migrations
RUN python manage.py makemigrations
RUN python manage.py migrate --noinput

# expose the app to a port
EXPOSE $PORT

# defined healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost:$PORT/ || exit 1

# default params to run the app
CMD ["gunicorn", "-b", "0.0.0.0:$PORT", "manage:app"]









