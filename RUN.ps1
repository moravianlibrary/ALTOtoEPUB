$pathToINFolder = "C:/EPUB/IN/"
$pathToOutFolder = "C:/EPUB/out/"
$PathToScripts = "C:/Users/dolejsd/Desktop/PS/"
$UUID = "uuid:f215b1d0-0c4b-11ea-a20e-005056827e51"

Remove-Item $pathToINFolder*.xml
Remove-Item $pathToINFolder"map/"*.*
Remove-Item $pathToOutFolder"/OEBPS/Images/"*.jpg


Invoke-Expression $PathToScripts"DownloadBookContentALTO_1.5.3.ps1 -pathToINFolder $pathToINFolder -titleUUID $UUID"
Invoke-Expression $PathToScripts"PreScanXML_0.1.ps1"
Invoke-Expression $PathToScripts"ReadFromXMLToObject_1.7.5.ps1 -pathToINFolder $pathToINFolder"
Invoke-Expression $PathToScripts"CheckFotPageNumberAltoObject1.1.ps1"
Invoke-Expression $PathToScripts"CheckFotLabelObject0.3.ps1"
Invoke-Expression $PathToScripts"CheckFotTitleAltoObject0.6.ps1"
Invoke-Expression $PathToScripts"DownloadBookContentImages_0.4.ps1 -pathToINFolder $pathToINFolder -pathToOutFolder $pathToOutFolder"
Invoke-Expression $PathToScripts"Make-EpubFromALTOXML1.7.3.ps1 -pathToINFolder $pathToINFolder -pathToOutFolder $pathToOutFolder -uuid $UUID"
Invoke-Expression $PathToScripts"Make-Content_OPF_0.3.ps1 -pathToOutFolder $pathToOutFolder -uuid $UUID"

#C:\Scripts\PS\PreScanXML_0.1.ps1
#C:\Scripts\PS\ReadFromXMLToObject_1.7.4.ps1
#C:\Scripts\PS\CheckFotPageNumberAltoObject1.1.ps1
#C:\Scripts\PS\CheckFotLabelObject0.3.ps1
#C:\Scripts\PS\CheckFotTitleAltoObject0.6.ps1
#C:\Scripts\PS\DownloadBookContentImages_0.3.ps1
#C:\Scripts\PS\Make-EpubFromALTOXML1.7.2.ps1
#C:\Scripts\PS\Make-Content_OPF_0.1.ps1