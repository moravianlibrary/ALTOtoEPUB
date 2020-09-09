#iniciate settings
$InFolder = "E:\EPUB\IN\"


#iniciate main object
$countBlock = 0
$Global:Book = @()
$InputFiles = (Get-ChildItem $InFolder -Filter *.xml | select name)

#############################################################################
#Reading downloaded files####################################################
foreach($file in $InputFiles ) {
$file
#set path to XML
$PathToXML = $InFolder+$File.name


#vystup pro titulni stranku a obsahovou atd...
#if ($file -match "Title")

[xml]$Alto = Get-Content $PathToXML -Encoding UTF8

#shortened object notation 
[xml]$xml = $Alto


##############################
#controll if TextBlock in ALto - 
##############################
if ($xml.alto.Layout.page.PrintSpace.textblock){

#iniciate page object
$altoTextBlockCount = @($xml.alto.Layout.Page.PrintSpace.TextBlock).count -1
$Global:BookPointer = -1
$Global:BookWordpointer = 0

###############################
#Make NewTextblock HTML object
###############################
function MakeTextObjectHTML {

param ([string]$AlignTextBlockHTML, [string]$FontTextBlock )
$Global:BookPointer++
$Global:BookWordpointer = 0
switch ($AlignTextBlockHTML) 
{
{$_ -match 'Block'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              Prefix = [string] '<p class="calibre9">'
                                              SubPrefix =$null
                                              String = $null
                                              SubSufix =$null
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -match 'Left'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              Prefix = [string] '<p class="calibre9">'
                                              SubPrefix =$null
                                              String = $null
                                              SubSufix =$null
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -match 'Right'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              Prefix = [string] '<p class="calibre15">'
                                              SubPrefix =$null
                                              String = $null
                                              SubSufix =$null
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -match 'Center'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              Prefix = [string] '<p class="calibre1">'
                                              SubPrefix =$null
                                              String = $null
                                              SubSufix =$null
                                              Suffix = [string] '</p>'
                                             }
}
}
return 
}



###############################
#Write to NewTextblock HTML object
###############################
function WriteTextObjectHTML {

param ([string] $WordTextblock, $StyleWordHTML )

if ($StyleWordHTML){ 
    $LastWord = ($Global:Book[$Global:BookPointer] | Select-Object -Last 1)

    if ($LastWord.SubPrefix -match $StyleWordHTML ) {
    ($Global:Book[$Global:BookPointer].Word | Select-Object -Last 1).FormatSuffix = $null
    $Global:Book[$Global:BookPointer].Word.FormatSuffix = '</span>'
    }
    else{
    $Global:Book[$Global:BookPointer].Word.FormatPrefix = '<span class="'+$StyleWordHTML+'">'
    $Global:Book[$Global:BookPointer].Word.FormatSuffix = '</span>' }
}
#$Global:Book[$Global:BookPointer].Word[$Global:BookWordpointe - 1].String
$Global:Book[$Global:BookPointer].String += ($WordTextblock + " ")

#echo processed word
#$WordTextblock
return
}





#####################################################################################################
For ($altoTextBlock=0; $altoTextBlock -le $altoTextBlockCount; $altoTextBlock++) {

$altoLineCount = @($xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].TextLine).count -1

##block Style and Font
$TextBlockStyle = $xml.alto.Styles.ParagraphStyle | Where-Object {$xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].STYLEREFS -match $_.ID}
$TextBlockFont = $xml.alto.Styles.TextStyle | Where-Object {$xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].STYLEREFS -match $_.ID}

MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.ID

##################################################################################################
For ($altoLine=0; $altoline -le $altoLineCount; $altoLine++) {


#average of begin position of all lines in ALTO text block 
$TextBlockAverage = ($xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].TextLine | Measure-Object HPOS -Average).Average

# if line offset 13%
if  ($xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].TextLine[$altoLine].HPOS/($TextBlockAverage/100) -ge 113 ){
    
    MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.ID 

}
#$counter = 0
#################################################################################################
$xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].TextLine[$altoLine].String | ForEach-Object -Process {


# check fo - on end of line
if (($_.SUBS_CONTENT -eq $null) -or($Global:SubsContent -eq $true) ){
    $Global:SubsContent =$false
    WriteTextObjectHTML -WordTextblock $_.CONTENT -StyleWordHTML $false
   
}
Else {
    Write-Host " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" $_.String 
    $Global:SubsContent =$true
    WriteTextObjectHTML -WordTextblock $_.SUBS_CONTENT
}
}
}
}
}
#end of file reading
}