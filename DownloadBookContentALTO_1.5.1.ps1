#zidi brno$titleUUID = "uuid:dda0be20-9521-11ea-830f-005056827e51"
#ma biogeneticka$titleUUID= "uuid:dc03bf10-4745-11ea-9ac7-005056827e51"
$titleUUID= "uuid:657c8240-b625-11e2-b6da-005056827e52"
#$titleUUID = "uuid:9a038280-10af-11e4-8e0d-005056827e51"
#$titleUUID = "uuid:8db80bf0-3f20-11e4-bc3a-005056827e51"
$pathToINFolder = "E:/EPUB/IN/" 
$pathToMAPCSV = $pathToInFolder+"MAP/UUIDmap.csv"
$pathToMODS = $pathToINFolder +"MODS/MODS.xml"
$Fullpagecounter = 0
$KramAPI ="https://kramerius.mzk.cz/search/api/v5.0/item/"

#$html = "$KramAPI$titleUUID/children"
$json = Invoke-WebRequest "$KramAPI$titleUUID/children" | ConvertFrom-Json

Write-Output '"UUID","PATH","PAGENO"' > $pathToMAPCSV

function CounterExtender
{
[string]$ExtendPageCounter = $Fullpagecounter

switch ($ExtendPageCounter.Length)
{
1 { $ExtendPageCounter = "0000"+$ExtendPageCounter}
2 { $ExtendPageCounter = "000"+$ExtendPageCounter}
3 { $ExtendPageCounter = "00"+$ExtendPageCounter}
4 { $ExtendPageCounter = "0"+$ExtendPageCounter}
5 { $ExtendPageCounter}
}

return $ExtendPageCounter
}


#####################

function FrontCover
{
param ($PageFrontCover)

return 
}
#####################

function TitlePage
{
param ([string]$PageTitlePage, [string] $NumberTitlePage)
#NUtne p5eformatovani na UTF 8 -funguje i na ALTO
$contentPageTitlePage = ([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$PageTitlePage+"/streams/ALTO")).RawContentStream.ToArray()))

$pagecounter = CounterExtender 
Write-Output $contentPageTitlePage > $pathToInFolder$pagecounter"_TitlePageALTO.xml"
$PageTitlePage= '"'+$PageTitlePage
#echo $PageTitlePage'","'$pagecounter'_TitlePageALTO.xml","'$NumberTitlePage'"' >> $pathToMAPCSV
Write-Output $PageTitlePage'","'$pagecounter'_TitlePageALTO.xml"' >> $pathToMAPCSV

return 
}

function NormalPage
{
param ([string]$PageNormalPage, [int] $NumberNormalPage)
#NUtne p5eformatovani na UTF 8 -funguje i na ALTO
$contentPageNormalPage = ([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$PageNormalPage+"/streams/ALTO")).RawContentStream.ToArray()))

$pagecounter = CounterExtender 
Write-Output $contentPageNormalPage > $pathToInFolder$pagecounter"_NormalPageALTO.xml"
$PageNormalPage = '"'+$PageNormalPage
Write-Output $PageNormalPage'","'$pagecounter'_NormalPageALTO.xml","'$NumberNormalPage'"' >> $pathToMAPCSV

return 
}

function TableOfContents
{
param ([string]$PageTableOfContents, [int] $NumberTableOfContents)
#NUtne p5eformatovani na UTF 8 -funguje i na ALTO
$contentPageTableOfContents = ([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$PageTableOfContents+"/streams/ALTO")).RawContentStream.ToArray()))

$pagecounter = CounterExtender 
Write-Output $contentPageTableOfContents > $pathToInFolder$pagecounter"_TitleTableOfContentsAlto.xml"
$PageTableOfContents='"'+$PageTableOfContents
Write-Output $PageTableOfContents'","'$pagecounter'_TitleTableOfContentsAlto.xml","'$NumberTableOfContents'"' >> $pathToMAPCSV

return 
}

###################################################################
#Main
###################################################################

#mods download
########################
([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$titleUUID+"/streams/BIBLIO_MODS")).RawContentStream.ToArray())) | Out-File -FilePath $pathToMODS -Encoding utf8
########################

$json |ForEach-Object -Process {
$page = $_

#


#if public
if ($page.policy -eq 'public') {

#hide download progres
$ProgressPreference = 'SilentlyContinue'

Switch ($page.details.type)
{
{$_ -match "Frontcover"}{ }
{$_ -match "TitlePage"}{TitlePage -PageTitlePage $page.PID -NumberTitlePage ($page.details.pagenumber).Substring(0, (([string]($page.details.pagenumber)).Length -27))
break}
{$_ -match "NormalPage"}{if (([string]$page.details.pagenumber) -notmatch ']') {NormalPage -PageNormalPage $page.PID -NumberNormalPage ($page.details.pagenumber).Substring(0, (([string]($page.details.pagenumber)).Length -27))}
break}
{$_ -match "TableOfContents"}{TableOfContents -PageTableOfContents $page.PID -NumberTableOfContents ($page.details.pagenumber).Substring(0, (([string]($page.details.pagenumber)).Length -27))
break}
}

$Fullpagecounter++ 
#unhive progres
$ProgressPreference = 'Continue' 
#write prograssbar
Write-Progress -Activity "Progres on $titleUUID " -Status "XML ALTO File $Fullpagecounter of $($json.Count)" -PercentComplete ((($Fullpagecounter / $json.Count) * 100))

}
}
