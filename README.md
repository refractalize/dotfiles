To setup on a new machine:

```sh
cd ~    
git init
git remote add origin https://github.com/refractalize/dotfiles.git
git fetch
git reset origin/master
```

And checkout as necessary:

```sh
git checkout .vimrc
git checkout .gitconfig
```

You'll most likely need to install [Vundle](https://github.com/VundleVim/Vundle.vim#quick-start).
