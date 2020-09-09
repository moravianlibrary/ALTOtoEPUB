$Global:BookTitle = @()

$Global:Book|Where-Object {($_.Type -eq "Textblock") -and (($_.word.string).Length -le 100) -and ($_.Page.UUIDMAP.path -notmatch "TableOfContents")} | Sort-Object {$_.page.uuidmap.path}, LIneVPOS  | ForEach-Object -Process {

$FindTitle = $_
#$FindTitle.word.string
$UpperCharCount = 0
$result = $false



#$FindTitle

if ($FindTitle.word.string){

foreach ($character in (($FindTitle.word.string).ToCharArray()) )
{
if ([Char]::IsUpper($character)){
    $UpperCharCount++ 
    }
}



if ($UpperCharCount -ge ((($FindTitle.word.string).Length/100)*50)) { 
    Write-Host $FindTitle.word.string
    Write-Host $FindTitle.Font
    Write-Host $FindTitle.FontSize
    Write-Host "------------------------------------------------"
    $Global:BookTitle += $FindTitle

   }
 }
}







###################################################
#average, maximum and minimum Word length
###################################################
#
#######################
$BookTitleWordLengthAverage = ($Global:BookTitle.word.string) | measure -Maximum -Minimum -Average -Property 'length'
#######################

###################################################
#Types of Font 
###################################################
#
#######################
$BookTitleTypesFond = ($Global:BookTitle | group font)
#######################
#
#select main Font
$Global:BookTitle = ($BookTitleTypesFond | Where-Object { $_.count -eq ($BookTitleTypesFond  | measure -Maximum -Property 'count').Maximum}).Group
#

#######################
$BookTitleFondSize = $Global:BookTitle | measure -Maximum -Minimum -Average -Property 'Fontsize'
#######################
While( (($BookTitleFondSize.Maximum - $BookTitleFondSize.Average) -ge 2) -and (( $BookTitleFondSize.Average - $BookTitleFondSize.Minimum ) -ge 2)){
#

#remove peak values
If(($BookTitleFondSize.Maximum - $BookTitleFondSize.Average) -Ge ($BookTitleFondSize.Average - $BookTitleFondSize.Minimum)){
$Global:BookTitle=$Global:BookTitle |Where-Object { ($_.Fontsize) -ne $BookTitleFondSize.Maximum }
}
Else {$Global:BookPageNumber=$Global:BookPageNumber |Where-Object { ($_.word.string).length -match $BookTitleFondSize.Minimum }}
$Global:BookTitle=$Global:BookTitle |Where-Object { ($_.Fontsize) -ne $BookTitleFondSize.Minimum }
#

$BookTitleFondSize = $Global:BookTitle | measure -Maximum -Minimum -Average -Property 'Fontsize'
}




$BookTitleWordLengthAverage
$BookTitleTypesFond

$Global:BookTitle | ForEach-Object -Process {
$title = $_
$title.type = "Title"
$title.Prefix = '<p class="calibre12">'
$title.word|ForEach-Object -Process { $_.SubPrefix = '<span class="bold">'}
$title.word|ForEach-Object -Process { $_.SubSufix = '</span>'}


}