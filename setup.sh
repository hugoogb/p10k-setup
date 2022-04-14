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

    if [ ! -d ~/powerlevel10k ]; then
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    else 
      warn "~/powerlevel10k already exists"
    fi
}

p10k_root() {
    if [ -d /root/powerlevel10k ]; then
      warn "/root/powerlevel10k already exists --> deleting it..."
      sudo rm -rf /root/powerlevel10k
    fi

    sudo ln -sfv $HOME/powerlevel10k /root/
    sudo ln -sfv $HOME/.p10k.zsh /root/.p10k.zsh
    sudo ln -sfv $HOME/.zshrc /root/.zshrc

    sudo usermod --shell /usr/bin/zsh root
    sudo usermod --shell /usr/bin/zsh $USERNAME
}

# Linking dotfiles
user_config() {
    info "Setting up..."

    ln -sfv $HOME/$REPO/.zshrc $HOME/.zshrc
    ln -sfv $HOME/$REPO/.p10k.zsh $HOME/.p10k.zsh
}

useful_apps() {
    info "Installing usefull plugins/apps..."

    # scrub (deleting files)
    sudo apt update
    sudo apt install scrub

    # zsh-autosuggestions
    if [ ! -d /usr/share/zsh-autosuggestions ]; then
      sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions
    else 
      warn "~/.zsh/zsh-autosuggestions already exists"
    fi

    # zsh-syntax-highlighting
    if [ ! -d /usr/share/zsh-syntax-highlighting ]; then
      sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting
    else 
      warn "~/.zsh/zsh-syntax-highlighting already exists"
    fi

    # zsh-autocomplete
    if [ ! -d /usr/share/zsh-autocomplete ]; then
      sudo git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git /usr/share/zsh-autocomplete
    else 
      warn "~/.zsh/zsh-autocomplete already exists"
    fi

    # sudo plugin
    if [ ! -f /usr/share/sudo.plugin.zsh ]; then
      cd /usr/share/
      sudo wget https://raw.githubusercontent.com/triplepointfive/oh-my-zsh/master/plugins/sudo/sudo.plugin.zsh
      cd $ACTUAL_DIR
    else 
      warn "~/.zsh/sudo.plugin.zsh already exists"
    fi

    # bat (cat with wings)
    if ! program_exists bat; then
      wget https://github.com/sharkdp/bat/releases/download/v0.20.0/bat_0.20.0_amd64.deb
      sudo dpkg -i bat_0.20.0_amd64.deb
      rm bat_0.20.0_amd64.deb
    else 
      warn "bat already exists"
    fi

    # lsd
    if ! program_exists lsd; then
      wget https://github.com/Peltoche/lsd/releases/download/0.21.0/lsd_0.21.0_amd64.deb
      sudo dpkg -i lsd_0.21.0_amd64.deb
      rm lsd_0.21.0_amd64.deb
    else 
      warn "lsd already exists"
    fi

    # fzf (fuzzy finder)
    if [ ! -d ~/.fzf ]; then
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      ~/.fzf/install
    else
      warn "~/.fzf already exists"
    fi
}

shell_setup() {
    p10k_user
    p10k_root
    user_config
    useful_apps
}

main() {
    ok "Welcome to @hugoogb $REPO!!!"
    info "Starting process..."

    sleep 0.8

    shell_setup
}

main

cd $ACTUAL_DIR

ok "$REPO done!!!"
warn "WARNING: don't forget to reboot in order to get everything working properly"