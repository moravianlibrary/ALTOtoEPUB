##########################
#Input parameters
##########################
param
(
    [string]$UUID = "NO UUID"
)


$pathToINFolder = "C:/temp/IN/"+$UUID+"/"
$pathToOutFolder = "C:/temp/OUT/"+$UUID+"/"
$PathToScripts = "C:/temp/epubscr/"
$UUID = "uuid:"+$UUID

#Remove-Item $pathToINFolder*.xml
#Remove-Item $pathToINFolder"map/"*.*
#Remove-Item $pathToOutFolder"/OEBPS/Images/"*.jpg


Invoke-Expression $PathToScripts"Make-WorkFolders_0.0.1.ps1 -pathToINFolder $pathToINFolder -pathToOutFolder $pathToOutFolder -uuid $UUID"
Invoke-Expression $PathToScripts"DownloadBookContentALTO_1.5.3.ps1 -pathToINFolder $pathToINFolder -titleUUID $UUID"
Invoke-Expression $PathToScripts"PreScanXML_0.2.ps1 -pathToINFolder $pathToINFolder" 
Invoke-Expression $PathToScripts"ReadFromXMLToObject_1.7.7.ps1 -pathToINFolder $pathToINFolder"
Invoke-Expression $PathToScripts"CheckFotPageNumberAltoObject1.1.ps1"
Invoke-Expression $PathToScripts"CheckFotLabelObject0.3.ps1"
Invoke-Expression $PathToScripts"CheckFotTitleAltoObject0.6.ps1"
Invoke-Expression $PathToScripts"DownloadBookContentImages_0.4.ps1 -pathToINFolder $pathToINFolder -pathToOutFolder $pathToOutFolder"
Invoke-Expression $PathToScripts"Make-EpubFromALTOXML1.7.4.ps1 -pathToINFolder $pathToINFolder -pathToOutFolder $pathToOutFolder -uuid $UUID"
Invoke-Expression $PathToScripts"Make-Content_OPF_0.4.1.ps1 -pathToOutFolder $pathToOutFolder -uuid $UUID"
Invoke-Expression $PathToScripts"WrapEpub_0.0.2.ps1 -pathToINFolder $pathToINFolder -pathToOutFolder $pathToOutFolder -pathToScripts $PathToScripts"

