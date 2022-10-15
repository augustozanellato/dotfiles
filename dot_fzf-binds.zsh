# Key bindings

if [[ $- == *i* ]]; then

__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fselhome() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L ${HOME} -mindepth 1 | cut -d'/' -f4-"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fselall() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L / -mindepth 1 \\( -path '.' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fasdseld() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command fasd -Rdl"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fasdself() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command fasd -Rfl"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fasdsela() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command fasd -Ral"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzf_use_tmux__() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ]
}

__fzfcmd() {
  __fzf_use_tmux__ &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-file-widget
bindkey '^E' fzf-file-widget

fzf-file-widget-home() {
  tFFWH=$(__fselhome)
  if [[ -z "$tFFWH" ]]; then
    LBUFFER="${LBUFFER}${tFFWH}"
  else
    tFFWH2=`echo "$tFFWH" | sed -r "s/[[:space:]]*$//" | sed -r "s_^|([^\] )_\1~/_g"`
    LBUFFER="${LBUFFER}${tFFWH2}"
  fi
#  LBUFFER="${LBUFFER}$(__fselhome)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-file-widget-home
bindkey '^F' fzf-file-widget-home

fzf-file-widget-all() {
  LBUFFER="${LBUFFER}$(__fselall)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-file-widget-all
bindkey '^G' fzf-file-widget-all

fzf-fasd-widget-d() {
  LBUFFER="${LBUFFER}$(__fasdseld)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-fasd-widget-d
bindkey '^Q' fzf-fasd-widget-d

fzf-fasd-widget-f() {
  LBUFFER="${LBUFFER}$(__fasdself)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-fasd-widget-f
bindkey '^W' fzf-fasd-widget-f

fzf-fasd-widget-a() {
  LBUFFER="${LBUFFER}$(__fasdsela)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-fasd-widget-a
bindkey '^A' fzf-fasd-widget-a

# Ensure precmds are run after cd
fzf-redraw-prompt() {
  local precmd
  for precmd in $precmd_functions; do
    $precmd
  done
  zle reset-prompt
}
zle -N fzf-redraw-prompt

# Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
  selected=( $(fc -rl 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-t:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^T' fzf-history-widget

fi
