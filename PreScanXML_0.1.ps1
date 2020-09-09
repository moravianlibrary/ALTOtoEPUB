$InFolder = "C:/EPUB/IN/"
$UUIDMAP = Import-Csv -Path ($InFolder+"MAP/UUIDmap.csv") -Delimiter ',' -Encoding Default


$InputFiles = (Get-ChildItem $InFolder -Filter *.xml | select name)
$Global:PreScanXML = @()
$Global:xml = 0

###################################
#TextBlock Processing
###################################
function FindSpace {

param ($xmlTextBlock)
##Cycle for Texblocks
Write-host $file.name -ForegroundColor white

########################################################################################################$xmlTextBlock = $_


$altoLineCount = @($xmlTextBlock.TextLine).count 

##block Style and Font
$TextBlockStyle = $Alto.alto.Styles.ParagraphStyle | Where-Object {$xmlTextBlock.STYLEREFS -match $_.ID}
$TextBlockFont = $Alto.alto.Styles.TextStyle | Where-Object {$xmlTextBlock.STYLEREFS -match $_.ID}

If ($altoLineCount -ge 2){

$LineVPOSbefore =$null
$LinevPOSafter = $null
##################################################################################################
#Cycle of Line in texblock
$xmlTextBlock.Textline|ForEach-Object -Process {
$xmlTextLine = $_

#average of begin position of all lines in ALTO text block 
$TextBlockAverage = ($xmlTextBlock.Textline | Measure-Object HPOS -Average).Average

$LineVPOSbefore =$LineVPOSafter
$LineVPOSafter = $xmlTextLine.VPOS

if($LineVPOSbefore) {
$lineDIF = $LineVPOSafter - $LineVPOSbefore
$Global:PreScanXML +=  [pscustomobject]@{
                                              Page = $file.Name
                                              LineVPO = $LineVPOSbefore
                                              LineVPOSDif = $lineDIF
                                              LineVPOSDifPercent = ([int]$lineDIF /([int]($Global:xml.HEIGHT /100)))
                                              Font = $TextBlockStyle
                                              FontSize = $TextBlockFont
                                             }
}
}
}
}



#####################
#MAIN
#####################

foreach($file in $InputFiles ) {
#set path to XML
$PathToXML = $InFolder+$File.name

[xml]$Alto = Get-Content $PathToXML -Encoding UTF8

#shortened object notation 
$Global:xml = $Alto.alto.Layout.Page.PrintSpace

if ($file -notmatch "TitlePage"){

if ($Global:xml.textblock){ 
$Global:xml.textblock|ForEach-Object -Process {
FindSpace -xmlTextBlock $_}
}

if ($Global:xml.ComposedBlock.textblock){
$Global:xml.ComposedBlock.textblock | ForEach-Object -Process {
FindSpace -xmlTextBlock $_
}
}
}


}