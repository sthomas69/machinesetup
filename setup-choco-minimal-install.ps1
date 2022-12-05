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

Write-Output  "Intstalling minimal setup"
& choco install `
    7zip `
    cascadia-code-nerd-font `
    chocolateygui `
    git `
    oh-my-posh `
    microsoft-windows-terminal `
    pwsh `
	vscode `
    -y

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
