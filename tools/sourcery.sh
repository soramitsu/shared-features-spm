SOURCERY="sourcery-2.1.3"

if [[ -z "${JENKINS_HOME}" ]]; then
    PROJECT_DIR="${WORKSPACE_PATH}/../../.."
else
    PROJECT_DIR="${WORKSPACE_PATH}/"
fi

"${PROJECT_DIR}/tools/${SOURCERY}/bin/sourcery" --config "${PROJECT_DIR}/tools/sourcery.yml" --verbose
