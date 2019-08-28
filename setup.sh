#!/bin/bash
mkdir -p ~/.vim

if [ ! -x "$(command -v git)" ]; then
  sudo apt-get -y install git
  git config --global user.email "strangesast@gmail.com"
  git config --global user.name "Sam Zagrobelny"
fi

read -p "Install typical apt stuff? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sudo apt-get install -y tree \
    silversearcher-ag
fi

if [ ! -x "$(command -v go)" ]; then
  read -p "Install go? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    wget https://dl.google.com/go/go1.12.9.linux-amd64.tar.gz -P /tmp
    sudo tar -C /usr/local -xzf /tmp/go1.12.9.linux-amd64.tar.gz
    echo "export PATH=$PATH:/usr/local/go/bin" | sudo tee -a /etc/profile
  fi
fi

mkdir -p ~/Projects

read -p "Install vim? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  {
    sudo apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
      libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
      libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
      python3-dev ruby-dev lua5.1 liblua5.1-dev libperl-dev

    sudo apt-get remove -y vim vim-tiny vim-common vim-gui-common vim-nox
    sudo apt-get autoremove -y
    
    mkdir -p ~/src/github.com/vim
    git clone https://github.com/vim/vim.git /tmp/vim --depth=1
    cd /tmp/vim
    git checkout $(git describe --tags $(git rev-list --tags --max-count=1)) 
    ./configure --with-features=huge \
      --enable-multibyte \
      --enable-rubyinterp=yes \
      --enable-pythoninterp=yes \
      --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
      --enable-python3interp=yes \
      --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
      --enable-perlinterp=yes \
      --enable-luainterp=yes \
      --enable-gui=gtk2 \
      --enable-cscope \
      --prefix=/usr/local

    make
    sudo make install
  } || {
    echo `vim install failed`
  }
  cd
fi

if [ ! -d "$HOME/Projects/dotfiles" ]; then
  {
    cd ~/Projects
    git clone https://github.com/strangesast/dotfiles.git
    cd dotfiles
    ln -s vimrc ~/.vimrc
  } || {
    echo `dotfiles setup failed`
  }
fi

if [ ! -x "$(command -v npm)" ]; then
  {
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install -g npm
    sudo npm install -g typescript
  } || {
    echo `nodejs install failed`
  }
fi

if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
  if [ -d "$HOME/.vim/bundle/YouCompleteMe" ]; then
    sudo apt-get install -y build-essential cmake
    cd ~/.vim/bundle/YouCompleteMe
    ./install.py --clang-completer --js-completer
    cd
  fi
fi

read -p "Install docker? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  {
    sudo apt-get remove -y docker docker-engine docker.io
    sudo apt-get install -y \
       apt-transport-https \
       ca-certificates \
       curl \
       gnupg2 \
       software-properties-common
  
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  
    sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/debian \
     $(lsb_release -cs) \
     stable"
  
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo usermod -aG docker $USER
    docker run hello-world
  } || {
    echo `docker install failed`
  }
fi

read -p "Install java? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  {
    sudo apt-get install -y default-jre
    sudo apt-get install -y default-jdk
  } || {
    echo `java install failed`
  }
fi
