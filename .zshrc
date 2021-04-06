#!/bin/env zsh

# Use vi mode
bindkey -v
setopt SHARE_HISTORY
setopt APPEND_HISTORY
export HISTSIZE=1000
export SAVEHIST=1000
export EDITOR=charm
export CHEAT_CONFIG_PATH=~/.config/cheat/conf.yml
# To make PAGER like MANPAGER, see
# https://vim.fandom.com/wiki/Using_vim_as_a_man-page_viewer_under_Unix
export PAGER=less
# https://git-scm.com/docs/git
export GIT_PAGER=less
# Set the default Less options. -F causes less to exit if the content to display
# is less than one screen; however, it also clears content from the screen. This
# means `git diff` may display nothing. To disable this, ensure both options are set.
export LESS='-X -F -g -i -M -R -S -w -z-4'
# Remove default pager flags that annoy me (like truncating long lines)
if [[ $PAGER == less ]]; then
        setopt hist_subst_pattern
        LESS=$LESS:gs/-[gS]\ /
        setopt no_hist_subst_pattern
fi

# MANPAGER should set all crucial settings explicitly so that you don't have
# to rely on potentially conflicting settings in .vimrc or init.vim
# NOTE: man.vim and mapping `K` aren't necessary; however, this does have
# the benefit of removing the prompt `Press ENTER or type command to continue`
# after `q` from a manpage you entered via `K`. It also makes `:Man` available
# if you want to view a manpage that is not the word under cursor.
# --not-a-term disables the "Reading from stdin..." message
# -R can be used in lieu of nomod
# ruler shows line position. It can be customized via rulerformat
export MANPAGER="/bin/sh -c \"col -b | \
	vim -nM --not-a-term \
	-c 'syntax on' \
	-c 'map d <C-D>' \
	-c 'map u <C-U>' \
	-c 'map q :q<CR>' \
	-c 'runtime ftplugin/man.vim' \
	-c 'map K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' \
	-c 'set ft=man ts=8 nolist nonu nomod linebreak breakindent wrap ruler rulerformat=%l\:%L\ (%p%%) ' \
	-\""

# Fuzzy find and open man pages
fman() {
    man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r man
}
# Doesn't work with MANPAGER
# See https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager/2183920 for ideas
# export GIT_PAGER=
if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi
path=(
  $path
  ~/go/bin
  # pipx-installed applications
  ~/.local/bin
  # User-defined scripts
  ~/bin
)
# https://stackoverflow.com/questions/39903571/gnu-find-on-macos
case $(uname) in
  Darwin)
    # Homebrew on ARM MacOS
    eval $(/opt/homebrew/bin/brew shellenv)
    # TODO: Create completions for whichever tldr-pages client you use
    fpath=(
      # cheat
      # You have to copy
      # ~/go/pkg/mod/github.com/cheat/cheat@v0.0.0-20201128162709-883a17092f08/scripts/cheat.zsh
      # to ~/.local/share/cheat/_cheat.zsh. The leading underscore is required.
      ~/.local/share/cheat
      # tldr pages (original client installed via `npm -g install tldr`)
      # TODO: Check out the tldr++ client
      /opt/homebrew/lib/node_modules/tldr/bin/completion/zsh
      $fpath
      # There are two sources of git completion in zsh:
      # /usr/share/zsh/5.8/functions/_git and the one in
      # Homebrew. The zsh-provided git completion seems superior, as it includes
      # descriptions for flags to git subcommands. See discussion:
      # https://stackoverflow.com/questions/38725102/how-to-add-custom-git-command-to-zsh-completion
      # TODO: Compare both to https://github.com/felipec/git-completion and
      #  https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gitfast
      # Homebrew completions need to be lower in the path to avoid shadowing.
      /opt/homebrew/share/zsh/site-functions
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

alias cat=bat

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

# This line was in marlonrichert's .zshrc in his config repo
export ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
# README requires this to be at the end of file
znap source zsh-users/zsh-syntax-highlighting

# Toggle navi (fzf-powered cheats) w/ C-g
# NOTE: Should be lower down in config to avoid
# shadowing by zsh-autocomplete and friends
eval "$(navi widget zsh)"
# TODO: Create completions for navi

cd $ZDOTDIR
