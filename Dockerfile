#
# Build frontend
#

FROM node:latest AS build

RUN mkdir /frontend
WORKDIR /frontend

COPY ./frontend/index.html /frontend/index.html
COPY ./frontend/vite.config.js /frontend/vite.config.js
COPY ./frontend/public /frontend/public
COPY ./frontend/package.json /frontend/package.json

RUN yarn install
COPY ./frontend/src /frontend/src
RUN yarn build


#
# Main container
#

FROM python:3.11
ENV PYTHONBUFFERED=1

RUN mkdir /backend
WORKDIR /backend

COPY ./backend/pyproject.toml /backend/pyproject.toml

RUN \
  pip install -U pip && \
  pip install poetry && \
  poetry config virtualenvs.create false && \
  poetry install --no-interaction --no-ansi

COPY ./backend/static /backend/static
COPY ./backend/start.sh /backend/start.sh
COPY ./backend/reload.sh /backend/reload.sh
COPY ./backend/demogen /backend/demogen
COPY ./backend/linker /backend/linker
COPY ./backend/setup /backend/setup

COPY ./backend/schemas /backend/schemas
COPY ./backend/ayon_server /backend/ayon_server
COPY ./backend/api /backend/api

COPY --from=build /frontend/dist/ /frontend

#ENTRYPOINT /backend/start.sh
CMD `docker compose up -d`
