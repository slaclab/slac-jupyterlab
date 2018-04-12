#!/bin/bash
PYTHON_VER=$1
CONFIG_FILE=$2
if [ -e ${HOME}/notebooks/.user_setups ]; then
    source ${HOME}/notebooks/.user_setups
fi
exec python${PYTHON_VER} -m ipykernel -f ${CONFIG_FILE}
