#iniciate settings
$InFolder = "E:/EPUB/IN/"


$UUIDMAP = Import-Csv -Path ($InFolder+"MAP/UUIDmap.csv") -Delimiter ',' -Encoding Default

#iniciate main object
$countBlock = 0
$Global:counterImage = 0
$Global:Book = @()
$Global:Images = @()
$InputFiles = (Get-ChildItem $InFolder -Filter *.xml | select name)
$Global:BookPointer = -1






#iniciate page object
$altoTextBlockCount = @($xml.TextBlock).count -1

$Global:BookWordpointer = 0

###############################
#Make NewTextblock HTML object
###############################
function MakeTextObjectHTML {
param ( [string]$AlignTextBlockHTML, [string]$FontTextBlock, [int]$FontTextBlockSize, [int]$LineVPOS )
$Global:BookPointer++
$Global:BookWordpointer = 0


switch ($AlignTextBlockHTML) 
{
{$_ -match 'Block'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              UID = [int] $Global:BookPointer
                                              PageName = $file.name
                                              LineVPOS = $LineVPOS
                                              Prefix = [string] '<p class="calibre9">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = @()
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -match 'Left'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              UID = [int] $Global:BookPointer
                                              PageName = $file.name
                                              LineVPOS = $LineVPOS
                                              Prefix = [string] '<p class="calibre9">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = @()
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -match 'Right'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              UID = [int] $Global:BookPointer
                                              PageName = $file.name
                                              LineVPOS = $LineVPOS
                                              Prefix = [string] '<p class="calibre15">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = @()
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -match 'Center'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              UID = [int] $Global:BookPointer
                                              PageName = $file.name
                                              LineVPOS = $LineVPOS
                                              Prefix = [string] '<p class="calibre1">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = @()
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -match 'Title'}{
$Global:counterImage++
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "Title"
                                              UID = [int] $Global:BookPointer
                                              PageName = $file.name
                                              LineVPOS = $LineVPOS
                                              Prefix = [string] '<p class="calibre1">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = [pscustomobject]@{
                                                SubPrefix = '<img src="'
                                                String = "images/$Global:counterImage.jpg"
                                                SubSufix ='" class="calibre6"/>'
                                                }
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -match 'Ilustration'}{
$Global:counterImage++
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "Ilustration"
                                              UID = [int] $Global:BookPointer
                                              PageName = $file.name
                                              LineVPOS = $LineVPOS
                                              Prefix = [string] '<p class="calibre1">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                               Word = [pscustomobject]@{
                                                SubPrefix = '<img src="'
                                                String = "images/$Global:counterImage.jpg"
                                                SubSufix ='" class="calibre6"/>'
                                                }
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -match 'ComposedBlock'}{
$Global:counterImage++
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "ComposedBlock"
                                              UID = [int] $Global:BookPointer
                                              PageName = $file.name
                                              LineVPOS = $LineVPOS
                                              Prefix = [string] '<p class="calibre1">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                               Word = [pscustomobject]@{
                                                SubPrefix = '<img src="'
                                                String = "images/$Global:counterImage.jpg"
                                                SubSufix ='" class="calibre6"/>'
                                                }
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


$StylewordPrefix = $null
$StylewordSufix = $null
if ($StyleWordHTML)
{$StylewordPrefix = '<span class="'+$StyleWordHTML+'">'
$StylewordSufix = '</span>'

#$Global:Book[$Global:BookPointer].Word[$Global:BookWordpointe - 1].String
    if ((($Global:Book[$Global:BookPointer].word | Select-Object -Last 1) -ne $null) -and (($Global:Book[$Global:BookPointer].word | Select-Object -Last 1).SubPrefix -eq $StylewordPrefix  ) ){

        ($Global:Book[$Global:BookPointer].word | Select-Object -Last 1).String += ($WordTextblock + " ")
    }
    else{
        $Global:Book[$Global:BookPointer].word += [pscustomobject]@{
                                              SubPrefix = $StylewordPrefix
                                              String = ($WordTextblock + " ")
                                              SubSufix = $StylewordSufix
                                              } 
    }
}
Else{

    If (($Global:Book[$Global:BookPointer].word | Select-Object -Last 1) -ne $null){

    ($Global:Book[$Global:BookPointer].word | Select-Object -Last 1).String += ($WordTextblock + " ")
    }
    Else {
    $Global:Book[$Global:BookPointer].word += [pscustomobject]@{
                                              SubPrefix = $null
                                              String = ($WordTextblock + " ")
                                              SubSufix = $null
                                              } 
    }
}
#echo word
##$WordTextblock
return
}

###################################
#Save Picture MAP
###################################
function SavePictureMAP {

param ([int]$HEIGHT,[int]$WIDTH,[int]$VPOS,[int]$HPOS )

#$ImageUUID = {$UUIDMAP | Where-Object {[string]$_.Path -match [string]$file.Name}}

$Global:Images += [pscustomobject]@{
                                              Type = [string] "Ilustration"
                                              Number = $Global:counterImage
                                              HEIGHT = $HEIGHT
                                              WIDTH = $WIDTH
                                              VPOS = $VPOS
                                              HPOS = $HPOS
                                              File = $file.name
                                              UUID = ($UUIDMAP | Where-Object {[string]$_.Path -match [string]$file.Name}).uuid
                                             }


}

###################################
#TextBlock Processing
###################################
function Textblockprocessing {

param ($xmlTextBlock)
##Cycle for Texblocks
Write-host $file.name -ForegroundColor white

########################################################################################################$xmlTextBlock = $_

#If text in textblock process
#if (){}

$altoLineCount = @($_.TextLine).count -1

##block Style and Font
$TextBlockStyle = $Alto.alto.Styles.ParagraphStyle | Where-Object {$xmlTextBlock.STYLEREFS -match $_.ID}
$TextBlockFont = $Alto.alto.Styles.TextStyle | Where-Object {$xmlTextBlock.STYLEREFS -match $_.ID}

MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.FONTFAMILY -FontTextBlockSize $TextBlockFont.FONTSIZE -LineVPOS 10

##################################################################################################
#Cycle of Line in texblock
$xmlTextBlock.Textline|ForEach-Object -Process {
$xmlTextLine = $_

#average of begin position of all lines in ALTO text block 
$TextBlockAverage = ($xmlTextBlock.Textline | Measure-Object HPOS -Average).Average
    $TexLineVPOS =[int] $xmlTextLine.VPOS
# if line offset 13%
if  ($xmlTextLine.HPOS/($TextBlockAverage/100) -ge 113 ){
    
    MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.FONTFAMILY -FontTextBlockSize $TextBlockFont.FONTSIZE -LineVPOS $TexLineVPOS

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


###################################################################################################
#Reading downloaded files##########################################################################
###################################################################################################
foreach($file in $InputFiles ) {
$file
#set path to XML
$PathToXML = $InFolder+$File.name




[xml]$Alto = Get-Content $PathToXML -Encoding UTF8

#shortened object notation 
$xml = $Alto.alto.Layout.Page.PrintSpace

######################################################################################################
#first selector
if ($file -notmatch "TitlePage"){

##############################
#controll if TextBlock in ALto - 
##############################
if ($xml.textblock){

$xml.TextBlock|ForEach-Object -Process { Textblockprocessing -xmlTextBlock $_  }


}#end of first selector



##############################
#controll if Ilustration in ALto - 
##############################
#doplnit pokud jsou na strance jen ilustrace stahnout celou...
if ($xml.Illustration ){

#in page only ilustration download all
if ((!$xml.ComposedBlock)-and(!$xml.TextBlock)){
Write-host $file.name -ForegroundColor DarkCyan
MakeTextObjectHTML -AlignTextBlockHTML "Ilustration" -FontTextBlock $null -LineVPOS $xml.VPOS

SavePictureMAP -HEIGHT $xml.HEIGHT -WIDTH $xml.WIDTH -VPOS $xml.VPOS -HPOS $xml.HPOS
}
else{
Write-host $file.name -ForegroundColor Cyan
$xml.Illustration | ForEach-Object {
$xmlIlustration = $_

#controll if image is not too small
if (([int]$xmlIlustration.HEIGHT -ge 200) -and ([int]$xmlIlustration.WIDTH -ge 200)){
MakeTextObjectHTML -AlignTextBlockHTML "Ilustration" -FontTextBlock $null -LineVPOS $xmlIlustration.VPOS

SavePictureMAP -HEIGHT $xmlIlustration.HEIGHT -WIDTH $xmlIlustration.WIDTH -VPOS $xmlIlustration.VPOS -HPOS $xmlIlustration.HPOS
}
}
}
}#end of control ilustration 
Else{
##############################
#controll if ComposedBlock in ALto - 
##############################
if ($xml.ComposedBlock){

if ((!$xml.textblock) -and (!$xml.Illustration)){
Write-host $file.name -ForegroundColor DarkMagenta

MakeTextObjectHTML -AlignTextBlockHTML "ComposedBlock" -FontTextBlock $null -LineVPOS $xmlComposedBlock.VPOS

SavePictureMAP -HEIGHT $xml.HEIGHT -WIDTH $xml.WIDTH -VPOS $xml.VPOS -HPOS $xml.HPOS

}
Else{
$xml.ComposedBlock | ForEach-Object {
$xmlComposedBlock = $_
Write-host $file.name -ForegroundColor RED

if ($xmlComposedBlock.textblock){

Write-host $file.name -ForegroundColor Magenta
##Cycle for Texblocks
$xmlComposedBlock.TextBlock|ForEach-Object -Process {Textblockprocessing -xmlTextBlock $_}
}

if ((!$xmlComposedBlock.textblock) -and ([int]$xmlComposedBlock.HEIGHT -ge 200) -and ([int]$xmlComposedBlock.WIDTH -ge 200)){

Write-host $file.name -ForegroundColor DarkRed

MakeTextObjectHTML -AlignTextBlockHTML "ComposedBlock" -FontTextBlock $null -LineVPOS $xmlComposedBlock.VPOS

#SavePictureMAP -HEIGHT -WIDTH -VPOS -HPOS

SavePictureMAP -HEIGHT $xml.HEIGHT -WIDTH $xml.WIDTH -VPOS $xml.VPOS -HPOS $xml.HPOS

#SavePictureMAP -HEIGHT $xmlComposedBlock.HEIGHT -WIDTH $xmlComposedBlock.WIDTH -VPOS $xmlComposedBlock.VPOS -HPOS $xmlComposedBlock.HPOS







}

}
}
}#end of control ComposedBlock
}#end of ilustration ELSE composed BLock
}#end of No match title or Table of contents
Else{
Write-host $file.name -ForegroundColor Yellow
MakeTextObjectHTML -AlignTextBlockHTML "Title" -FontTextBlock $null -LineVPOS 0 
SavePictureMAP -HEIGHT $xml.HEIGHT -WIDTH $xml.WIDTH -VPOS $xml.VPOS -HPOS $xml.HPOS
}
}#end of file reading
