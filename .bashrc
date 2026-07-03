#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias git_graph='git log --all --graph --decorate'

PS1='[\u@\h \W]\$ '

source /usr/share/nvm/init-nvm.sh

if [ -f "$HOME/.secret-token" ]; then
  source "$HOME/.secret-token"
fi

export GO_INSTALL="$HOME/.go"
export GOPATH="$HOME/go"
export BUN_INSTALL="$HOME/.bun"
export LOCALSTACK_INSTALL="$HOME/.localstack"
export FLAME_INSTALL="$HOME/.flamegraph"
export ZIP_DIR="$HOME/Playground/SnapShot"
export MKCERT="$HOME/.mkcert"

export PATH="$GO_INSTALL/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="$ZIP_DIR/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$FLAME_INSTALL:$PATH"
export PATH="$MKCERT:$PATH"
export PATH="$LOCALSTACK_INSTALL:$PATH"

mkcdir() {
  mkdir -p "$1" && cd "$1"
}
