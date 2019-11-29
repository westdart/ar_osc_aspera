#!/bin/bash

# Required files:
# ${SEED_DIR}/${USERNAME}
# ${SEED_DIR}/aspera_id_rsa
# ${SEED_DIR}/aspera_id_rsa.pub
# ${SEED_DIR}/sshd_config

USERNAME=aspera
ASPERA_TYPE=$(cat /aspera-type)
SEED_DIR=/mnt/aspera/seed
SSHD_PID=

if [[ "${ASPERA_TYPE}" == "HSTE" ]]; then
    FT_BASEDIR=/mjdi/local/GFT
elif [[ "${ASPERA_TYPE}" == "HSTS" ]]; then
    FT_BASEDIR=/desbs/stg
else
    echo "Unsupported Aspera container type: '${ASPERA_TYPE}'"
    exit 1
fi

function ensureUser()
{
    if ! whoami &> /dev/null; then
      if [ -w /etc/passwd ]; then
        echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
      fi
    fi
}

function createDirectories()
{
    mkdir -p ${FT_BASEDIR}/in && \
    mkdir -p ${FT_BASEDIR}/out && \
    mkdir -p ${FT_BASEDIR}/archive && \
    mkdir -p /opt/aspera/etc
    chmod 770 ${FT_BASEDIR}/*
    chmod 770 /opt/aspera/etc
}

function startSshd()
{
    [[ -f /home/${USERNAME}/.ssh/ssh_host_rsa_key ]] || ssh-keygen -f /home/${USERNAME}/.ssh/ssh_host_rsa_key -N '' -t rsa
    [[ -f /home/${USERNAME}/.ssh/ssh_host_ecdsa_key ]] || ssh-keygen -f /home/${USERNAME}/.ssh/ssh_host_ecdsa_key -N '' -t ecdsa
    [[ -f /home/${USERNAME}/.ssh/ssh_host_ed25519_key ]] || ssh-keygen -f /home/${USERNAME}/.ssh/ssh_host_ed25519_key -N '' -t ed25519
    /usr/sbin/sshd -f /home/${USERNAME}/sshd_config -E /home/${USERNAME}/sshdLog || return 1
    SSHD_PID=$!
}

function copyFiles()
{
    cp ${SEED_DIR}/sshd_config /home/${USERNAME}/sshd_config
    cp ${SEED_DIR}/aspera-license /opt/aspera/etc/aspera-license
    cp ${SEED_DIR}/aspera.conf /opt/aspera/etc/aspera.conf
}

function initAspera()
{
    if [[ ! -f /opt/aspera/bin/asuserdata ]]
    then
        echo "WARN: Aspera not present - failed to initialise Aspera"
    else
        /opt/aspera/bin/asuserdata -v
    fi
}

function copyAuthorizedKeys()
{
    cp ${SEED_DIR}/aspera_id_rsa.pub /home/${USERNAME}/.ssh/authorized_keys && \
    chown -R ${USERNAME}:root /home/${USERNAME}/.ssh/authorized_keys && \
    chmod 600 /home/${USERNAME}/.ssh/authorized_keys
}

function runAspera()
{
    if [[ ! -d /opt/aspera/sbin ]]
    then
        echo "WARN: Aspera not present - failed to run Aspera"
    else
        /opt/aspera/sbin/asperacentral || { echo "Failed to execute /opt/aspera/sbin/asperacentral"; return 1; }
        /opt/aspera/sbin/asperanoded   || { echo "Failed to execute /opt/aspera/sbin/asperanoded"; return 1; }
        sleep 10
    fi
}

function seedAspera()
{
    if [[ ! -d /opt/aspera/sbin ]]
    then
        echo "WARN: Aspera not present - failed to seed Aspera"
    else
        /opt/aspera/bin/asnodeadmin -a -u asperaNodeUser -p Password123 -x ${USERNAME}
        sleep 10

        if [[ "${ASPERA_TYPE}" == "HSTE" ]]; then
            curl -ki -u asperaNodeUser:Password123 -X POST https://localhost:9092/access_keys -d '{"id":"MjdiDeployed","secret":"/mjdi/local/GFT","storage":{"type":"local","path":"/mjdi/local/GFT"}}'
        elif [[ "${ASPERA_TYPE}" == "HSTS" ]]; then
            curl -ki -u asperaNodeUser:Password123 -X POST https://localhost:9092/access_keys -d '{"id":"MjdiCentral","secret":"/desbs/stg","storage":{"type":"local","path":"/desbs/stg"}}'
        else
            echo "Unsupported Aspera container type (cannot seed): '${ASPERA_TYPE}'"
        fi
    fi
}

function errorExit()
{
    echo "$@"
    exit 1
}

trap "errorExit 'Received signal SIGHUP'" SIGHUP
trap "errorExit 'Received signal SIGINT'" SIGINT
trap "errorExit 'Received signal SIGTERM'" SIGTERM

ensureUser        || exit 1
createDirectories || exit 1
copyFiles         || exit 1
initAspera        || exit 1
startSshd         || exit 1
runAspera         || exit 1
seedAspera        || exit 1

while true ; do nc -l -p 8443 -c 'echo -e "HTTP/1.1 200 OK\n\n $(date)"'; done
