#!/bin/bash

#
# functions
download(){
    git clone --depth=1 $2 ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/$1/$3
}

# install zsh
if $(which apt &>/dev/null); then
    if [[ $(which sudo) = '' ]]; then
        echo "sudo not found, installing..."
        apt update
        apt install sudo -y
    fi
    sudo apt update
    if [[ $(which zsh) = '' ]]; then
        echo "zsh not found, installing..."
        sudo apt install zsh -y
    fi
    if [[ $(which git) = '' ]]; then
        echo "git not found, installing..."
        sudo apt install git -y
    fi
    # if [[ ! -f /usr/bin/composer ]]; then
    #     echo "composer not found, installing..."
    #     sudo apt install composer -y
    # fi
    if [[ $(which make) = '' ]]; then
        echo "make not found, installing..."
        sudo apt install make -y
    fi
fi

#
# install oh my zsh
echo "Installing oh my zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

#
# download plugins
echo "Downloading zsh plugins..."
download plugins https://gitlab.com/carcheky/zsh_carcheky zsh_carcheky
download plugins https://github.com/agkozak/zsh-z zsh-z
download plugins https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
download plugins https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting
download plugins https://github.com/TamCore/autoupdate-oh-my-zsh-plugins autoupdate
#
# download theme
echo "Downloading zsh theme..."
download themes https://github.com/romkatv/powerlevel10k.git powerlevel10k

#
# customize
echo "Customizing..."
echo '
# START customized settings
plugins=(git zsh_carcheky autoupdate ubuntu docker zsh-z zsh-autosuggestions zsh-syntax-highlighting)
zstyle ":omz:update" mode auto
zstyle ":omz:update" frequency 1
export UPDATE_ZSH_DAYS=1
ZSH_THEME="powerlevel10k/powerlevel10k"
HIST_STAMPS="dd/mm/yyyy"
DISABLE_UNTRACKED_FILES_DIRTY="true"
COMPLETION_WAITING_DOTS="true"
export PATH=$HOME/bin:/usr/local/bin:$PATH
alias ohmyzsh="code  $HOME/.oh-my-zsh"
alias zshconfig="code  $HOME/.zshrc"
source $ZSH/oh-my-zsh.sh
[[ ! -f  $HOME/MISALIAS ]] || source  $HOME/MISALIAS
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# END customized settings
echo "[✔ loaded ¯\_(ツ)_/¯]"
' >> $HOME/.zshrc

# add MISALIAS
if [[ ! -f  $HOME/MISALIAS ]];
then
echo "Creating MISALIAS..."
echo "
#!/bin/bash
# CUSTOM aliases
alias misalias='code ~/MISALIAS'
"  >> $HOME/MISALIAS
fi

# set zsh default
echo "Setting zsh as default shell..."
sudo usermod --shell /usr/bin/zsh $USER
echo "PLEASE REBOOT"
