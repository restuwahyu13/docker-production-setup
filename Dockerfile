# =======================================
# BUILD STEP APPLICATION ENVIRONMENT
# =======================================

FROM golang:1.20.4-alpine3.18 as build

LABEL name="Restu Wahyu Saputra"
LABEL email="restuwahyu13@gmail.com"
LABEL linkedin="https://www.linkedin.com/in/restuwahyu13"
LABEL gitHub="https://github.com/restuwahyu13"

ARG ROOT_DIR=app
ARG USER_ACCOUNT=gopher
ARG USER_UID=300
ARG USER_GID=300

ENV GO111MODULE="on" \
  CGO_ENABLED="0"

WORKDIR /usr/src/${ROOT_DIR}
COPY --chown=${USER_UID}:${USER_GID} . .

RUN apk update \
  && apk -u list \
  && apk upgrade \
  && apk --no-cache --update add upx \
  build-base

RUN go mod tidy \
  && go mod verify \
  && go build --ldflags "-r -s -w -extldflags" -o main . \
  && upx -9 ./main \
  && upx -t ./main

USER ${USER_ACCOUNT}

# =======================================
# RELEASE STEP APPLICATION ENVIRONMENT
# =======================================

FROM alpine:latest as release
ARG ROOT_DIR=app
ARG USER_ACCOUNT=linuxer
ARG USER_UID=600
ARG USER_GID=600

RUN apk update \
  && apk -u list \
  && apk upgrade \
  && apk --no-cache --update add shadow \
  tzdata \
  ca-certificates

RUN mkdir /home/${USER_ACCOUNT} \
  && groupadd -r -g $USER_GID $USER_ACCOUNT \
  && useradd -r -u $USER_UID -g $USER_GID $USER_ACCOUNT -s /bin/false -d /home/$USER_ACCOUNT -M \
  && groupmod -g $USER_GID $USER_ACCOUNT \
  && usermod -u $USER_UID -g $USER_GID $USER_ACCOUNT \
  && chown -R $USER_UID:$USER_GID /home/$USER_ACCOUNT

RUN mkdir /home/${USER_ACCOUNT}/${ROOT_DIR}
COPY --chown=${USER_UID}:${USER_GID} --from=build /usr/src/${ROOT_DIR}  /home/${USER_ACCOUNT}/${ROOT_DIR}
RUN chmod -R 6744 /home/$USER_ACCOUNT

USER $USER_ACCOUNT
ENTRYPOINT ["./home/linuxer/app/main"]