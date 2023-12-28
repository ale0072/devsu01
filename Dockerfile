# Official Docker Python image
FROM python:3.11-bullseye

# Environment variables
ENV PORT=8000

# Non-root user creation
RUN adduser --disabled-password devsuuser
USER devsuuser

# App labels
LABEL Name="Demo DevOps Python" Version=1.0.0
LABEL org.opencontainers.image.source="https://bitbucket.org/devsu/demo-devops-python"

# Working app directory, copy requirements, and install
WORKDIR /
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Add /usr/local/bin to the PATH
ENV PATH="/usr/local/bin:${PATH}"

# Copy app files
COPY manage.py .
COPY / ./

# Run migrations to set up the database
RUN python manage.py makemigrations
RUN python manage.py migrate

# Expose the app to a port
EXPOSE $PORT

# Defined healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost:$PORT/ || exit 1

# Default parameters to run the app
CMD ["gunicorn", "-b", "0.0.0.0:$PORT", "manage:app"]




