#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

BOLD='\033[1m'
ITALIC='\033[3m'
NORMAL="\033[0m"

color_print() {
  if [ -t 1 ]; then
    echo -e "$@$NORMAL"
  else
    echo "$@" | sed "s/\\\033\[[0-9;]*m//g"
  fi
}

stderr_print() {
  color_print "$@" >&2
}

warn() {
  stderr_print "$YELLOW$1"
}

error() {
  stderr_print "$RED$1"
  exit 1
}

info() {
  color_print "$CYAN$1"
}

ok() {
  color_print "$GREEN$1"
}

program_exists() {
  command -v $1 &> /dev/null
}

# modify
REPO=p10k-setup

ACTUAL_DIR=`pwd`
USERNAME=`whoami`

# Installing p10k
p10k_user() {
    info "Installing p10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

}

p10k_root() {
    sudo su

    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

    ln -sfv $HOME/.p10k.zsh /root/.p10k.zsh
    ln -sfv $HOME/.zshrc /root/.zshrc

    usermod --shell /usr/bin/zsh root
    usermod --shell /usr/bin/zsh $USERNAME
}

# Linking dotfiles
user_config() {
    info "Setting up..."

    su $USERNAME

    ln -sfv $HOME/$REPO/.zshrc $HOME/.zshrc
    ln -sfv $HOME/$REPO/.p10k.zsh $HOME/.p10k.zsh
}

useful_apps() {
    info "Installing usefull plugins/apps..."

    sudo apt update
    sudo apt install scrub

    # zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

    # zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

    # zsh-autocomplete
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh/zsh-autocomplete

    # sudo plugin
    cd $HOME/.zsh/
    wget https://raw.githubusercontent.com/triplepointfive/oh-my-zsh/master/plugins/sudo/sudo.plugin.zsh
    cd $ACTUAL_DIR

    # bat (cat with wings)
    sudo apt install bat

    # lsd
    wget https://github.com/Peltoche/lsd/releases/download/0.21.0/lsd_0.21.0_amd64.deb
    sudo dpkg -i lsd_0.21.0_amd64.deb
    rm -rf lsd_0.21.0_amd64.deb

    # fzf (fuzzy finder)
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
}

shell_setup() {
    p10k_user
    p10k_root
    shell_config
    useful_apps
}

main() {
    if [ ! -d $TEMP_DIR ]; then
        mkdir $TEMP_DIR
    fi

    if [ ! -d $CONFIG_DIR ]; then
        mkdir $CONFIG_DIR
    fi

    ok "Welcome to @hugoogb $REPO!!!"
    info "Starting process..."

    sleep 0.8

    shell_setup
}

main

cd $ACTUAL_DIR

ok "$REPO done!!!"
warn "WARNING: don't forget to reboot in order to get everything working properly"