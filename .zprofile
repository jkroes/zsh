# /etc/zprofile is called after .zshenv but before .zshrc for login shells. It uses the path_helper utility to update PATH and MANPATH based on /etc/paths.d and /etc/manpaths.d. The end result is the default path with any changes appended, even if you prepend those changes in .zshenv. 
# See http://www.softec.lu/site/DevelopersCorner/MasteringThePathHelper
# If you want to update PATH in .zshenv, you can use the following code: 
# [[ -f ~/.zshenv ]] && source ~/.zshenv 

