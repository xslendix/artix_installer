set fish_greeting ""

set QT_SCALE_FACTOR_ROUNDING_POLICY Round

set -gx PATH $HOME/.cargo/bin /mnt/sdb1/Code/sh/ $PATH

set -gx WEECHAT_HOME "$XDG_CONFIG_HOME"/weechat

set -gx EDITOR nvim
set -gx VISUAL nvim

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export LESSHISTFILE="-"
export WGETRC="$HOME/.config/wget/wgetrc"
export INPUTRC="$HOME/.config/inputrc"

alias f="ranger ./"
alias weechat="weechat -d /home/blyat/.config/weechat"
alias ms="vlc ~/Music/"
alias yd="youtube-dl"
alias ydm="youtube-dl -f 140"
alias l="ls -lh"

printf '\033[?1h\033=' >/dev/tty
tput smkx
