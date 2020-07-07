FROM python:3.6-alpine

# Build arguments passed into the docker command for image metadata
ARG BUILD_DATE
ARG COMMIT
ARG BRANCH

COPY requirements.txt /requirements.txt

# RUN pip install requests docker python-json-logger structlog && \
RUN apk add gcc make musl-dev linux-headers libffi-dev && \
    pip3 install --upgrade pip && \
    pip3 install --no-binary gevent -r /requirements.txt && \
    apk del gcc make musl-dev linux-headers libffi-dev

COPY *.py logging.conf *.conf /app/

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/kbase/narrative-traefiker.git" \
      org.label-schema.vcs-ref=$COMMIT \
      org.label-schema.schema-version="1.0.0-rc1" \
      us.kbase.vcs-branch=$BRANCH  \
      maintainer="Steve Chan sychan@lbl.gov"

WORKDIR /app

USER nobody
ENV COMMIT_SHA=${COMMIT}

ENTRYPOINT [ "gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--worker-class", "gevent", "--log-config", "logging.conf", "-c", "config.py", "app:app" ]
