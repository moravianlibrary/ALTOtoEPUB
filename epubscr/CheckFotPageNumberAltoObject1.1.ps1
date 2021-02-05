$Global:BookPageNumber = @()
$Global:Book|Where-Object {($_.Type -eq "Textblock") -and (($_.word.string).Length -le 15) -and ($_.Page.UUIDMAP.path -notmatch "TableOfContents")} | Sort-Object {$_.page.uuidmap.path}, LIneVPOS  | ForEach-Object -Process {
$BookObjectFindNumber = $_



###################################################
#Find the numbers that match the page number
###################################################
if ($BookObjectFindNumber.word.string -match '\d' ){
$numbers = ""
#write-host "-----------------------------------"

write-host $BookObjectFindNumber.word.string
foreach ($character in (($BookObjectFindNumber.word.string).ToCharArray())){
$character
if ($character -match '\d'){$numbers += $character }

}

#$Numbers= ($BookObjectFindNumber.word.string -replace '\D+(\d+)','$1')

$numbers

if($numbers -eq $BookObjectFindNumber.page.UUIDMAP.PAGENO){
#write-host "jo?++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
$Global:BookPageNumber += $BookObjectFindNumber
}

}

}#end of cycle


$Global:BookPageNumber.linevpos | measure -Maximum -Minimum -Average

###################################################
#average, maximum and minimum Hight perrcet on page
###################################################
#
######################
$PagenumberVPOSAverage = $Global:BookPageNumber.linevpospercent | measure -Maximum -Minimum -Average
######################
While( $PagenumberVPOSAverage.Maximum - $PagenumberVPOSAverage.Minimum -gt 5){
#
#remove peak values
If(($PagenumberVPOSAverage.Maximum - $PagenumberVPOSAverage.Average) -Ge ($PagenumberVPOSAverage.Average - $PagenumberVPOSAverage.Minimum)){
$Global:BookPageNumber=$Global:BookPageNumber |Where-Object {[string]$_.linevpospercent -match $PagenumberVPOSAverage.Maximum }
}
Else {$Global:BookPageNumber=$Global:BookPageNumber |Where-Object {[string]$_.linevpospercent -match $PagenumberVPOSAverage.Minimum }}
$PagenumberVPOSAverage = $Global:BookPageNumber.linevpospercent | measure -Maximum -Minimum -Average
#
}
echo "++++++++++++++++++++++++++++++++++++++++++++"
###################################################
#average, maximum and minimum Word length
###################################################
#
#######################
$PagenumberWordLengthAverage = ($Global:BookPageNumber.word.string) | measure -Maximum -Minimum -Average -Property 'length'
#######################
While( $PagenumberWordLengthAverage.Maximum - $PagenumberWordLengthAverage.Minimum -gt 5){
#
#remove peak values
If(($PagenumberWordLengthAverage.Maximum - $PagenumberWordLengthAverage.Average) -Ge ($PagenumberWordLengthAverage.Average - $PagenumberWordLengthAverage.Minimum)){
$Global:BookPageNumber=$Global:BookPageNumber |Where-Object { ($_.word.string).length -ne $PagenumberWordLengthAverage.Maximum }
}
Else {$Global:BookPageNumber=$Global:BookPageNumber |Where-Object { ($_.word.string).length -ne $PagenumberWordLengthAverage.Minimum }}
$PagenumberWordLengthAverage =($Global:BookPageNumber.word.string) | measure -Maximum -Minimum -Average -Property 'length'
#
}
echo "1111111111111111111111111111111111111111111111111111111"
###################################################
#Types of Font 
###################################################
#
#######################
$PagenumberTypesFond = ($Global:BookPageNumber.font |select -Unique | group)
#######################


$PagenumberVPOSAverage
$PagenumberWordLengthAverage
$PagenumberTypesFond 


#########################################################################################
#
#########################################################################################
$Global:Book|Where-Object {($_.Type -eq "Textblock") -and ($_.pagename -notmatch "TableOfContents") -and ($PagenumberTypesFond.Name -match $_.Font) -and (($_.word.string).Length -le $PagenumberWordLengthAverage.Maximum)}| 
Where-Object {($_.LineVPOSPercent -le $PagenumberVPOSAverage.Maximum) -and ($_.LineVPOSPercent -ge $PagenumberVPOSAverage.Minimum)} | foreach -Process {

$_.Type = "PageNumber"


}