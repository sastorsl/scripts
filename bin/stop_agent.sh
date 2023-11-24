#!/bin/bash
# stop_agent.sh
# 2017, Stein Arne Storslett
# Run: . stop_agent.sh
# Stop any ssh-agent process owned by user
[[ $- =~ i ]] || { echo -e "Stop the agent in the current shell\n. stop_agent.sh" ; exit 1 ; }
killall -v ssh-agent
echo unset SSH_AUTH_SOCK SSH_AGENT_PID
unset SSH_AUTH_SOCK SSH_AGENT_PID
