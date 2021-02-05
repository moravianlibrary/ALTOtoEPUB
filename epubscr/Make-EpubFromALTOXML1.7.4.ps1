##########################
#Input parameters
##########################
param
(
    [string]$pathToOutFolder = "NO PATH TO OUT FOLDER",
    [string]$pathToINFolder = "NO PATH TO IN FOLDER",
    [string]$UUID = "NO UUID"
)

[xml]$Mods = Get-Content $pathToINFolder"MODS/MODS.xml" -Encoding UTF8

$Titles = @()
$FileHTML = @()
$GLobal:FileHtmlCount = 0
$PathToHTML = $pathToOutFolder+"OEBPS/Text/"
$Title = $mods.modsCollection.mods.titleinfo.title[0]
$FileHtmlName = "NovyMake-html"
$pagebefore =""

$HEAD= @" 
<?xml version='1.0' encoding='utf-8'?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$Title</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<link href="../Styles/stylesheet.css" rel="stylesheet" type="text/css"/>
<link href="../Styles/page_styles.css" rel="stylesheet" type="text/css"/>
</head>
<body class="calibre">
"@
$END = @"
<p class="calibre4" style="margin:0pt; border:0pt; height:1em"> </p><div class="mbppagebreak" id="calibre_pb_"></div>
</body></html>
"@


function CounterExtender
{
[string]$ExtendPageCounter = $GLobal:FileHtmlCount

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


##########################################
#Prepare first name for HTML
$FileHtmlCountExtend = CounterExtender


###MAIN
#############################################################################################################
$Global:Book | Sort-Object {$_.page.uuidmap.path}, LIneVPOS  | ForEach-Object -Process {

#chceck if it is first one page and create firs Title
if ($Titles.Count -eq '0'){
if (($_.Type -notmatch "PageNumber") -and ($_.Type -notmatch "Label") ){
$Titles += $_
#####################################################
#add First Title
$FileHTML += $_.Prefix 
$_.word | ForEach-Object -Process {
$FileHTML +=($_.SubPrefix+$_.String+$_.SubSufix)
}
$FileHTML +=$_.Suffix
#####################################################
}
}
else{ 
if ($_.type -match "Title"){
#two titles on page.
if ($_.page.UUIDMAP.UUID -ne ($Titles|Select-Object -Last 1).page.UUIDMAP.UUID){
$Titles += $_ 

$FileHTML = $HEAD+$FileHTML+$END
$FileHTML |Out-File -FilePath $PathToHTML$FileHtmlCountExtend.html -Encoding utf8
$GLobal:FileHtmlCount ++
$FileHtmlCountExtend = CounterExtender
$FileHTML =@()
#####################################################
#add Title to Page
$FileHTML += $_.Prefix 
$_.word | ForEach-Object -Process {
$FileHTML +=($_.SubPrefix+$_.String+$_.SubSufix)
}
$FileHTML +=$_.Suffix
#####################################################
}
else{
#####################################################
#add duplicate doubled title
$FileHTML += $_.Prefix 
$_.word | ForEach-Object -Process {
$FileHTML +=($_.SubPrefix+$_.String+$_.SubSufix)
}
$FileHTML +=$_.Suffix
#####################################################
}
}
else {
#add second and more block
if (($_.Type -notmatch "PageNumber") -and ($_.Type -notmatch "Label") -and ($Titles.Count -ne '0') ){
$FileHTML += $_.Prefix
$_.word | ForEach-Object -Process {
$FileHTML +=($_.SubPrefix+$_.String+$_.SubSufix)
}
$FileHTML +=$_.Suffix
}
}
}
}
##############################################################################################################
##############################################################################################################


#####################
$FileHTML = $HEAD+$FileHTML+$END
$FileHtmlCountExtend = CounterExtender
$FileHTML |Out-File -FilePath $PathToHTML$FileHtmlCountExtend.html -Encoding utf8