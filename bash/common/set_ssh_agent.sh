if ! pgrep -u $USER ssh-agent > /dev/null; then
    ssh-agent > ${MYBASHRC_SSH_AGENT_PATH}
    echo "ssh-agent started"
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval $(<${MYBASHRC_SSH_AGENT_PATH}) > /dev/null
fi
