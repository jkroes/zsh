#!/bin/env zsh
source ~/git/zsh-snap/znap.zsh

znap source marlonrichert/zcolors
znap eval zcolors "zcolors ${(q)LS_COLORS}"

# Configuration documented at:
# https://github.com/marlonrichert/zsh-autocomplete/blob/main/.zshrc

# Complete dotfiles (and folders!)
setopt globdots

# Implicit cd if directory is in command position
setopt auto_cd

# With setopt auto_cd, display directories immediately
zstyle ':autocomplete:*' min-input 0

# Repeated tabs cycle completion menu visibly
zstyle ':autocomplete:tab:*' widget-style menu-select

znap source marlonrichert/zsh-autocomplete

# Use vi mode
bindkey -v
# TODO: Investigate zsh-autokey bindings.

cd $ZDOTDIR
setopt SHARE_HISTORY
setopt APPEND_HISTORY
export HISTSIZE=1000
export SAVEHIST=1000
export EDITOR=vim
export VISUAL=vim
export PAGER=less
if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi
path=(
  $path
  # User-defined scripts
  ~/bin
)
# https://stackoverflow.com/questions/39903571/gnu-find-on-macos
case $(uname) in
  Darwin)
    # Homebrew on ARM MacOS
    eval $(/opt/homebrew/bin/brew shellenv)
    fpath=(
      # Homebrew autocompletions
      /opt/homebrew/share/zsh/site-functions
      $fpath
    )
   path=(
     # /Library/Frameworks/R.framework/Versions/Current/Resources/bin
     $path
   )
   ;;
esac

# Redirect `man zsh` to `man zshall` for convenience
#unalias man # whence -f man
#function man() {
#        if [[ ${@[-1]} == zsh ]]; then
#                /usr/bin/man zshall
#        else
#                nocorrect /usr/bin/man $@
#        fi
#}

alias cdf='pwdf; cd "$(pwdf)"'

# Super ranger. Also works with `d` and `1`-`9`
# Source: https://superuser.com/questions/1043806/how-to-exit-the-ranger-file-explorer-back-to-command-prompt-but-keep-the-current#:~:text=If%20you%20hit%20Shift%20%2B%20S,it%20goes%20back%20to%20ranger%20.
alias r='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'

# View man pages as PDF in Preview
# function pman() { man -t "$@" | open -f -a "Preview" ;}

# View man pages using the default handler for x-man-page URIs (typically terminal)
# Source:
# https://scriptingosx.com/2017/04/on-viewing-man-pages/
# https://robservatory.com/open-unix-man-pages-in-their-own-terminal-window/
# Terminal.app is the default x-man-page handler. To make, x-man-page output prettier, configure the Man Page profile in Terminal to use white text, aquamarine bold text, red selection, and a black background.kkk
# TODO: There's a way to configure Dash.app to open man pages. E.g., see https://gist.github.com/boneskull/4b6378784e2d719dd543. Note that Dash.app has instructions for adding Linux man pages.
#function xmanpage() { open x-man-page://$@ ; }

# Change cursor shape for different vi modes.
# https://www.youtube.com/watch?v=eLEo4OQ-cuQ
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt

# Set the default Less options.
#GIT_PAGER='cat git diff'
export LESS='-X -F -g -i -M -R -S -w -z-4'
# Remove default pager flags that annoy me (like truncating long lines)
#(Could define LESS explicitly, but I like this code demo for reference)
if [[ $PAGER == less ]]; then
        setopt hist_subst_pattern
        LESS=$LESS:gs/-[gS]\ /
        setopt no_hist_subst_pattern
fi
# https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager/2183920

# This line was in marlonrichert's .zshrc in his config repo
export ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
# README requires this to be at the end of file
znap source zsh-users/zsh-syntax-highlighting
