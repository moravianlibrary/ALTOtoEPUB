##########################
#Input parameters
##########################
param
(
    [string]$pathToOutFolder = "NO PATH TO OUT FOLDER",
    [string]$pathToINFolder = "NO PATH TO IN FOLDER",
    [string]$pathToScripts = "NO PATH TO SCRIPT FOLDER"
)

#create File Name
[xml]$Mods = Get-Content $pathToINFolder"MODS/MODS.xml" -Encoding UTF8
$TitleName = $Mods.modsCollection.mods.titleinfo.title[0]

#clean name from caracters
$TitleName = ($TitleName -replace '[\W]', ' ').trim() -replace ' ', '_'

#copy template epubfile
Copy-Item -Path ($PathToScripts +"DATA/TemplateEpub/template.zip") -Destination ($pathToOutFolder + $TitleName + ".zip")

Compress-Archive -path ($pathToOutFolder + "OEBPS") -DestinationPath ($pathToOutFolder + $TitleName + ".zip") -Update

Rename-Item -Path ($pathToOutFolder + $TitleName + ".zip") ($pathToOutFolder + $TitleName + ".epub")
