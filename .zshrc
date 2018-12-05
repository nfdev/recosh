# command_not_found
. /etc/zsh_command_not_found

# history
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY


#RECOSH
RECOBASE=~/.recosh

function init_recosh(){
  mkdir -p ${RECOBASE}
  # TODO
}


function preexec_function() {
}

function precmd_function() {
  if [ -z "$RCODE" ]; then
    RCODE=$?
  fi
  if [ -z "$RCMD" ]; then
    RCMD=`history -1 | awk '{$1=""; print $0}' | sed -e 's/^ *//'`
  fi
  if [ -z "$RPWD" ]; then
    RPWD="$PWD"
  fi
  if [ -z "$RDATE" ]; then
    RDATE=`date`
  fi
  RECOSH=${RECODIR}/`date +%s%N`

  if [ -e "${RECOSH}" ]; then
    return 1
  fi
  mkdir -p "${RECOSH}"

  echo "$RPWD" > ${RECOSH}/pwd
  echo "$RCMD" > ${RECOSH}/cmd
  echo "$RDATE" > ${RECOSH}/date
  echo "$RSTDOUT" > ${RECOSH}/stdout
  echo "$RCODE" > ${RECOSH}/rcode

  unset RPWD
  unset RCMD
  unset RDATE
  unset RSTDOUT
  unset RCODE
}

function zshexit_function(){
  echo ${RECOBASE}
  cd ${RECOBASE}
  git add ./*
  git commit -m "$(date)"
  git push -u origin master
}

function reco(){
  RCODE=$?
  RCMD="$@"
  RSTDOUT=`exec $@`
  RDATE=`date`
  echo "${RSTDOUT}"
}

RECODIR=${RECOBASE}/`date +%s%N`$$
mkdir -p ${RECODIR}

autoload -Uz add-zsh-hook
add-zsh-hook preexec preexec_function
add-zsh-hook precmd precmd_function
add-zsh-hook zshexit zshexit_function
