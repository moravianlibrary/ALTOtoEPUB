##########################
#Input parameters
##########################
param
(
    [string]$pathToOutFolder = "NO PATH TO OUT FOLDER",
    [string]$pathToINFolder = "NO PATH TO IN FOLDER",
    [string]$UUID = "NO UUID"
)

#copy template Filesystem
Copy-Item -Path ($pathToScripts +"DATA/TemplateWorkFolder/IN") -Destination $pathToINFolder -Recurse
Copy-Item -Path ($pathToScripts +"DATA/TemplateWorkFolder/OUT") -Destination $pathToOutFolder -Recurse
