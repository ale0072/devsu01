# Official Docker Python image
FROM python:3.11-bullseye

# Environment variables
ENV PORT=8000

# Non-root user creation
USER root

# Install necessary packages and set up Google Cloud SDK
RUN apt-get update && \
    apt-get install -y curl && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk

# Non-root user creation
RUN adduser --disabled-password devsuuser

# Switch to non-root user
USER devsuuser

# App labels
LABEL Name="Demo DevOps Python" Version=1.0.0
LABEL org.opencontainers.image.source="https://bitbucket.org/devsu/demo-devops-python"

# Working app directory && copy requirements && install
WORKDIR /
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files && run migrations
COPY manage.py .
COPY / ./

# Expose the app to a port
EXPOSE $PORT

# Defined healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost:$PORT/ || exit 1

# Default params to run the app
CMD ["gunicorn", "-b", "0.0.0.0:$PORT", "manage:app"]
