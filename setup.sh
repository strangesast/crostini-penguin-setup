#!/bin/bash
mkdir -p ~/.vim
sudo apt-get install git

mkdir -p ~/Projects

if [ ! -d "$HOME/Projects/vim" ]; then
  sudo apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
    python3-dev ruby-dev lua5.1 liblua5.1-dev libperl-dev

  sudo apt-get remove -y vim vim-tiny vim-common vim-gui-common vim-nox
  sudo apt-get autoremove -y
  
  git clone https://github.com/vim/vim.git ~/Projects/vim --depth=1
  cd ~/Projects/vim
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
fi


if [ ! -d "$HOME/Projects/dotfiles" ]; then
  git clone https://github.com/strangesast/dotfiles.git Projects/dotfiles
  ln -s ~/Projects/dotfiles/vimrc ~/.vimrc
fi

if [ ! -x "$(command -v npm)" ]; then
  curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
  if [ -d "$HOME/.vim/bundle/YouCompleteMe" ]; then
    sudo apt-get install build-essential cmake
    cd ~/.vim/bundle/YouCompleteMe
    ./install.py --clang-completer --
  fi
fi

cd
