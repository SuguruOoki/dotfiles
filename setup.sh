 #!/bin/bash


#Homebrewをinstall

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# TODO: brewfileをとりあえず使っているが、ツール的に検討を行っていないので、よければ、他のものを使用してみる
# brew fileをinstall
brew install 
# brew fileのリポジトリを設定
brew set_repo git@github.com:SuguruOoki/brew-file-backup.git

# brewfileの内容をinstall
# brew caskの中身をinstall
brew file install;

# この辺は現在のPCでは入れていないが、cask管理下におきたいアプリ群
# TODO: 次のPCに変わった時やこのsetupを走らせてcask管理下置かれた場合はここから外す。
brew cask install google-chrome;
brew cask install sequel-pro;
brew cask install virtualbox;
brew cask install docker;
brew cask install slack;
brew cask install iterm2;
brew cask install sketch;

# ここにzshを /etc/shell に追加するものを入れる
# /usr/local/bin/zsh を最後に追記
# TODO: 本当はここを自動化したいが、権限上うまく行くかわからない。
chsh -s /bin/zsh;

# defaultのやつをzshに変更
chsh -s /usr/local/bin/zsh;

# preztoのinstall
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto";
setopt EXTENDED_GLOB;
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}";
done

# この辺りからzshとpreztoのシンボリックリンク
# 上記のファイル群をdotfilesにシンボリックリンクを貼って処理する
DOT_FILES=(.zshrc .zprofile .zshenv .zpreztorc .vimrc)
for file in ${DOT_FILES[@]}
do
    ln -s $HOME/dotfiles/$file $HOME/$file;
done

# apm stars --installed としていたファイルを取り込む
apm stars --user SuguruOoki --install;

