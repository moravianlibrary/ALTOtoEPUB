﻿#iniciate settings

##########################
#Input parameters
##########################
param
(
    [string]$pathToINFolder = "NO PATH TO IN FOLDER"
)

$UUIDMAP = Import-Csv -Path ($pathToINFolder+"MAP/UUIDmap.csv") -Delimiter ',' -Encoding Default

#iniciate main object
#$countBlock = 0
$Global:counterImage = 0
$Global:Book = @()
$Global:Images = @()
$InputFiles = (Get-ChildItem $pathToINFolder -Filter *.xml | Select-Object name)
$Global:BookPointer = -1
$Global:Page = @()

#########################################################
#READ FROm prescan VALUE
#########################################################
$Global:LineSpaceAverage = $Global:PreScanXML.LineVPOSDifPercent | Measure-Object -Maximum -Minimum -Average
#########################################################

#iniciate page object
#$altoTextBlockCount = @($xml.TextBlock).count -1

$Global:BookWordpointer = 0

###############################
#Make Newblock HTML object
###############################
function MakeTextObjectHTML {
param ( [string]$AlignTextBlockHTML, [string]$FontTextBlock, [int]$FontTextBlockSize, [int]$LineVPOS )
$Global:BookPointer++
#$Global:BookWordpointer = 0

###############################################################################################################################################################################

switch ($AlignTextBlockHTML) 
{
{$_ -eq 'Block'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              UID = [int] $Global:BookPointer
                                              Page = ($Global:Page |Select-Object -Last 1)
                                              LineVPOS = $LineVPOS
                                              LineVPOSPercent = ([int]$LineVPOS /([int]($Global:Page |Select-Object -Last 1).HEIGHT /100))
                                              Prefix = [string] '<p class="calibre9">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = @()
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -eq 'Left'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              UID = [int] $Global:BookPointer
                                              Page = ($Global:Page |Select-Object -Last 1)
                                              LineVPOS = $LineVPOS
                                              LineVPOSPercent = ([int]$LineVPOS /([int]($Global:Page |Select-Object -Last 1).HEIGHT /100))
                                              Prefix = [string] '<p class="calibre9">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = @()
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -eq 'Right'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              UID = [int] $Global:BookPointer
                                              Page = ($Global:Page |Select-Object -Last 1)
                                              LineVPOS = $LineVPOS
                                              LineVPOSPercent = ([int]$LineVPOS /([int]($Global:Page |Select-Object -Last 1).HEIGHT /100))
                                              Prefix = [string] '<p class="calibre15">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = @()
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -eq 'Center'}{
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              UID = [int] $Global:BookPointer
                                              Page = ($Global:Page |Select-Object -Last 1)
                                              LineVPOS = $LineVPOS
                                              LineVPOSPercent = ([int]$LineVPOS /([int]($Global:Page |Select-Object -Last 1).HEIGHT /100))
                                              Prefix = [string] '<p class="calibre1">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = @()
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -eq 'TitlePage'}{
$Global:counterImage++
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "Title"
                                              UID = [int] $Global:BookPointer
                                              Page = ($Global:Page |Select-Object -Last 1)
                                              LineVPOS = $LineVPOS
                                              LineVPOSPercent = ([int]$LineVPOS /([int]($Global:Page |Select-Object -Last 1).HEIGHT /100))
                                              Prefix = [string] '<p class="calibre1">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                              Word = [pscustomobject]@{
                                                SubPrefix = '<img src="'
                                                String = "../Images/$Global:counterImage.jpg"
                                                SubSufix ='" class="calibre6"/>'
                                                }
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -eq 'Ilustration'}{
$Global:counterImage++
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "Ilustration"
                                              UID = [int] $Global:BookPointer
                                              Page = ($Global:Page |Select-Object -Last 1)
                                              LineVPOS = $LineVPOS
                                              LineVPOSPercent = ([int]$LineVPOS /([int]($Global:Page |Select-Object -Last 1).HEIGHT /100))
                                              Prefix = [string] '<p class="calibre1">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                               Word = [pscustomobject]@{
                                                SubPrefix = '<img src="'
                                                String = "../Images/$Global:counterImage.jpg"
                                                SubSufix ='" class="calibre6"/>'
                                                }
                                              Suffix = [string] '</p>'
                                             }
}
{$_ -eq 'ComposedBlock'}{
$Global:counterImage++
$Global:Book +=  [pscustomobject]@{
                                              Type = [string] "ComposedBlock"
                                              UID = [int] $Global:BookPointer
                                              Page = ($Global:Page |Select-Object -Last 1)
                                              LineVPOS = $LineVPOS
                                              LineVPOSPercent = ([int]$LineVPOS /([int]($Global:Page |Select-Object -Last 1).HEIGHT /100))
                                              Prefix = [string] '<p class="calibre1">'
                                              Font = $FontTextBlock
                                              FontSize = [int]$FontTextBlockSize
                                               Word = [pscustomobject]@{
                                                SubPrefix = '<img src="'
                                                String = "../Images/$Global:counterImage.jpg"
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


if ($null -ne $StyleWordHTML)
{
#possible change to format <blot italic> 
Switch ($StyleWordHTML)
{
{$_ -match 'bold'}{$StylewordPrefix += '<span class="bold">'
                   $StylewordSufix += '</span>'}

{$_ -match 'italic'}{$StylewordPrefix += '<span class="italic">'
                   $StylewordSufix += '</span>'}


}

#$Global:Book[$Global:BookPointer].Word[$Global:BookWordpointe - 1].String
    if (($null -ne ($Global:Book[$Global:BookPointer].word | Select-Object -Last 1)) -and ($Global:Book[$Global:BookPointer].Type -eq "TextBlock") -and (($Global:Book[$Global:BookPointer].word |
     Select-Object -Last 1).SubPrefix -eq $StylewordPrefix  ) ){
#write-host "++++++++++++++++++++++++++++++++++++++++++++++++++"$StyleWordHTML
#$StyleWordHTML
        ($Global:Book[$Global:BookPointer].word | Select-Object -Last 1).String += ($WordTextblock + " ")
    }
    else{
    #Write-Host "------------------------------------------------------------"
        $Global:Book[$Global:BookPointer].word += [pscustomobject]@{
                                              SubPrefix = $StylewordPrefix
                                              String = ($WordTextblock + " ")
                                              SubSufix = $StylewordSufix
                                              } 
    }
}
Else{

    If (($null -ne ($Global:Book[$Global:BookPointer].word | Select-Object -Last 1)) -and (($null -eq ($Global:Book[$Global:BookPointer].word |
     Select-Object -Last 1).SubPrefix  ))-and $Global:Book[$Global:BookPointer].Type -eq "TextBlock" ){

   # Write-Host "000000000000000000000000000000000000000000000000000000000000000"
    ($Global:Book[$Global:BookPointer].word | Select-Object -Last 1).String += ($WordTextblock + " ")
    }
    Else {#Write-Host  "1111111111111111111111111111111111111111111111111111111111111111111111"
    $Global:Book[$Global:BookPointer].word += [pscustomobject]@{
                                              SubPrefix = $null
                                              String = ($WordTextblock + " ")
                                              SubSufix = $null
                                              } 
    }
}
 #Write-Host "###################################################################################################################################################################"
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


#$xmlLineCount = @($xmlTextBlock.TextLine).count 

##block Style and Font
$TextBlockStyle = $Alto.alto.Styles.ParagraphStyle | Where-Object {$xmlTextBlock.STYLEREFS -match $_.ID}
$TextBlockFont = $Alto.alto.Styles.TextStyle | Where-Object {$xmlTextBlock.STYLEREFS -match $_.ID}

MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.FONTFAMILY -FontTextBlockSize $TextBlockFont.FONTSIZE -LineVPOS $xmlTextBlock.VPOS

#init Line space scale
$LineVPOSbefore =$null
$LinevPOSafter = $null
$NewTextBlockObject = $false

##################################################################################################
#Cycle of Line in texblock
$xmlTextBlock.Textline|ForEach-Object -Process {
$xmlTextLine = $_

#Load Copare Vpos
$LineVPOSbefore = $LinevPOSafter
$LinevPOSafter = $xmlTextLine.VPOS

#([int]$xmlTextLine.VPOS/([int]($Global:Page |Select-Object -Last 1).HEIGHT /100))


If ($LineVPOSbefore){
If ((($LinevPOSafter - $LineVPOSbefore)/([int]($Global:Page |Select-Object -Last 1).HEIGHT /100)) -ge ($Global:LineSpaceAverage.Average * 1.5)){
$NewTextBlockObject = $true}
}

#average of begin position of all lines in ALTO text block 
$TextBlockAverage = ($xmlTextBlock.Textline | Measure-Object HPOS -Average).Average
    $TexLineVPOS =[int] $xmlTextLine.VPOS
# if line offset 13%
if  (($xmlTextLine.HPOS/($TextBlockAverage/100) -ge 113) -or ($NewTextBlockObject) ){
    $NewTextBlockObject = $false
    MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.FONTFAMILY -FontTextBlockSize $TextBlockFont.FONTSIZE -LineVPOS $TexLineVPOS

}
#$counter = 0
#################################################################################################
$xmlTextLine.String | ForEach-Object -Process {




# check fo - on end of line

if ($_.SUBS_TYPE){
if ($_.SUBS_TYPE -eq "HypPart1") {}
else {WriteTextObjectHTML -WordTextblock $_.SUBS_CONTENT -StyleWordHTML $_.STYLE}
#Write-Host "ROZDeLENE SLOVO" $_.content

}
Else {WriteTextObjectHTML -WordTextblock $_.CONTENT -StyleWordHTML $_.STYLE}



#OLD word split check
#if (($null -eq $_.SUBS_CONTENT) -or($Global:SubsContent -eq $true) ){
#    $Global:SubsContent =$false
#    WriteTextObjectHTML -WordTextblock $_.CONTENT -StyleWordHTML $_.STYLE
   
#}
#Else {
    #Write-Host "+" $_.String 
#    $Global:SubsContent =$true
#    WriteTextObjectHTML -WordTextblock $_.SUBS_CONTENT -StyleWordHTML $_.STYLE
#}
}
}
return
}


###################################################################################################
#Reading downloaded files##########################################################################
###################################################################################################
foreach($file in $InputFiles ) {
#set path to XML
$PathToXML = $pathToINFolder+$File.name

[xml]$Alto = Get-Content $PathToXML -Encoding UTF8

#shortened object notation 
$xml = $Alto.alto.Layout.Page.PrintSpace



####################
#New Page Object 
####################
$Global:Page +=            [pscustomobject]@{
                                              Type = [string] "TextBlock"
                                              File = $file.Name
                                              UUIDMAP =  ($UUIDMAP|where-object {$_.path -eq $file.name})
                                              HEIGHT = $xml.HEIGHT
                                              WIDTH = $xml.WIDTH
                                              VPOS = $xml.VPOS
                                              HPOS = $xml.HPOS
                                             }


###################################################################################################
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

if ((!$xml.textblock) -and (!$xml.Illustration) -and (!$xml.ComposedBlock.TextBlock)){
Write-host $file.name -ForegroundColor DarkMagenta

MakeTextObjectHTML -AlignTextBlockHTML "ComposedBlock" -FontTextBlock "555" -LineVPOS $xmlComposedBlock.VPOS

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

if ($xmlComposedBlock.Illustration){
Write-host $file.name -ForegroundColor DarkCyan

$xmlComposedBlock.Illustration | ForEach-Object -Process {
$composedBlockIlustration = $_
MakeTextObjectHTML -AlignTextBlockHTML "Ilustration" -FontTextBlock $null -LineVPOS $composedBlockIlustration.VPOS

#SavePictureMAP -HEIGHT -WIDTH -VPOS -HPOS

SavePictureMAP -HEIGHT $composedBlockIlustration.HEIGHT -WIDTH $composedBlockIlustration.WIDTH -VPOS $composedBlockIlustration.VPOS -HPOS $composedBlockIlustration.HPOS
}
}

if ((!$xmlComposedBlock.textblock) -and (!$xmlComposedBlock.Illustration) -and  ([int]$xmlComposedBlock.HEIGHT -ge 200) -and ([int]$xmlComposedBlock.WIDTH -ge 200)){

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
MakeTextObjectHTML -AlignTextBlockHTML "TitlePage" -FontTextBlock $null -LineVPOS 0 
SavePictureMAP -HEIGHT $xml.HEIGHT -WIDTH $xml.WIDTH -VPOS $xml.VPOS -HPOS $xml.HPOS
}
}#end of file reading


###################################################################################################
#Cleaning object###################################################################################
###################################################################################################

#correction danger chars
#remove < char form object
($Global:Book | Where-Object {$_.word.string -match '<' }) | foreach -Process { $_.word | ForEach-Object -Process { $_.string = (($_.string).Replace('<', ''))}}
#remove > char from object
($Global:Book | Where-Object {$_.word.string -match '>' }) | foreach -Process { $_.word | ForEach-Object -Process { $_.string = (($_.string).Replace('>', ''))}}
#remove @ char from object
($Global:Book | Where-Object {$_.word.string -match '@' }) | foreach -Process { $_.word | ForEach-Object -Process { $_.string = (($_.string).Replace('@', ''))}}
#remove & char from object
($Global:Book | Where-Object {$_.word.string -match '&' }) | foreach -Process { $_.word | ForEach-Object -Process { $_.string = (($_.string).Replace('&', ''))}}
#remove * char from object
($Global:Book | Where-Object {$_.word.string -match '\*' }) | foreach -Process { $_.word | ForEach-Object -Process { $_.string = (($_.string).Replace('*', ''))}}