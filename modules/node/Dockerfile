ARG NODE_VERSION=stable

FROM node:${NODE_VERSION}

MAINTAINER Vince Chu <vwchu@users.noreply.github.com>

#####################################
# YARN:
#####################################

USER root

ARG INSTALL_YARN=false
ENV INSTALL_YARN ${INSTALL_YARN}
ARG YARN_VERSION=latest
ENV YARN_VERSION ${YARN_VERSION}

RUN if [ ${INSTALL_YARN} = true ]; then \
    npm install -g yarn@${YARN_VERSION} \
;fi

#####################################
# NPM Globals:
#####################################

USER root

ARG NPM_GLOBALS
ENV NPM_GLOBALS ${NPM_GLOBALS}

RUN if [ -n "${NPM_GLOBALS}" ]; then \
    npm install -g ${NPM_GLOBALS} \
;fi

#####################################
# Entrypoint:
#####################################

USER node
RUN mkdir -p /home/node/bin
COPY entrypoint.sh /home/node/bin/entrypoint.sh

USER root
RUN chown -R node:node /home/node/bin && \
    chmod +x /home/node/bin/entrypoint.sh

#####################################
# Working Directory:
#####################################

USER node
RUN mkdir -p /home/node/app && \
    mkdir -p /home/node/app/node_modules && \
    chown -R node:node /home/node/app && \
    chown -R node:node /home/node/app/node_modules

#####################################
# Configure PATH:
#####################################

USER node
RUN touch /home/node/.bashrc && \
    echo 'export PATH="$HOME/bin:$PATH"' >> /home/node/.bashrc && \
    echo 'export PATH="$HOME/app/node_modules/.bin:$PATH"' >> /home/node/.bashrc && \
    echo 'export PATH="$PATH:."' >> /home/node/.bashrc

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

USER node
WORKDIR /home/node/app
