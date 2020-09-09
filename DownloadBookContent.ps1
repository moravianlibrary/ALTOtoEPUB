$titleUUID = "uuid:8db80bf0-3f20-11e4-bc3a-005056827e51"
$pathToInFolder = "E:\EPUB\IN\" 
$pagecounter = 0
$KramAPI ="https://kramerius.mzk.cz/search/api/v5.0/item/"

#$html = "$KramAPI$titleUUID/children"
$json = Invoke-WebRequest "$KramAPI$titleUUID/children" | ConvertFrom-Json



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
$contentPageTitlePage = ([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$PageTitlePage+"/streams/TEXT_OCR")).RawContentStream.ToArray()))

Echo $contentPageTitlePage > $pathToInFolder$pagecounter"_TitlePage.txt"

return 
}

function NormalPage
{
param ([string]$PageNormalPage)
#NUtne p5eformatovani na UTF 8 -funguje i na ALTO
$contentPageNormalPage = ([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$PageNormalPage+"/streams/TEXT_OCR")).RawContentStream.ToArray()))

Echo $contentPageNormalPage > $pathToInFolder$pagecounter"_NormalPage.txt"

return 
}

function TableOfContents
{
param ([string]$PageTableOfContents)
#NUtne p5eformatovani na UTF 8 -funguje i na ALTO
$contentPageTableOfContents = ([system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest ($KramAPI+$PageTableOfContents+"/streams/TEXT_OCR")).RawContentStream.ToArray()))

Echo $contentPageTableOfContents > $pathToInFolder$pagecounter"_TableOfContents.txt"

return 
}

###################################################################
#Main
###################################################################

$json |foreach -Process {
$page = $_

#write prograssbar
Write-Progress -Activity "Progres on $titleUUID " -Status "Line $pagecounter of $($json.Count)" -PercentComplete ((($pagecounter  / $json.Count) * 100) - 1)

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


$pagecounter++ 
}
}
#Write-Host $_.PID}




