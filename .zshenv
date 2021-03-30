#!/bin/env zsh
# Skip reading global config files after /etc/zshenv. The settings are messing with
# zsh-autocomplete.
unsetopt GLOBAL_RCS

HISTFILE=$ZDOTDIR/.zsh_history
