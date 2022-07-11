function Get-Gbp-QuestionAnswer {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory, Position=0, HelpMessage="What are you asking the user to provide a value to?")]
        [string]
		$Question = "Please provide 'INPUT'?",

    [Parameter(Position=1, HelpMessage="What is the default responce value. `n`tDEFAULT=exit")]
        [string]
		$dynamicDEFAULT = "exit",

    [Parameter(Position=2, HelpMessage="Are you wanting a TRUE/FALSE answer? `n`tDEFAULT=false")]
		[switch]
		$IsYesNoQuestion,

    [Parameter(Position=3, HelpMessage="What is the min acceptable length of the answer? `n`tDEFAULT=0")]
		[int]
		$AnswerLengthMin = 0,

	[Parameter(Position=4, HelpMessage="What is the max acceptable length of the answer? `n`tDEFAULT=254")]
		[int]
		$AnswerLengthMax = 254
    )
	Begin
	{
        [bool]$IsDebuggingEnabled = $true
        [bool]$IsVerboseEnabled = $true

        $OriginalInformationPreference = $InformationPreference
        $OriginalDebugPreference = $DebugPreference
        $OriginalVerbosePreference = $VerbosePreference

        $InformationPreference = "continue"
        if($IsDebuggingEnabled){$DebugPreference = "continue"}
        if($IsVerboseEnabled){$VerbosePreference = "continue"}

		$dynamic = $null
		$Answer = ""

		Write-Information "`n_____| QUESTION |_____________________________________________________"
	}
	Process
	{
		#__________________________________________________________

        if ($IsYesNoQuestion.IsPresent){
            while("GOT-VALID-ANSWER","$dynamicDEFAULT" -notcontains $dynamic){
                $dynamic = Read-Host "$Question (y/yes, n/no, exit) [$dynamicDEFAULT]"
                #Write-Debug "Response=[$dynamic]"
                if($null -eq $dynamic -or $dynamic -eq "" -or $dynamic -eq $dynamicDEFAULT){$dynamic=$dynamicDEFAULT}

                # Need to workout if the value entered is valid for a machine name and description
                $Answer = $dynamic.Trim().ToLower()
                if("y","yes" -contains $Answer){
                    $Answer = "TRUE"
                    $dynamic = "GOT-VALID-ANSWER"

                }elseif("n","no" -contains $Answer){
                    $Answer = "FALSE"
                    $dynamic = "GOT-VALID-ANSWER"

                }elseif ($Answer -ne $dynamicDEFAULT ) {
                    Write-Warning "Invalud input value!"
                    $dynamic = "invalid name"

                }else { $dynamic = "GOT-VALID-ANSWER" }
            }
        } else {
            Write-Debug "Note: providing spaces will return an empty string for this"
            while("GOT-VALID-ANSWER","$dynamicDEFAULT" -notcontains $dynamic){
                $dynamic = Read-Host "$Question [$dynamicDEFAULT]"
                #Write-Debug "Response=[$dynamic]"
                if($null -eq $dynamic -or $dynamic -eq "" -or $dynamic -eq $dynamicDEFAULT){$dynamic=$dynamicDEFAULT}

                # Need to workout if the value entered is valid for a machine name and description
                $Answer = $dynamic
                if($Answer.Trim().Length -eq 0){
                    Write-Warning "You enter a blank string by passing spaces. Will be returning """" to this question!"
                    $Answer = ""
                    $dynamic = "GOT-VALID-ANSWER"

                }elseif ($Answer.Trim().Length -lt $AnswerLengthMin -or $Answer.Trim().Length -gt $AnswerLengthMax) {
                    Write-Warning "Answer must be between $AnswerLengthMin - $AnswerLengthMax char!"
                    $dynamic = "invalid name"

                }else { $dynamic = "GOT-VALID-ANSWER" }
            }
        }

        #______________________________________________________
        #                DONE Processing
        #______________________________________________________
    }
    end
    {
        $Answer = $Answer.Trim()
        #Write-Information "__________> Returning =""$Answer"" <__________"
        $VerbosePreference = $OriginalVerbosePreference
        $DebugPreference = $OriginalDebugPreference
        $InformationPreference = $OriginalInformationPreference

		return $Answer
	}
}

# Debugging
#$Install_Command_Base = "choco install --what-if --verbose -y "
$Install_Command_Base = "choco install -y "

#install choco
Write-Output "Installing/Updating Choco"
if ($null -eq (Get-Command -Name choco.exe -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    & choco update Chocolatey
}

Write-Output  "Intstalling minimal setup"
& choco install `
    7zip `
    cascadia-code-nerd-font `
    chocolateygui `
    git `
    oh-my-posh `
    microsoft-windows-terminal `
    powertoys `
    pwsh `
    sysinternals `
	vscode `
    -y

# Setup Synology Active Backup for Business
# -> You will be prompted for the config details
# Example:
#choco install synology-activebackup-for-business-agent --params="'/Address:192.168.1.1 /Username:Synology /Password:MyPassword /RemoveShortcut'"
if ((Read-Host "Setup Synology Active Backup for Business: (y/N)").ToLower() -eq 'y') {
	$IsRequiredAnswersCompleted = $false
	$IsSynoOKToInstall = $false
	$Syno_FQDN = ""
	$Syno_Username = ""
	$Syno_Password = ""
	$Syno_Params = ""

	do {
		do {
			Write-Information "Please provide the Synology NAS details, FQDN, Username & Password"

			$Syno_FQDN = Get-Gbp-QuestionAnswer -Question "Synology NAS FQDN/IP Address?" -dynamicDEFAULT "exit"
			if($Syno_FQDN -ne "exit"){
				$Syno_Username = Get-Gbp-QuestionAnswer -Question "Synology NAS Backup Agent Username?" -dynamicDEFAULT "exit"
				if($Syno_Username -ne "exit"){
					$Syno_Password = Get-Gbp-QuestionAnswer -Question "Synology NAS Backup Agent Password?" -dynamicDEFAULT "exit"
					if($Syno_Password -ne "exit"){
						$IsRequiredAnswersCompleted = $true
						$IsSynoOKToInstall = $true
					} else { $IsRequiredAnswersCompleted = $true }
				} else { $IsRequiredAnswersCompleted = $true }
			} else { $IsRequiredAnswersCompleted = $true }

		} until (
			$IsRequiredAnswersCompleted
		)
        if ($IsSynoOKToInstall) {
            $IsRequiredAnswersCompleted = $false

            $Syno_Params = """'/Address:"+$Syno_FQDN+" /Username:"+$Syno_Username+" /Password:"+$Syno_Password+"'"""
            Write-Output $Syno_Params

            $AreTheValuesCorrect = Get-Gbp-QuestionAnswer -Question "Are the values correct?" -IsYesNoQuestion -dynamicDEFAULT "exit"

            switch ($AreTheValuesCorrect) {
                "TRUE" {
                    $IsSynoOKToInstall = $true
                    $IsRequiredAnswersCompleted = $true

                    $Syno_Install_Command = "synology-activebackup-for-business-agent --params="+$Syno_Params
                }
                Default { $IsRequiredAnswersCompleted = $false}
            }
        }
    } until (
        $IsRequiredAnswersCompleted
	)

	if ($IsSynoOKToInstall) {
        $Install_Command_Complete = $Install_Command_Base+$Syno_Install_Command

        Write-Output "Executing: $Install_Command_Complete"
        Invoke-Expression $Install_Command_Complete
	}
}

Write-Output "Installing Telnet Client"
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient -NoRestart

if ((Read-Host "Install Hyper-V: (y/N)").ToLower() -eq 'y') {
	Write-Output "Installing Hyper-V and packages"
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
}

if ((Read-Host "Install WSL: (y/N)").ToLower() -eq 'y') {
	Write-Output "Installing WSL"
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
}

# add Server tools
if ((Read-Host "Install Server tools (BoxStarter ""Create Machine via Code""): (y/N)").ToLower() -eq 'y') {
    & choco install `
		boxstarter `
        -y
}

# add tools
if ((Read-Host "Install dev tools: (y/N)").ToLower() -eq 'y') {
    & choco install `
        autohotkey.install `
        azure-cli `
        eartrumpet `
        gh `
        insomnia-rest-api-client `
        linqpad `
        nodejs-lts `
        nswagstudio `
        postman `
        sudo `
        -y
}

# add Kubernetes tools
if ((Read-Host "Install Kubernetes tools: (y/N)").ToLower() -eq 'y') {
    & choco install `
		kubernetes-cli `
        vscode-kubernetes-tools `
        kubernetes-helm `
        -y
}

# add Minicube
if ((Read-Host "Install Docker-Desktop and Minicube: (y/N)").ToLower() -eq 'y') {
    & choco install `
		docker-desktop `
		minikube `
        -y
}

if ((Read-Host "Install 1Password and KeePass: (y/N)").ToLower() -eq 'y') {
    & choco install `
        1password `
        keepass `
        keepass-plugin-keeagent ` # Allow SSH keys stored in a KeePass database to be used for SSH authentication by other programs
        -y
}

if ((Read-Host "Install paid tools: SnagIt: (y/N)").ToLower() -eq 'y') {
    & choco install `
        snagit `
        -y
}

if ((Read-Host "Install any Visual Studio (you will be asked for the versons): (y/N)").ToLower() -eq 'y') {
	$VS_Install_List = ""

	if ((Read-Host "Version: Visual Studio 2017: (y/N)").ToLower() -eq 'y') {
		$VS_Install_List = $VS_Install_List & " visualstudio2017enterprise" }
	if ((Read-Host "Version: Visual Studio 2019: (y/N)").ToLower() -eq 'y') {
		$VS_Install_List = $VS_Install_List & " visualstudio2019enterprise" }
	if ((Read-Host "Version: Visual Studio 2022: (y/N)").ToLower() -eq 'y') {
		$VS_Install_List = $VS_Install_List & " visualstudio2022enterprise" }

	if ($VS_Install_List.Trim().Length -gt 0) {
        $Install_Command_Complete = $Install_Command_Base+$VS_Install_List.Trim()

        Write-Output "Executing: $Install_Command_Complete"
        Invoke-Expression $Install_Command_Complete
	}
}

# if ((Read-Host "Install gaming apps: (y/N)").ToLower() -eq 'y') {
#     & choco install `
#         epicgameslauncher `
#         steam-client `
#         -y
# }

if ((Read-Host "Install other apps (Logitech camera, OBS, Teams, Paint.NET): (y/N)").ToLower() -eq 'y') {
    & choco install `
        logitech-camera-settings `
        logitech-options `
        microsoft-teams `
        paint.net `
        obs-studio `
        obs-virtualcam `
        -y
}
