# Stop on errors
$ErrorActionPreference = 'stop'

# Parse some arguments and set some variables.
$installerName = $args[0]
$cygwinArch = $args[1]
$installerURL = "http://cygwin.com/$installerName"
$cygwinRoot = 'c:\cygwin'
$cygwinMirror ="http://cygwin.mirror.constant.com"

if($installerName -eq $null)
 {
	 $thisScript = $MyInvocation.MyCommand.Name
     Write-Host "Cygwin installer name is not specified. Please choose an appropriate name based on http://cygwin.com/<installer_name>
For example:
	$thisScript setup-x86_64.exe <arch>"
	 exit 1
 }
 
 if($cygwinArch -eq $null)
 {
	 $thisScript = $MyInvocation.MyCommand.Name
     Write-Host " Mingw architecture is not specified. Please choose an appropriate name based on mingw64-<arch>-clang.
For example:
	$thisScript <installer_name> x86_64"
	 exit 1
 }

# Download the cygwin installer.
echo "Downloading the Cygwin installer from $installerURL"
Invoke-WebRequest -UseBasicParsing -URI "$installerURL" -OutFile "$installerName"

# Install cygwin and the required packages.
echo "Installing Cygwin packages"
& ".\$installerName" -dgnqNO -R "$cygwinRoot" -s "$cygwinMirror" -l "$cygwinRoot\var\cache\setup" `
    -P make `
    -P cmake `
    -P zip `
    -P mingw64-$cygwinArch-clang `
    -P unzip `
    -P wget `
    -P git `
    -P autoconf2.5 `
    -P autoconf `
    -P automake1.16 `
    -P automake `
    -P libtool `
    -P patch | Out-Null

echo "Cygwin installed under $cygwinRoot"
