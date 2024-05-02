# syntax=docker/dockerfile:1

FROM python:3.12-slim-bookworm

LABEL project="microk8s-setup" name="helloworld"
ARG DEBIAN_FRONTEND=noninteractive
ARG USER=appuser
ENV APPUSER=$USER LANG=C.UTF-8 LC_ALL=C.UTF-8 PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 WORKDIR=/app
WORKDIR $WORKDIR
RUN useradd --skel /dev/null --create-home $APPUSER
RUN chown $APPUSER:$APPUSER $WORKDIR
ENV PATH="/home/${APPUSER}/.local/bin:${PATH}"
ARG PACKAGES_PATH=/home/${APPUSER}/.local/lib/python3.12/site-packages
USER $APPUSER
COPY --chown=$APPUSER . .
CMD ["python3", "-m", "http.server", "-d", "/app/static/", "8000"]
