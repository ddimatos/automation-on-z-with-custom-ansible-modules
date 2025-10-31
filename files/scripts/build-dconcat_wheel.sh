#!/bin/sh

ENV_SOURCE_FILE="../../.env"
export SEP_LINE="-------------------------------------------------------------------------------"
export SEP_LINE_NL="\n-------------------------------------------------------------------------------\n"


# ---------------------------------------------------------------------
# Sourcing the setup file to setup and teardown the demo script
# ---------------------------------------------------------------------

if [ -f "$ENV_SOURCE_FILE" ]; then
  echo "${SEP_LINE_NL}[INFO] Sourcing $ENV_SOURCE_FILE${SEP_LINE_NL}"
  source "$ENV_SOURCE_FILE"
else
  echo "${SEP_LINE_NL}[WARN] There is no environment file $ENV_SOURCE_FILE,
  please be sure to configure script variables'USER', 'HOST' and \
  'MY_ANSIBLE_LIBRARY' in this script${SEP_LINE_NL}"
fi

export USER=${MY_USER:="ibmuser"}
export HOST=${MY_HOST:="hostname"}


# ---------------------------------------------------------------------
# Export environment variables
# ---------------------------------------------------------------------
export WHEEL_DIR="wheel"

# ---------------------------------------------------------------------
# Copy local file content to UNIX System Services files
# ---------------------------------------------------------------------
echo "Copying python source file dconcat.py to USS"
scp -O -r ../../python/${WHEEL_DIR} ${USER}@${HOST}:/tmp/${WHEEL_DIR}

# ---------------------------------------------------------------------
# Running dconcat
# ---------------------------------------------------------------------

echo "${SEP_LINE_NL}Building and installing 'dconcat' wheel on managed z/OS.${SEP_LINE_NL}"
SSH_OUTPUT=$(ssh -q ${USER}@${HOST} ". ./.profile; \
mkdir -p /tmp/lib; \
python3 -m pip install --no-input --upgrade build --target /tmp/lib; \
cd /tmp/wheel; \
python3 -m build; \
pip install /tmp/wheel/dist/dconcat_module-0.0.1-py3-none-any.whl --target /tmp/lib; \
cd /tmp; \
rm -rf ${WHEEL_DIR};")
echo "${SSH_OUTPUT}"
