FROM python:3.9-alpine3.13

LABEL maintainer="leomconti@gmail.com"

ENV PYTHONUNBUFFERED 1

# Install system dependencies
RUN apk add --update --no-cache postgresql-client
RUN apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev

# Install Python dependencies
COPY ./requirements.txt /requirements.txt
COPY ./requirements.dev.txt /requirements.dev.txt
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /requirements.txt && \
    if [ "$DEV" = "true" ] ; then /py/bin/pip install -r /requirements.dev.txt ; fi && \
    apk del .tmp-build-deps

# Cleanup
RUN rm -rf /tmp

# Add the user for running the application
RUN adduser --disabled-password --no-create-home django-user

# Set up the app directory
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ENV PATH="/py/bin:$PATH"

USER django-user

# when making changes: docker compose BUILD
# docker compose up and down just runs the container