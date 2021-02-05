$PageLabel = (($Global:Book|Where-Object {($_.Type -eq "Textblock")}).word.string | group | Where-Object {$_.count -ge 5} )

$PageLabelBookObject = $Global:Book| Where-Object { $PageLabel.Name -eq $_.word.string }

###############
$PagelabelFont = $PageLabelBookObject | group font| Sort-Object count | Select-Object -Last 1
###############
###############
$PagelabelFontSize = $PagelabelFont.group | group font, fontsize | Sort-Object count | Select-Object -Last 1
###############

$PageLabelBookObject = $PagelabelFont.group

################
$PageLabelVposAverage = $PageLabelBookObject.LineVPOSPercent |measure -Maximum -Minimum -Average
################
While( $PageLabelVposAverage.Maximum - $PageLabelVposAverage.Minimum -gt 5){
#
#remove peak values
If(($PageLabelVposAverage.Maximum - $PageLabelVposAverage.Average) -Ge ($PageLabelVposAverage.Average - $PageLabelVposAverage.Minimum)){
$PageLabelBookObject=$PageLabelBookObject |Where-Object {[string]$_.linevpospercent -match $PageLabelVposAverage.Maximum }
}
Else {$PageLabelBookObject=$PageLabelBookObject |Where-Object {[string]$_.linevpospercent -match $PageLabelVposAverage.Minimum }}
#
#
$PageLabelVposAverage = $PageLabelBookObject.LineVPOSPercent |measure -Maximum -Minimum -Average
#
}
($Global:Book | Where-Object {($_.Type -eq "Textblock") -and (($_.LineVPOSPercent -le $PageLabelVposAverage.Maximum) -and ($_.LineVPOSPercent -ge $PageLabelVposAverage.Minimum))}).word.string

($Global:Book | Where-Object {($_.Type -eq "Textblock") -and (($_.LineVPOSPercent -le $PageLabelVposAverage.Maximum) -and ($_.LineVPOSPercent -ge $PageLabelVposAverage.Minimum))})| ForEach-Object -Process {
$_.Type = "Label"

}

