source ~/git/zsh-snap/znap.zsh

znap source marlonrichert/zcolors
znap eval zcolors "zcolors ${(q)LS_COLORS}"

znap source marlonrichert/zsh-autocomplete

# README requires this to be at the end of file
export ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting

export HISTSIZE=1000
export SAVEHIST=1000
