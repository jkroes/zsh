#!/usr/bin/env zsh

#
# Dependencies
#

# fzf
# fzf-tab
# fd
# bat
# exa
# pet
# dracula.dircolors
# rg
# fzf-rg (github.com/jkroes/home_bin)

#
# Prompt
#

# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
# λ for regular user, ! for super user
PROMPT='%(!.! .λ )'
# Current directory on right
RPROMPT='%F{blue}%~%f'

#
# vim
#

bindkey -v # vi bindings

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

#
# Basic settings
#

setopt globdots
setopt SHARE_HISTORY
setopt APPEND_HISTORY
export HISTSIZE=1000
export SAVEHIST=1000
if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

#
# (f)path
#

# snipcli installation and usage on MacOS arm64:
# Install crystal-0.35.1-1.pkg (/opt/crystal)
# https://github.com/crystal-lang/crystal/releases/tag/0.35.1
# Install this snipcli fork from source in ~/git.
# (Note that the fork did not update the README to refer to itself when
# running git clone)
# > git clone https://github.com/ajones/snipcli
# > cd ~/git/snipcli
# > export path=(/opt/crystal/bin /opt/crystal/embedded/bin $path)
# From https://crystal-lang.org/install/on_mac_os/:
# > export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/openssl/lib/pkgconfig
# > shards
# > crystal build src/snipline_cli.cr -o snipcli --release -o snipcli
# Ignore the warning
# > snipcli init
# Alternative to snipcli:
# https://github.com/yuki-yano/zsh-fzf-snippet

path=(
  $path
  ~/go/bin
  ~/.local/bin # pipx-installed applications
  ~/bin # User-defined scripts
)

case $(uname) in
  Darwin)
    # Set up homebrew environment.
    # NOTE: iTerm can run in Rosetta mode on MacOS M1:
    # Navigate to /Applications/iTerm
    # Right-click, Get Info.
    # Check box for Rosetta.
    # CMD-Q iTerm, launch, and check `uname -m`
    case $(uname -m) in
      x86_64)
        export HOMEBREW_PREFIX="/usr/local"
        export HOMEBREW_CELLAR="/usr/local/Cellar";
        export HOMEBREW_REPOSITORY="/usr/local/Homebrew";
      ;;
      arm64)
        export HOMEBREW_PREFIX="/opt/homebrew";
        export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
        export HOMEBREW_REPOSITORY="/opt/homebrew";
      ;;
    esac
    infopath=(
      $infopath
      $HOMEBREW_PREFIX/share/info
    )
    manpath=(
      $manpath
      $HOMEBREW_PREFIX/share/man
    )
    fpath=(
      $fpath
      $HOMEBREW_PREFIX/share/zsh/site-functions
    )
   path=(
     $HOMEBREW_PREFIX/bin
     $HOMEBREW_PREFIX/sbin
     $path
   )
   ;;
esac

#
# (man)pager
#

export PAGER=less # https://vim.fandom.com/wiki/Using_vim_as_a_man-page_viewer_under_Unix
export GIT_PAGER=less # https://git-scm.com/docs/git

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
	-c 'set ft=man ts=8 hlsearch nolist nonu nomod linebreak breakindent wrap ruler rulerformat=%l\:%L\ (%p%%) ' \
	-\""

#
# fzf: fuzzy find and filter
#

# Run once on Linux after installing fd-find:
# ln -s $(whence -f fdfind) ~/.local/bin/fd

# NOTE: This affects fzf-tab
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# What to run when fzf is used as the primary command rather than as a pipeline filter
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# TODO: Change command to execute command
fhistory() {
  builtin history -1000 | fzf
}

fman() {
    man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r man
}

# See `man fd` for a link to the Rust flavour of regex. It is the same as
# that used by ripgrep, but an older version.

# fzf install script includes autocompletion (fzf/shell/completion.zsh)
# and keybindings that are enabled by /opt/homebrew/opt/fzf/install. It adds
# the following to .zshrc:
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# and creates ~/.fzf.zsh. Completion requires typing a trigger sequence ('**')
# followed by TAB. It is specific to a limited number of commands such as cd,
# ls, vim, etc. In contrast, vim-tab uses fzf as a frontend for the zsh
# completion system. It requires no trigger sequence and can use fzf for any
# command that provides a zsh completion script.

# For a discussion of fzf vs fzf-tab completion in zsh, see
# https://github.com/Aloxaf/fzf-tab/issues/65

#
# ripgrep + fzf
#

# See ~/bin/fzf-rg. Consider adding an alias.

# See regex syntax: https://docs.rs/regex/1.4.5/regex/#syntax

#
# fzf-tab: fzf as zsh-completion frontend
#

autoload -Uz compinit
compinit -D
source ~/git/fzf-tab/fzf-tab.plugin.zsh

# At the start of completion, all candidates are shown,
# highlighted by group. Switching group via ',' or '.' will change
# the color of the active group (currently white) and limit the
# completion candidates to that group. Note that the filtered
# candidates retain the original color of the group.
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' switch-group ',' '.'

# disable sort when completing options of any command
# NOTE: To show relevant zstyle contexts and tags, use 'C-x h' instead of TAB
zstyle ':completion:complete:*:options' sort false

# disable sort for `git log` completions; default chronological order
zstyle ':completion:*:git-log:*' sort false

# FZF previews (use single quotes around the preview commands)
# TODO: This is too general and provides a preview for most completions.
# Enable it only for completion of contexts where a file is expected.
# zstyle ':fzf-tab:complete:*' fzf-preview '[[ -f $realpath ]] && bat --style=numbers --color=always --line-range :100 $realpath'
## Ranger-like navigation of directories
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

# NOTE: This partially changes exa's apparently natural coloration, but also
# allows for coloration with fzf-tab. Not sure how to tell fzf-tab to use
# exa's natural coloration. At least both are consistent with each other now.
# TODO: Investigate dircolors, exa, and this zstyle snippet

if [[ ! -a ~/dircolors/dracula.dircolors ]]; then
	if [[ ! -d ~/dircolors ]]; then
		mkdir ~/dircolors
	fi
	wget https://raw.githubusercontent.com/joshbenham/linux-dotfiles/master/dircolors/Dracula.dircolors > ~/dircolors/dracula.dircolors
fi
case $(uname) in
	Darwin)
		eval $(gdircolors ~/dircolors/dracula.dircolors)
		;;
	Linux)
		eval $(dircolors ~/dircolors/dracula.dircolors)
		;;
esac
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

#
# aliases
#

alias cdf='pwdf; cd "$(pwdf)"'
if type bat >/dev/null; then
	alias cat=bat
else
	alias cat=batcat
fi
alias ls=exa
alias la='ls -la'
if type wslview >/dev/null; then
	alias open=wslview
fi
# https://superuser.com/questions/1043806/how-to-exit-the-ranger-file-explorer-back-to-command-prompt-but-keep-the-current#:~:text=If%20you%20hit%20Shift%20%2B%20S,it%20goes%20back%20to%20ranger%20.
alias r='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'

#
# pet: CLI snippets
#

# Add previous command to pet
function prev() {
  PREV=$(fc -lrn | head -n 1)
  sh -c "pet new `printf %q "$PREV"`"
}

# C-g inserts selection into current line/buffer
# NOTE: Example from README in GitHub omits inner quotes; however,
# I found they were necessary. Perhaps our options are set differently
function pet-select() {
  BUFFER=$(pet search --query "'$LBUFFER'")
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N pet-select
stty -ixon
bindkey '^g' pet-select

alias pc='pet configure'
alias pe='pet exec'
alias ped='pet edit'
alias pl='pet list'
alias pn='pet new'

# truecolor support for `emacs -nw` on MacOS
# Requires following instructions at https://github.com/syl20bnr/spacemacs/wiki/Terminal
export TERM=xterm-24bit

# For WSL
cd ~/

alias e="emacs --debug-init &"
# Open files with running emacs server, then free the terminal
# alias e=~/bin/emacs-same-frame

# Open files in from ranger (among other programs)
export EDITOR=~/bin/emacs-same-frame

# git-commit aborts using the graphical EDITOR...
export GIT_EDITOR="emacsclient -a '' -t"

# TODO: Use this as a basis to make emacsclient frame focus when launced:
# https://www.emacswiki.org/emacs/TilingWindowManagers

#
# Archived code
#

# Redirect `man zsh` to `man zshall` for convenience
#unalias man # whence -f man
#function man() {
#        if [[ ${@[-1]} == zsh ]]; then
#                /usr/bin/man zshall
#        else
#                nocorrect /usr/bin/man $@
#        fi
#}

# View man pages as PDF in Preview
# function pman() { man -t "$@" | open -f -a "Preview" ;}

# View man pages using the default handler for x-man-page URIs (typically terminal)
# Source:
# https://scriptingosx.com/2017/04/on-viewing-man-pages/
# https://robservatory.com/open-unix-man-pages-in-their-own-terminal-window/
# Terminal.app is the default x-man-page handler. To make, x-man-page output prettier, configure the Man Page profile in Terminal to use white text, aquamarine bold text, red selection, and a black background.kkk
# TODO: There's a way to configure Dash.app to open man pages. E.g., see https://gist.github.com/boneskull/4b6378784e2d719dd543. Note that Dash.app has instructions for adding Linux man pages.
#function xmanpage() { open x-man-page://$@ ; }

# There are two sources of git completion in zsh:
# /usr/share/zsh/5.8/functions/_git and the one in
# Homebrew. The zsh-provided git completion seems superior, as it includes
# descriptions for flags to git subcommands. See discussion:
# https://stackoverflow.com/questions/38725102/how-to-add-custom-git-command-to-zsh-completion
# TODO: Compare both to https://github.com/felipec/git-completion and
#  https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gitfast
# Homebrew completions need to be lower in the path to avoid shadowing.
