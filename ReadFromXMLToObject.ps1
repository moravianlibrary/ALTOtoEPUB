[xml]$xml = Get-Content E:\EPUB\TESTALTO.xml -Encoding UTF8
$altoTextBlockCount = @($xml.alto.Layout.Page.PrintSpace.TextBlock).count -1
$countBlock = 0
$LINE = ""
$Global:Book = @()
$Global:NewTextBlock = $nul
$Global:SubsContent =$false

#TextBlock Left
$Global:ObjectPropertiesTextBlockLEFT = @{
Type = [string] "TextBlock"
Order = [int]
Prefix = [string] '<p class="calibre9">'
Word = @{
String = [string] $null
FormatPrefix = [string] $null
FormatSuffix = [string] $null
} 
Suffix = [string] '</p>'
}


###############################
#Make NewTextblock HTML object
###############################
function MakeTextObjectHTML {

param ([string]$AlignTextBlockHTML, [string]$FontTextBlock )
$NewTextBlock.Word =$null
Write-Host " zavolal sem novy radek "
Write-Host "hodnota  zarovnani " $AlignTextBlockHTML
Write-Host "Hodnota Fond" $FontTextBlock
Write-Host "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
$Global:NewTextBlock = $null
#save finish text block to Book
if ($Global:NewTextBlock){ 
$Global:Book += $Global:NewTextBlock }
$Global:NewTextBlock = $null

switch ($AlignTextBlockHTML) 
{
{$_ -match 'Block'}{
$Global:NewTextBlock =  New-Object psobject -Property $Global:ObjectPropertiesTextBlockLEFT}
{$_ -match 'Left'}{$Global:NewTextBlock =  New-Object psobject -Property $Global:ObjectPropertiesTextBlockLEFT}
{$_ -match 'Right'}{$Global:NewTextBlock =  New-Object psobject -Property $Global:ObjectPropertiesTextBlockLEFT}
}

return 
}


###############################
#Write to NewTextblock HTML object
###############################
function WriteTextObjectHTML {

param ([string] $WordTextblock, $StyleWordHTML )

if ($StyleWordHTML){ 
    $LastWord = ($NewTextBlock.word | Select-Object -Last 1)

    if ($LastWord.FormatPrefix -match $StyleWordHTML ) {
    ($Global:NewTextBlock.Word | Select-Object -Last 1).FormatSuffix = $null
    $Global:NewTextBlock.Word.FormatSuffix = '</span>'
    }
    else{
    $Global:NewTextBlock.Word.FormatPrefix = '<span class="'+$StyleWordHTML+'">'
    $Global:NewTextBlock.Word.FormatSuffix = '</span>' }
}
$Global:NewTextBlock.Word.String
$Global:NewTextBlock.Word.String += ($WordTextblock + " ")
return
}


#$iterace1 =0
#$iterace2 = 0
#$iterace3 = 0

#####################################################################################################
#####################################################################################################
For ($altoTextBlock=0; $altoTextBlock -le $altoTextBlockCount; $altoTextBlock++) {

###
#$iterace1++
#Write-host " smycka Altoblock - alto count " $altoTextBlockCount
#$iterace1 
#Write-Host "Alto " $altoTextBlock
#Write-Host "00000000000000000000000000000000000000000000000"
###
$altoLineCount = @($xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].TextLine).count -1

##block Style and Font
$TextBlockStyle = $xml.alto.Styles.ParagraphStyle | Where-Object {$xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].STYLEREFS -match $_.ID}
$TextBlockFont = $xml.alto.Styles.TextStyle | Where-Object {$xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].STYLEREFS -match $_.ID}

MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.ID

##################################################################################################
For ($altoLine=0; $altoline -le $altoLineCount; $altoLine++) {


###
#$iterace2++
##Write-host " smycka Altoline - alto line count " $altolineCount
#$iterace2 
#Write-Host "Alto line " $altoline 
#Write-Host "1111111111111111111111111111111111111111"
###
#average of begin position of all lines in ALTO text block 
$TextBlockAverage = ($xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].TextLine | Measure-Object HPOS -Average).Average

# if line offset 13%
if  ($xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].TextLine[$altoLine].HPOS/($TextBlockAverage/100) -ge 113 ){
    
    MakeTextObjectHTML -AlignTextBlockHTML $TextBlockStyle.ALIGN -FontTextBlock $TextBlockFont.ID 

}
#$counter = 0
#################################################################################################
$xml.alto.Layout.Page.PrintSpace.TextBlock[$altoTextBlock].TextLine[$altoLine].String | ForEach-Object -Process {

#$counter++
#$counter
#$_.content

# check fo - on end of line
if (($_.SUBS_CONTENT -eq $null) -or($Global:SubsContent -eq $true) ){
    $Global:SubsContent =$false
    WriteTextObjectHTML -WordTextblock $_.CONTENT
   
}
Else {
    Write-Host " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" $_.String 
    $Global:SubsContent =$true
    WriteTextObjectHTML -WordTextblock $_.SUBS_CONTENT
}

}


}

}