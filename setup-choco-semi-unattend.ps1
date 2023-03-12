function Get-Gbp-QuestionAnswer {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory, Position=0, HelpMessage="What are you asking the user to provide a value to?")]
        [string]
		$Question,

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

# This will be a complete list of items that you want installed
# It will allow you to answer all the questions and then walk away from the PC while Choco is installing things
$Choco_Install_List = ""

Write-Information "This is a list of minimal apps/tools that will be installed by default:-"
Write-Output "7zip cascadia-code-nerd-font chocolateygui git oh-my-posh microsoft-windows-terminal powertoys pwsh vscode"

if ((Read-Host "Install minimal apps/tools listed above? (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " 7zip cascadia-code-nerd-font chocolateygui git oh-my-posh microsoft-windows-terminal powertoys pwsh vscode"
}

$Install_HyperV = $false
if ((Read-Host "Install Hyper-V: (y/N)").ToLower() -eq 'y') {
	$Install_HyperV = $true
}

$Install_WSL = $false
if ((Read-Host "Install WSL: (y/N)").ToLower() -eq 'y') {
	$Install_WSL = $true
}

# add Server tools
if ((Read-Host "Install Server tools (BoxStarter ""Create Machine via Code""): (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " boxstarter"
}

# add tools
if ((Read-Host "Install dev tools: (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " azure-cli eartrumpet gh insomnia-rest-api-client linqpad postman"
}

# add Kubernetes tools
if ((Read-Host "Install Kubernetes tools: (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " kubernetes-cli vscode-kubernetes-tools kubernetes-helm"
}

if ((Read-Host "Install Docker-Desktop: (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " docker-desktop"

	# add Minicube
	if ((Read-Host "Install Docker-Desktop and Minicube: (y/N)").ToLower() -eq 'y') {
		$Choco_Install_List = $Choco_Install_List + " minikube"
	}
}

if ((Read-Host "Install 1Password: (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " 1password"
}

if ((Read-Host "Install KeePass: (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " keepass keepass-plugin-keeagent"
	# Allow SSH keys stored in a KeePass database to be used for SSH authentication by other programs
}

if ((Read-Host "Install paid tools: SnagIt: (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " snagit"
}

$VS_Install_List = ""
if ((Read-Host "Install any Visual Studio (you will be asked for the versons): (y/N)").ToLower() -eq 'y') {

	if ((Read-Host "Version: Visual Studio 2017: (y/N)").ToLower() -eq 'y') {
		$VS_Install_List = $VS_Install_List + " visualstudio2017enterprise" }
	if ((Read-Host "Version: Visual Studio 2019: (y/N)").ToLower() -eq 'y') {
		$VS_Install_List = $VS_Install_List + " visualstudio2019enterprise" }
	if ((Read-Host "Version: Visual Studio 2022: (y/N)").ToLower() -eq 'y') {
		$VS_Install_List = $VS_Install_List + " visualstudio2022enterprise" }
}

# Setup Synology Active Backup for Business
# -> You will be prompted for the config details
# Example:
#choco install synology-activebackup-for-business-agent --params="'/Address:192.168.1.1 /Username:Synology /Password:MyPassword /RemoveShortcut'"
$IsSynoOKToInstall = $false
if ((Read-Host "Setup Synology Active Backup for Business: (y/N)").ToLower() -eq 'y') {
	$IsRequiredAnswersCompleted = $false
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
}

if ((Read-Host "Install Microsoft Teams: (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " microsoft-teams"
}

if ((Read-Host "Install Paint.NET: (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " paint.net"
}

if ((Read-Host "Install OBS Studio: (y/N)").ToLower() -eq 'y') {
	$Choco_Install_List = $Choco_Install_List + " obs-studio obs-virtualcam"
}

if ((Read-Host "Install Logitech camera: (y/N)").ToLower() -eq 'y') {
    $Choco_Install_List = $Choco_Install_List + " logitech-camera-settings logitech-options"
}

$Install_Command_ChocoList = $Install_Command_Base+$Choco_Install_List

Write-Output ""
Write-Output "============================================================================================="
Write-Output " About to now go through and install the Apps/Tools you requested."

$IsRequiredAnswersCompleted = $false
$Install_List = """"+$Choco_Install_List+""""
Write-Output $Install_List

$AreTheValuesCorrect = Get-Gbp-QuestionAnswer -Question "Are you happy to install?" -IsYesNoQuestion -dynamicDEFAULT "exit"

switch ($AreTheValuesCorrect) {
	"TRUE" {
		$IsRequiredAnswersCompleted = $true
	}
	Default { $IsRequiredAnswersCompleted = $false}
}

if ($IsRequiredAnswersCompleted = $true) {
	Write-Output "Installing Approved List of Apps/Tools, go and have coffee..."
	Write-Output ""

	Write-Output "Installing Telnet Client"
	Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient -NoRestart

	if ($Install_HyperV = $true) {
		Write-Output "Installing Hyper-V and packages"
		Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
	}

	if ($Install_WSL = $true) {
		Write-Output "Installing WSL"
		Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
	}

	Invoke-Expression $Install_Command_ChocoList

	if ($VS_Install_List.Trim().Length -gt 0) {
		Write-Output "Installing the requested Visual Studio's selected..."

		$Install_Command_Complete = $Install_Command_Base+$VS_Install_List.Trim()

		Write-Output "Executing: $Install_Command_Complete"
		Invoke-Expression $Install_Command_Complete
	}

	if ($IsSynoOKToInstall) {
		Write-Output "Installing Synology Backup Agent..."

		$Install_Command_Complete = $Install_Command_Base+$Syno_Install_Command

		Write-Output "Executing: $Install_Command_Complete"
		Invoke-Expression $Install_Command_Complete
	}

	Write-Output ""
	Write-Output "============================================================================================="
	Write-Output "   DONE, it might be a good idea to reboot now!"
	Write-Output "============================================================================================="

} else {
	Write-Output ""
	Write-Output "============================================================================================="
	Write-Output "   Nothing was done, exiting"
	Write-Output "============================================================================================="
}
