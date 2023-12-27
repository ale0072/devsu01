#official docker python image
FROM python:3.11-bullseye
#environment variables

ENV PORT=8000

#non-root user creation
RUN adduser --disabled-password devsuuser
USER devsuuser

#app labels
LABEL Name="Demo DevOps Python" Version=1.0.0
LABEL org.opencontainers.image.source = "https://bitbucket.org/devsu/demo-devops-python"

#working app directory && copy requierments && install 
WORKDIR /
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN apt-get update && \
    apt-get install -y curl && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk
    
#copy app files && run migrations
COPY manage.py .
COPY / ./

#expose the app to a port
EXPOSE $PORT

#defined healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost:$PORT/ || exit 1
  
#default params to run the app
CMD ["gunicorn", "-b", "0.0.0.0:$PORT", "manage:app"]
