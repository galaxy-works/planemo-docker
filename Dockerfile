FROM python:3.7-slim-stretch AS builder

# vaguely modeled after
# https://github.com/mvdbeek/planemo-action/blob/master/Dockerfile

MAINTAINER jmchilton@gmail.com

ARG galaxy_branch=master

ENV PLANEMO_VENV=/planemo_venv
#ENV GALAXY_VENV=/venv
#ENV GALAXY_ROOT=/galaxy
#ENV GALAXY_VIRTUAL_ENV=/venv
#ENV PLANEMO_TARGET=https://github.com/jmchilton/planemo/archive/reporting_workflows.zip

RUN apt-get update && apt-get install -y --no-install-recommends curl wget git build-essential software-properties-common apt-transport-https gnupg2
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install --no-install-recommends -y docker-ce-cli
RUN pip install virtualenv
# RUN mkdir /galaxy && wget -q https://codeload.github.com/galaxyproject/galaxy/tar.gz/${galaxy_branch} -O - | tar -C '/galaxy' --strip-components=1 -xvz
# RUN cd /galaxy && GALAXY_VIRTUAL_ENV=$GALAXY_VENV DEV_WHEELS=1 GALAXY_SKIP_CLIENT_BUILD=1 sh scripts/common_startup.sh
ENV PLANEMO_TARGET=https://github.com/jmchilton/planemo/archive/reporting_workflows.zip
RUN virtualenv $PLANEMO_VENV && \
     cd /root && \
    . $PLANEMO_VENV/bin/activate && pip install "$PLANEMO_TARGET"

FROM python:3.7.5-slim-stretch
COPY --from=builder /usr/bin/docker /usr/bin/docker
#COPY --from=builder $GALAXY_VENV $GALAXY_VENV
COPY --from=builder $PLANEMO_ENV $PLANEMO_ENV
#COPY --from=builder $GALAXY_ROOT $GALAXY_ROOT
RUN mkdir /root/.planemo/ && curl -L 'https://github.com/involucro/involucro/releases/download/v1.1.2/involucro' -o '/root/.planemo/involucro' && chmod +x /root/.planemo/involucro

#ENV GALAXY_VIRTUAL_ENV=/venv
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
