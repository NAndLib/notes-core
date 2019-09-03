# Enables bash completion for the available notes commands.

COMMANDS=$(cat<<EOF | sort
help
-h
--help
list
ls
open
edit
git
make
EOF
)

# Gets the completion for the given string starting with a command.
# Author: Brian Beffa <brbsix@gmail.com>
# Original source:
# https://brbsix.github.io/2015/11/29/accessing-tab-completion-programmatically-in-bash/
# License: LGPLv3 (http://www.gnu.org/licenses/lgpl-3.0.txt)
__notes_get_completions() {
  local completion COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMPREPLY=()

  # load bash-completion if necessary
  declare -F _completion_loader &>/dev/null || {
      source /usr/share/bash-completion/bash_completion
  }

  COMP_LINE=$*
  COMP_POINT=${#COMP_LINE}

  eval set -- "$@"

  COMP_WORDS=("$@")

  # add '' to COMP_WORDS if the last character of the command line is a space
  [[ "${COMP_LINE[@]: -1}" = ' ' ]] && COMP_WORDS+=('')

  # index of the last word
  COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

  # determine completion function
  completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')

  # run _completion_loader only if necessary
  if [[ -z $completion ]]; then
    # load completion
    _completion_loader "$1"
    # detect completion
    completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')
  fi

  # ensure completion was detected
  [[ -n $completion ]] || return 1

  # execute completion function
  "$completion"

  # print completions to stdout
  printf '%s\n' "${COMPREPLY[@]}" | LC_ALL=C sort
}

__notes_completion() {
  if [[ ${#COMP_WORDS[@]} -le 2 ]]; then
    COMPREPLY=($(compgen -W "$COMMANDS" "${COMP_WORDS[1]}"))
  else
    case ${COMP_WORDS[1]} in
      make|git)
        COMPREPLY=($(__notes_get_completions "${COMP_WORDS[@]:1}"))
        ;;
      edit)
        ;;
      *)
        COMPREPLY=($(compgen -W "$COMMANDS" "${COMP_WORDS[1]}"))
    esac
  fi
}

complete -F __notes_completion notes
