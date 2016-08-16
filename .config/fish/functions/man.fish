function man --description "Colored man pages"
    set -lx LESS_TERMCAP_md (tput bold; tput setaf 33)
    set -lx LESS_TERMCAP_me (tput sgr0)
    set -lx LESS_TERMCAP_so (tput bold; tput setab 127)
    set -lx LESS_TERMCAP_se (tput sgr0)
    set -lx LESS_TERMCAP_us (tput smul; tput bold; tput setaf 40)
    set -lx LESS_TERMCAP_ue (tput sgr0)
    command man "$argv"
end

