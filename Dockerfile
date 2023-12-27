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

# Working app directory and copy requirements, then install
WORKDIR /
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files and run migrations
COPY manage.py .
COPY / ./

# Expose the app to a port
EXPOSE $PORT

# Defined healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost:$PORT/ || exit 1

# Install curl and lsb-release, add the Google Cloud SDK repository, and install the Google Cloud SDK
USER root
RUN apt-get update && \
    apt-get install -y curl lsb-release && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk

# Default params to run the app
USER devsuuser
CMD ["gunicorn", "-b", "0.0.0.0:$PORT", "manage:app"]

