 #!/bin/bash

DOT_FILES=(.zshrc .zprofile .zshenv .zpreztorc .vimrc)

#上記のファイル群をdotfilesにシンボリックリンクを貼って処理する
for file in ${DOT_FILES[@]}
do
    ln -s $HOME/dotfiles/$file $HOME/$file
done

#Homebrewをinstall

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# brew fileをinstall
# brew fileのinstall先をdotfiles以下に設定 => zshrcなどでも設定を書いている
# brew fileのリポジトリを設定
# brew fileをpullする
brew file pull

# brewfileの内容をinstall
# brew caskの中身をinstall

brew file install

# ここにzshを /etc/shell に追加するものを入れる
# /usr/local/bin/zsh を最後に追記
# TODO: 本当はここを自動化したい

sudo vi /etc/shells

# defaultのやつをzshに変更
chsh -s /usr/local/bin/zsh

# apm stars --installed としていたファイルを取り込む
apm stars --user SuguruOoki --install


