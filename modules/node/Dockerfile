FROM buildpack-deps:jessie

MAINTAINER Vince Chu <vwchu@users.noreply.github.com>

RUN groupadd --gid 1000 node && \
    useradd --uid 1000 --gid node --shell /bin/bash --create-home node

#####################################
# Node / NVM:
#####################################

USER node

ENV NPM_CONFIG_LOGLEVEL info
ARG NODE_VERSION=stable
ENV NODE_VERSION ${NODE_VERSION}
ENV NVM_DIR /home/node/.nvm

# Install nvm (A Node Version Manager)
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias ${NODE_VERSION}

# Wouldn't execute when added to the RUN statement in the above block
# Source NVM when loading bash since ~/.profile isn't loaded on non-login shell
RUN echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc

# Add NVM binaries to root's .bashrc
USER root

RUN echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="/home/node/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc

#####################################
# YARN:
#####################################

USER node

ARG INSTALL_YARN=false
ENV INSTALL_YARN ${INSTALL_YARN}
ARG YARN_VERSION=latest
ENV YARN_VERSION ${YARN_VERSION}

RUN if [ ${INSTALL_YARN} = true ]; then \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    if [ ${YARN_VERSION} = "latest" ]; then \
        curl -o- -L https://yarnpkg.com/install.sh | bash; \
    else \
        curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version ${YARN_VERSION}; \
    fi && \
    echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> ~/.bashrc \
;fi

# Add YARN binaries to root's .bashrc
USER root

RUN if [ ${INSTALL_YARN} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export YARN_DIR="/home/node/.yarn"' >> ~/.bashrc && \
    echo 'export PATH="$YARN_DIR/bin:$PATH"' >> ~/.bashrc \
;fi

#####################################
# NPM Globals:
#####################################

USER root

ARG NPM_GLOBALS
ENV NPM_GLOBALS ${NPM_GLOBALS}

RUN if [ -n "${NPM_GLOBALS}" ]; then \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
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
