#
# kubernetes / k8s prompt
#
if [ -f ~/git/github.com/clones/kube-ps1/kube-ps1.sh ]
then
    source ~/git/github.com/clones/kube-ps1/kube-ps1.sh 
    # Add "kube_ps1" to the system generated PS1
    case "$PS1" in
        *kube_ps1*) : ;;
        *)  export oPS1=$PS1
            export PS1='$(kube_ps1)'$PS1
            ;;
    esac
fi

#
# https://krew.sigs.k8s.io/
#
case "$PATH" in
    *.krew/bin*) : ;;
    *) export PATH=$PATH:~/.krew/bin ;;
esac

#
# Short handle for kubectl, etc
#
alias k='kubectl'
alias ke='kubens'
alias kx='kubectx'
alias klogs='kubectl logs --timestamps=true'
alias cert-manager='kubectl cert-manager'

function kresources () {
  # Get resource requests and limits for all containers in all pods in a namespace
  # Usage: kresources [<project_name>]
  # Props to steffenlongva/zsh-stuff
  local project_name=$1
  test -n "${project_name}" && local namespace="--namespace=${project_name}" || local namespace=""
  which oc >/dev/null && local cmd=oc || local cmd=kubectl
  ${cmd} get pods $namespace -o custom-columns="STATE:.status.phase,NAME:.metadata.name,CPU_REQ:.spec.containers[*].resources.requests.cpu,CPU_LIMIT:.spec.containers[*].resources.limits.cpu,MEM_REQ:.spec.containers[*].resources.requests.memory,MEM_LIMIT:.spec.containers[*].resources.limits.memory"
}

function get_oc_token_keys () {
  jq -r '.tokens | keys[]' ~/.ao-session.json
}

function get_oc_token () {
  if [ $# -ne 1 ]
  then
    echo "usage: $funcstack[1] <kubernetes-context>"
    return
  fi
  local RET=$(jq -r ".tokens.\"${1}\"" ~/.ao-session.json)
  if [ "$RET" != "null" ]
  then
    echo "$RET"
  else
    echo "ERROR getting token for context ${1}"
    return 1
  fi
}

function do-login-all-oc () {
  for OC_CONTEXT in $(get_oc_token_keys)
  do
    do-login-oc-${OC_CONTEXT}
  done
}

function get-k8s-context () {
    if [ $# -ne 1 ]
    then
        echo "usage: $funcstack[1] <kubernetes-context>"
        return
    fi
    local contexts=$(kubectx)
    local OPENSHIFT_CONTEXT_DOMAIN=$(cat $HOME/.openshift_domain | sed 's/\./-/g')
    local OPENSHIFT_USER=$(cat $HOME/.openshift_user)
    for context in $contexts
    do
        echo "$context" | grep -E "^[^/]+/api-${1}-${OPENSHIFT_CONTEXT_DOMAIN}:6443/${OPENSHIFT_USER}$"
    done
}

if [ -f $HOME/.openshift_domain ]
then
    OPENSHIFT_DOMAIN=$(cat $HOME/.openshift_domain)
    OPENSHIFT_CONTEXT_DOMAIN=$(cat $HOME/.openshift_domain | sed 's/\./-/g')
    if [ -f $HOME/.openshift_user ]
    then
        OPENSHIFT_USER=$(cat $HOME/.openshift_user)
        for OC_CONTEXT in $(get_oc_token_keys)
        do
            unalias oc-${OC_CONTEXT} 2>/dev/null
            source /dev/stdin <<EOF
            function oc-${OC_CONTEXT} () {
              oc \$@ --context=$(get-k8s-context ${OC_CONTEXT} | head -1)
            }
EOF
            source /dev/stdin <<EOF
            function do-login-oc-${OC_CONTEXT} () {
              oc login --server https://api.${OC_CONTEXT}.${OPENSHIFT_DOMAIN}:6443 --token=$(get_oc_token ${OC_CONTEXT})
            }
EOF
            # FIXME completions
        done
    else
        echo "Add your email-address to $HOME/.openshift_user to get oc-<env> funtions, e.g. 'user.name@organization.com'"
    fi
else echo "Add the _domain_ part to $HOME/.openshift_domain to get oc-<env> funtions, e.g. 'hostname.com'"
fi
