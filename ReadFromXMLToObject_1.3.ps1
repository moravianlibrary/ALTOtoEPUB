#iniciate settings
$InFolder = "E:\EPUB\IN\"


#iniciate main object
$countBlock = 0
$Global:Book = @()
$InputFiles = (Get-ChildItem $InFolder -Filter *.xml | select name)
$Global:BookPointer = -1

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
$xml = $Alto.alto.Layout.Page.PrintSpace


##############################
#controll if TextBlock in ALto - 
##############################
if ($xml.textblock){

#iniciate page object
$altoTextBlockCount = @($xml.TextBlock).count -1

$Global:BookWordpointer = 0

###############################
#Make NewTextblock HTML object
###############################
function MakeTextObjectHTML {
param ([string]$AlignTextBlockHTML, [string]$FontTextBlock, [int]$LineVPOS )
$Global:BookPointer++
$Global:BookWordpointer = 0
switch ($AlignTextBlockHTML) 
{
{$_ -match 'Block'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              PageName = $file
                                              LineVPOS = $LineVPOS
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
                                              PageName = $file
                                              LineVPOS = $LineVPOS
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
                                              PageName = $file
                                              LineVPOS = $LineVPOS
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
                                              PageName = $file
                                              LineVPOS = $LineVPOS
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
$WordTextblock
return
}




#####################################################################################################
#####################################################################################################

##Cycle for Texblocks
$xml.TextBlock|ForEach-Object -Process {

$xmlTextBlock = $_
#If text in textblock process
#if (){}

$altoLineCount = @($_.TextLine).count -1

##block Style and Font
$TextBlockStyle = $Alto.alto.Styles.ParagraphStyle | Where-Object {$xmlTextBlock.STYLEREFS -match $_.ID}
$TextBlockFont = $Alto.alto.Styles.TextStyle | Where-Object {$xmlTextBlock.STYLEREFS -match $_.ID}

MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.ID -LineVPOS 10

##################################################################################################
#Cycle fo Line in texblock
$xmlTextBlock.Textline|ForEach-Object -Process {
$xmlTextLine = $_

#average of begin position of all lines in ALTO text block 
$TextBlockAverage = ($xmlTextBlock.Textline | Measure-Object HPOS -Average).Average
    $TexLineVPOS =[int] $xmlTextLine.VPOS
# if line offset 13%
if  ($xmlTextLine.HPOS/($TextBlockAverage/100) -ge 113 ){
    
    MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.ID -LineVPOS $TexLineVPOS

}
#$counter = 0
#################################################################################################
$xmlTextLine.String | ForEach-Object -Process {




# check fo - on end of line
if (($_.SUBS_CONTENT -eq $null) -or($Global:SubsContent -eq $true) ){
    $Global:SubsContent =$false
    WriteTextObjectHTML -WordTextblock $_.CONTENT -StyleWordHTML $false
   
}
Else {
    Write-Host " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" $_.String 
    $Global:SubsContent =$true
    WriteTextObjectHTML -WordTextblock $_.SUBS_CONTENT -StyleWordHTML $false
}
}
}
}
}
#end of file reading
}