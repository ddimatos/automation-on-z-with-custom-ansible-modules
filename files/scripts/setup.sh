#!/bin/sh

ENV_SOURCE_FILE="../../.env"
export SEP_LINE="\\\n-------------------------------------------------------------------------------\\\n"
export SEP_LINE_NL="\n-------------------------------------------------------------------------------\n"
# ---------------------------------------------------------------------
# Place your secrets in a '.env' file in project root for auto sourcing
# ---------------------------------------------------------------------

if [ -f "$ENV_SOURCE_FILE" ]; then
  echo "${SEP_LINE_NL}[INFO] Sourcing $ENV_SOURCE_FILE${SEP_LINE_NL}"
  source "$ENV_SOURCE_FILE"
else
  echo "${SEP_LINE_NL}[WARN] There is no environment file $ENV_SOURCE_FILE,
  please be sure to configure script variables'USER', 'HOST' and \
  'MY_ANSIBLE_LIBRARY' in this script${SEP_LINE_NL}"
fi

# ---------------------------------------------------------------------
# Export environment variables
# ---------------------------------------------------------------------
export USER=${MY_USER:="ibmuser"}
export HOST=${MY_HOST:="hostname"}
export SRC_EMP_FILE_NAME="employee.source.seq"
export ADD_EMP_FILE_NAME="employee.added.seq"
export NEW_EMP_FILE_NAME="employee.all.seq"
export TMP_FILE=/tmp/tmp.txt

# ---------------------------------------------------------------------
# Copy local file content to UNIX System Services files
# ---------------------------------------------------------------------
echo "${SEP_LINE_NL}[INFO] Copying data employee data to z/OS${SEP_LINE_NL}"
tail -n +3 ../data/${SRC_EMP_FILE_NAME} > ${TMP_FILE}
scp -O ${TMP_FILE} ${USER}@${HOST}:/tmp/${SRC_EMP_FILE_NAME}
rm -rf ${TMP_FILE}
tail -n +3 ../data/${ADD_EMP_FILE_NAME} > ${TMP_FILE}
scp -O ${TMP_FILE} ${USER}@${HOST}:/tmp/${ADD_EMP_FILE_NAME}
rm -rf ${TMP_FILE}

# ---------------------------------------------------------------------
# Copy a templated ssh '.profile' to be used by the script
# ---------------------------------------------------------------------
echo "${SEP_LINE_NL}[INFO] Copying profile to UNIX System Services${SEP_LINE_NL}"
scp -O ../data/profile ${USER}@${HOST}:/.profile

# ---------------------------------------------------------------------
# Create and populated z/OS datasets
# ---------------------------------------------------------------------
SSH_OUTPUT=$(ssh -q ${USER}@${HOST} ". ./.profile; \
echo "${SEP_LINE}[INFO] Remove pre-existing datasets"
drm -f ${SRC_EMP_FILE_NAME} > /dev/null 2>&1; \
if [ \$? -eq 0 ]; then echo "[SUCCESS] drm -f ${SRC_EMP_FILE_NAME} executed successfully.${SEP_LINE}"; else echo "[ERROR] drm -f ${SRC_EMP_FILE_NAME} failed${SEP_LINE}"; fi; \

echo "${SEP_LINE}[INFO] Remove pre-existing datasets"
drm -f ${ADD_EMP_FILE_NAME}> /dev/null 2>&1; \
if [ \$? -eq 0 ]; then echo "[SUCCESS] drm -f ${ADD_EMP_FILE_NAME} executed successfully.${SEP_LINE}"; else echo "[ERROR] drm -f ${ADD_EMP_FILE_NAME} failed.${SEP_LINE}"; fi; \

echo "${SEP_LINE}[INFO] Remove any pre-existing datasets"
drm -f ${NEW_EMP_FILE_NAME}> /dev/null 2>&1; \
if [ \$? -eq 0 ]; then echo "[SUCCESS] drm -f ${NEW_EMP_FILE_NAME} executed successfully.${SEP_LINE}"; else echo "[ERROR] drm -f ${NEW_EMP_FILE_NAME} failed.${SEP_LINE}"; fi; \

echo "${SEP_LINE}[INFO] Create empty sequential dataset"
dtouch -tseq ${SRC_EMP_FILE_NAME}; \
if [ \$? -eq 0 ]; then echo "[SUCCESS] dtouch -tseq ${SRC_EMP_FILE_NAME} executed successfully.${SEP_LINE}"; else echo "[ERROR] dtouch -tseq ${SRC_EMP_FILE_NAME} failed.${SEP_LINE}"; fi; \

echo "${SEP_LINE}[INFO] Create empty sequential dataset"
dtouch -tseq ${ADD_EMP_FILE_NAME}; \
if [ \$? -eq 0 ]; then echo "[SUCCESS] dtouch -tseq ${ADD_EMP_FILE_NAME} executed successfully.${SEP_LINE}"; else echo "[ERROR] dtouch -tseq ${ADD_EMP_FILE_NAME} failed.${SEP_LINE}"; fi; \

echo "${SEP_LINE}[INFO] Create empty sequential dataset"
dtouch -tseq ${NEW_EMP_FILE_NAME}; \
if [ \$? -eq 0 ]; then echo "[SUCCESS] dtouch -tseq ${NEW_EMP_FILE_NAME} executed successfully.${SEP_LINE}"; else echo "[ERROR] dtouch -tseq ${NEW_EMP_FILE_NAME} failed.${SEP_LINE}"; fi; \

echo "${SEP_LINE}[INFO] Copy text source into dataset"
dcp /tmp/${SRC_EMP_FILE_NAME} ${SRC_EMP_FILE_NAME}; \
if [ \$? -eq 0 ]; then echo "[SUCCESS] dcp /tmp/${SRC_EMP_FILE_NAME} ${SRC_EMP_FILE_NAME} executed successfully.${SEP_LINE}"; else echo "[ERROR] dcp /tmp/${SRC_EMP_FILE_NAME} ${SRC_EMP_FILE_NAME} failed.${SEP_LINE}"; fi; \

echo "${SEP_LINE}[INFO] Copy text source into dataset"
dcp /tmp/${ADD_EMP_FILE_NAME} ${ADD_EMP_FILE_NAME}; \
if [ \$? -eq 0 ]; then echo "[SUCCESS] dcp /tmp/${ADD_EMP_FILE_NAME} ${ADD_EMP_FILE_NAME} executed successfully.${SEP_LINE}"; else echo "[ERROR] dcp /tmp/${ADD_EMP_FILE_NAME} ${ADD_EMP_FILE_NAME} failed.${SEP_LINE}"; fi; \

echo "${SEP_LINE}[INFO] Clean up temporary files${SEP_LINE}"
rm -rf /tmp/${SRC_EMP_FILE_NAME} /tmp/${ADD_EMP_FILE_NAME};")

echo "${SSH_OUTPUT}"

# ---------------------------------------------------------------------
# Run the playbook with the custom module
# ---------------------------------------------------------------------


