#!/bin/bash
# start_agent.sh
# 2017, Stein Arne Storslett
# Run: . start_agent.sh
# Start an ssh-agent if the required environment variable is missing or empty
[[ $- =~ i ]] || { echo -e "Start the agent in the current shell\n. start_agent.sh" ; exit 1 ; }
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent`
  ssh-add
  echo "export SSH_AUTH_SOCK=\"${SSH_AUTH_SOCK}\""
  echo "export SSH_AGENT_PID=\"${SSH_AGENT_PID}"
else
  echo "ssh-agent environment variables found"
  echo "export SSH_AUTH_SOCK=\"${SSH_AUTH_SOCK}\""
  echo "export SSH_AGENT_PID=\"${SSH_AGENT_PID}"
fi
