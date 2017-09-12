#!/bin/bash
BASEDIR=$(dirname $0)

function build(){
  echo "npm install ...."
  cd workspace/test-node-module/ \
  && npm install
}

function checkout(){
    echo "checkout ...."
    mkdir ~/.ssh/ && ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    mkdir workspace
    echo ${BASEDIR}/workspace
    #@TODO: Fix git clone for private repos using ssh keys
    # We will get "Permission denied (publickey)" error if we try to clone even
    # a public repo without a valid ssh private key associated to our github
    # account.
    (cd workspace &&  git clone git://github.com/imranansari/test-node-module.git)
}

function pipeline(){
    echo "executing pipeline ...."
    checkout \
    && build
}

function dockerBuildPipeline(){
    if [ -e Dockerfile ]
    then
        echo "Dockerfile present, doing docker build"
        docker build -t myimage .
    else
        echo "Dockerfile not present, building using node:onbuild"
        docker run -ti --rm --name build-app -v $PWD:/usr/src/app/ -w \
        /usr/src/app/ node bash /usr/src/app/ci.sh pipeline
    fi
    #check if Dockerfile present in current directory, if yes do "Docker build" else assume node image already present
    # start the node container
    # mount current directory to the container.
    # run pipeline function (this shell script) inside the container
    # terminate container
}

${1:-dockerBuildPipeline}
