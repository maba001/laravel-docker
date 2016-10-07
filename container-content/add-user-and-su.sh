#!/bin/bash

export USER_NAME="phon"
export USER_ID="1000"
export USER_HOME="/app"

# USER_NAME=$(stat --format=%U /app)
# USER_ID=$(stat --format=%u /app)

# create jira user
useradd -u ${USER_ID} --home-dir ${USER_HOME} --shell /bin/bash ${USER_NAME}

gosu ${USER} bash

