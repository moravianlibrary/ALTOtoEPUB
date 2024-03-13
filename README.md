# ALTOtoEPUB

Install Powershell 7.1 or later (WrapEpub_x.x.x.ps1 does not work properly with older versions and your .epub will be unreadable by some programs and readers) 

on Windows  
https://github.com/PowerShell/PowerShell/releases/latest

or Linux
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1


Downolad "epubscr" folder 

In /epubscr/RUN_x.x.x.ps1 edit:
1) $pathToINFolder = "YOUR_PATH/"+$UUID+"/"     must be unique! 
2) $pathToOutFolder = "YOUR_PATH/"+$UUID+"/"    must be unique!
3) $$PathToScripts = "PATH_TO_epubscr_FOLDER"




Run the script:
In Powershell cd to "epubscr" run with parametr "-UUID"

For example ./RUN_0.0.5.ps1 -UUID f215b1d0-0c4b-11ea-a20e-005056827e51
