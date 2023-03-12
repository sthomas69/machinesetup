# Dotfiles and scripts I use on dev machines

> Based off https://github.com/wicksipedia/dotfiles
> Original from https://github.com/haacked/dotfiles

## Setup

1. Install the tools
   `iwr -useb https://github.com/sthomas69/machinesetup/raw/main/setup-choco.ps1 | iex`
2. Clone repo
   `git clone https://github.com/sthomas69/machinesetup.git`
3. Customise Powershell & Windows Terminal
   `.\setup-shell.ps1`
4. Reload profile
   `. $profile`

## Semi-Unattended/Automated Setup Option

#### I've created an option of getting asked all the questions before-hand so that you can then leave the script to install what you wanted without needing you to wait and ever answer the prompt. So you have time for coffee while it's being done.

Install the tools
`iwr -useb https://github.com/sthomas69/machinesetup/raw/main/setup-choco-semi-unattend.ps1 | iex`

## Update

1. Pull latest
   `git pull`
2. Reinstall the tools
   `.\setup-choco.ps1`
3. Customise Powershell & Windows Terminal
   `.\setup-shell.ps1`
4. Reload profile
   `. $profile`

## What does this add?

If you don't want to install a particular item - feel free to comment the line out in the setup-choco script

Installs:

Free tools:

- 7zip
- Autohotkey
- Azure CLI
- Cascadia Code Nerd Font
- Chocolatey GUI
- Docker
- Eartrumpet
- Git
- GitHub CLI
- Insomnia
- oh-my-posh
- Linqpad
- Logitech Camera settings
- Logitech Options
- Microsoft Teams
- Nodejs LTS
- NSwag studio
- OBS studio
- OBS virtualcam
- paint.net
- Postman
- Powershell 7
- VSCode
- Windows Powertoys
- Windows Terminal
- Boxstarter

Paid tools: (optional)

- 1Password
- Snagit
- Visual Studio 2017 Enterprise
- Visual Studio 2019 Enterprise
- Visual Studio 2022 Enterprise

Customisations:

- Terminal-Icons
- Git
  - Aliases
- Powershell
  - Aliases
  - Hotkeys/Chords

## Want more? Need somthing else?

This is a WIP - Happy to take suggestions! Submit an issue/PR!
