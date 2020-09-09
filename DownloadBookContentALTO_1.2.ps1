#testovaci $titleUUID = "uuid:9a038280-10af-11e4-8e0d-005056827e51"
$titleUUID = "uuid:8db80bf0-3f20-11e4-bc3a-005056827e51"
$pathToOutFolder = "E:/EPUB/out/" 
$pathToMAPCSV = $pathToInFolder+"MAP/UUIDmap.csv"
$Fullpagecounter = 0
$KramAPI ="https://kramerius.mzk.cz/search/api/v5.0/item/"

#$html = "$KramAPI$titleUUID/children"
$json = Invoke-WebRequest "$KramAPI$titleUUID/children" | ConvertFrom-Json

echo '"UUID","PATH"' > $pathToMAPCSV

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
param ([string]$PageTitlePage)
#NUtne p5eformatovani na UTF 8 -funguje i na ALTO
$contentPageTitlePage = ([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$PageTitlePage+"/streams/ALTO")).RawContentStream.ToArray()))

$pagecounter = CounterExtender 
Echo $contentPageTitlePage > $pathToInFolder$pagecounter"_TitlePageALTO.xml"
$PageTitlePage= '"'+$PageTitlePage
echo $PageTitlePage'","'$pagecounter'_TitlePageALTO.xml"' >> $pathToMAPCSV

return 
}

function NormalPage
{
param ([string]$PageNormalPage)
#NUtne p5eformatovani na UTF 8 -funguje i na ALTO
$contentPageNormalPage = ([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$PageNormalPage+"/streams/ALTO")).RawContentStream.ToArray()))

$pagecounter = CounterExtender 
Echo $contentPageNormalPage > $pathToInFolder$pagecounter"_NormalPageALTO.xml"
$PageNormalPage = '"'+$PageNormalPage
echo $PageNormalPage'","'$pagecounter'_NormalPageALTO.xml"' >> $pathToMAPCSV

return 
}

function TableOfContents
{
param ([string]$PageTableOfContents)
#NUtne p5eformatovani na UTF 8 -funguje i na ALTO
$contentPageTableOfContents = ([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$PageTableOfContents+"/streams/ALTO")).RawContentStream.ToArray()))

$pagecounter = CounterExtender 
Echo $contentPageTableOfContents > $pathToInFolder$pagecounter"_TitleTableOfContentsAlto.xml"
$PageTableOfContents='"'+$PageTableOfContents
echo $PageTableOfContents'","'$pagecounter'_TitleTableOfContentsAlto.xml"' >> $pathToMAPCSV

return 
}

###################################################################
#Main
###################################################################

$json |foreach -Process {
$page = $_

#write prograssbar
Write-Progress -Activity "Progres on $titleUUID " -Status "Line $Fullpagecounter of $($json.Count)" -PercentComplete ((($Fullpagecounter / $json.Count) * 100) - 1)

#if public
if ($page.policy -eq 'public') {

Switch ($page.details.type)
{
{$_ -match "Frontcover"}{ }
{$_ -match "TitlePage"}{TitlePage -PageTitlePage $page.PID 
break}
{$_ -match "NormalPage"}{if (([string]$page.details.pagenumber) -notmatch ']') {NormalPage -PageNormalPage $page.PID }
break}
{$_ -match "TableOfContents"}{TableOfContents -PageTableOfContents $page.PID
break}
}


$Fullpagecounter++ 
}
}
