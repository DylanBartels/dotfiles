#!/bin/bash

#===============================================================================
#   A shell script to help with the quick setup of tools and applications.
# 
#   Quick Instructions:
#
#   1. Make the script executable:
#      chmod +x ./setup-new-computer.sh
#
#   2. Run the script:
#      ./setup-new-computer.sh
#
#   3. Some installs will need your password
#
#   4. You will be promted to fill out your git email and name. 
#      Use the email and name you use for Github
#
#===============================================================================

#===============================================================================
#  Functions
#===============================================================================


printHeading() {
    printf "\n\n\n\e[0;36m$1\e[0m \n"
}

printDivider() {
    printf %"$COLUMNS"s |tr " " "-"
    printf "\n"
}

printError() {
    printf "\n\e[1;31m"
    printf %"$COLUMNS"s |tr " " "-"
    if [ -z "$1" ]      # Is parameter #1 zero length?
    then
        printf "     There was an error ... somewhere\n"  # no parameter passed.
    else
        printf "\n     Error Installing $1\n" # parameter passed.
    fi
    printf %"$COLUMNS"s |tr " " "-"
    printf " \e[0m\n"
}

printStep() {
    printf %"$COLUMNS"s |tr " " "-"
    printf "\nInstalling $1...\n";
    $2 || printError "$1"
}

printLogo() {
cat << "EOT"
 ------------------------------------------
    Q U I C K   S E T U P   S C R I P T


    NOTE:
    You can exit the script at any time by
    pressing CONTROL+C a bunch
EOT
}


writetoZshProfile() {
cat << EOT >> ~/.zprofile


# --------------------------------------------------------------------
# Begin ZSH autogenerated content from setup-new-computer.sh
# --------------------------------------------------------------------

# Pyenv
eval $(/opt/homebrew/bin/brew shellenv)

# Setting up Path for Homebrew
export PATH=/usr/local/sbin:\$PATH

# Brew Autocompletion
if type brew &>/dev/null; then
    fpath+=\$(brew --prefix)/share/zsh/site-functions
fi

# Zsh Autocompletion
# Note: must run after Brew Autocompletion
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
fpath=(/usr/local/share/zsh-completions \$fpath)

# --------------------------------------------------------------------
# End autogenerated content from setup-new-computer.sh
# --------------------------------------------------------------------

EOT
}

printLogo

# Get root user for later. Brew needs the user to be admin to install 
sudo ls > /dev/null

#===============================================================================
#  Installer: Set up shell profiles
#===============================================================================


# Create .bash_profile and .zprofile if they dont exist
printHeading "Prep Bash and Zsh"
printDivider
    echo "✔ Touch ~/.bash_profile"
        touch ~/.bash_profile
printDivider
    echo "✔ Touch ~/.zprofile"
        touch ~/.zprofile
printDivider
    if grep --quiet "setup-new-computer.sh" ~/.bash_profile; then
        echo "✔ .bash_profile already modified. Skipping"
    else
        writetoBashProfile
        echo "✔ Added to .bash_profile"
    fi
printDivider
    # Zsh profile
    if grep --quiet "setup-new-computer.sh" ~/.zprofile; then
        echo "✔ .zprofile already modified. Skipping"
    else
        writetoZshProfile
        echo "✔ Added to .zprofile"
    fi
printDivider
    echo "(zsh) Rebuild zcompdump"
    rm -f ~/.zcompdump
printDivider
    echo "(zsh) Fix insecure directories warning"
    chmod go-w "$(brew --prefix)/share"
printDivider


#===============================================================================
#  Installer: Main Payload
#===============================================================================


# Install xcode cli development tools
printHeading "Installing xcode cli development tools"
printDivider
    xcode-select --install && \
        read -n 1 -r -s -p $'\n\nWhen Xcode cli tools are installed, press ANY KEY to continue...\n\n' || \
            printDivider && echo "✔ Xcode cli tools already installed. Skipping"
printDivider


# Install Brew
printHeading "Installing Homebrew"
printDivider
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
printDivider
    echo "✔ Setting Path to /usr/local/bin:\$PATH"
        export PATH=/usr/local/bin:$PATH
printDivider


# Install Utilities
printHeading "Installing Brew Packages"
    printStep "Bash"                        "brew install bash"
    printStep "bash-completion"             "brew install bash-completion"
    printStep "zsh-completions"             "brew install zsh-completions"
    printStep "Git"                         "brew install git"
printDivider


# Install  Apps
printHeading "Installing Applications"
    printStep "Slack"                       "brew install --cask slack"
    printStep "Firefox"                     "brew install --cask firefox"
    printStep "Docker for Mac"              "brew install --cask docker"
    printStep "Visual Studio Code"          "brew install --cask visual-studio-code"
    printStep "iTerm2"                      "brew install --cask iterm2"
printDivider

# Install System Tweaks
printHeading "System Tweaks"
    echo "✔ General: Save to disk (not to iCloud) by default"
        defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    echo "✔ General: Avoid creating .DS_Store files on network volumes"
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    echo "✔ Typing: Disable smart quotes and dashes as they cause problems when typing code"
        defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
        defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    echo "✔ Finder: Show status bar and path bar"
        defaults write com.apple.finder ShowStatusBar -bool true
        defaults write com.apple.finder ShowPathbar -bool true
    echo "✔ Finder: Disable the warning when changing a file extension"
        defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    echo "✔ Finder: Show the ~/Library folder"
        chflags nohidden ~/Library
printDivider



#===============================================================================
#  Installer: Git
#===============================================================================


# Set up Git
printHeading "Set Up Git"

printDivider
    echo "✔ Set Git to store credentials in Keychain"
    git config --global credential.helper osxkeychain
printDivider
    if [ -n "$(git config --global user.email)" ]; then
        echo "✔ Git email is set to $(git config --global user.email)"
    else
        read -p 'What is your Git email address?: ' gitEmail
        git config --global user.email "$gitEmail"
    fi
printDivider
    if [ -n "$(git config --global user.name)" ]; then
        echo "✔ Git display name is set to $(git config --global user.name)"
    else
        read -p 'What is your Git display name (Firstname Lastname)?: ' gitName
        git config --global user.name "$gitName"
    fi
printDivider


#===============================================================================
#  Installer: Complete
#===============================================================================

printHeading "Script Complete"
printDivider
exit