#inicialiyace promennych 
##############################

#path 
$PathToTXT = 'E:\EPUB\IN\ENDEROVA.txt'

#ukazatel rakdu
$Global:LineCounter = 0

#Hlavni promena obsahuje form8tovanz text - inicializace jako pole objektu
$Global:FULLTEXTHTML = @()

#delka znaku
$Global:TotalLength = 0

#prumerna delka radku
$Global:AverageLength = 0

#hlidac zapisu
$Global:WriteSetter = $false

###################################################
#Objects###############
###################################################

#INICIATE
#allow value Type (Chapter, Speech, TextBolock, Special)

#Chapter
$Global:ObjectPropertiesChapter = @{
Type = [string] "Chapter"
Order = [int]
Prefix = [string] '<p class="calibre12"><span class="bold">' 
Value = [string] 
Suffix = [string] '</span></p>'
}

#Speech
$Global:ObjectPropertiesSpeech = @{
Type = [string] "Speech"
Order = [int]
Prefix = [string] '<p class="calibre9">' 
Value = [string] 
Suffix = [string] '</p>'
}

#TextBlock
$Global:ObjectPropertiesTextBlock = @{
Type = [string] "TextBlock"
Order = [int]
Prefix = [string] ""
Value = [string] ""
Suffix = [string] ""
}


##########################################
#write to FULLTXTHTML
##########################################
function Write-ToFulltexthtml{

param($HtmlObject)

$Global:FULLTEXTHTML += $HtmlObject
$Global:WriteSetter = $true

}



###################################
#Make Chapter HTML object
##################################
function MakeChapterObjectHTML {

param ([string] $LineChapterHtml, [int] $Order )

$LastObjct = ($FULLTEXTHTML | Select-Object -Last 1)
#uprave konce bloku predchoziho
if ($LastObjct.Suffix -notmatch '</p>') {
    ($FULLTEXTHTML | Select-Object -Last 1 ).Suffix = "</p>" }

$TXTHTML =  New-Object psobject -Property $Global:ObjectPropertiesChapter

$TXTHTML.Order = $Order
$TXTHTML.Value = $LineChapterHtml
return ($TXTHTML)

}

###############################
#Make Speech HTML object
###############################
function MakeSpeechObjectHTML {

param ([string] $LineSpeechHTML, [int] $Order )

#check last object type add end it
    $LastObjct = ($FULLTEXTHTML | Select-Object -Last 1)
    
    if ($LastObjct.Suffix -notmatch "</p>") {
    ($FULLTEXTHTML | Select-Object -Last 1 ).Suffix = "</p>" }
    
#Write-Host "sem v tvorbe HTML speech"
$TXTHTML =  New-Object psobject -Property $Global:ObjectPropertiesSpeech
$TXTHTML.Order = $Order
$TXTHTML.Value = $LineSpeechHTML
return ($TXTHTML)
}


###############################
#Make Textblock Html Object
###############################

function Make-TextBlockHtml{

param ([string] $LineTextBlockHtml, [int] $Order)

#vareable
$LastObjct = ($FULLTEXTHTML | Select-Object -Last 1)

[char]$FirsCharTextBlock = $LineTextBlockHtml.Substring(0, 1)
$TXTHTML =  New-Object psobject -Property $Global:ObjectPropertiesTextBlock


#new textblock
if (($LastObjct.Value -eq $null) -or($LastObjct.Type -ne "TextBlock") ) { 
$TXTHTML.Prefix = '<p class="calibre9">'
} else {
if (((($LineTextBlockHtml.Length / ($LastObjct.Value).Length) -ge 1.2 ) -and ( [Char]::IsUpper($FirsCharTextBlock) ) ) -or ($FirsCharTextBlock -eq '„')  )   {
#uprave konce bloku predchoziho
if ($LastObjct.Suffix -notmatch "</p>") {
    ($FULLTEXTHTML | Select-Object -Last 1 ).Suffix = "</p>"}
$TXTHTML.Prefix = '<p class="calibre9">'
}
Else {$TXTHTML.Prefix = $null}
}
#write-host "je to presne"$LastObjct.value
#uprava konce s pomlckou
#if ($LineTextBlockHtml.EndsWith('-')) {
#$LineTextBlockHtml = $LineTextBlockHtml.Substring(0, ($LineTextBlockHtml.Length - 1))
$ValueLastObjectHTML = $LastObjct.Value
if ($ValueLastObjectHTML.EndsWith('-') ){
write-host "--------------------------------------------------------------- -"
#$TEST = ($ValueLastObjectHTML.Substring(0, ($LineTextBlockHtml.Length - 1)))+$LineTextBlockHtml
($FULLTEXTHTML | Select-Object -Last 1 ).Value = ($ValueLastObjectHTML.Substring(0, ($ValueLastObjectHTML.Length - 1)))+$LineTextBlockHtml
$LineTextBlockHtml = $null
$TXTHTML.Type = $null
}Else 
{
if($LineTextBlockHtml.EndsWith('-')){Write-Host "sem TU+++++++++++++++++++++++++++++++++"}
else{
$LineTextBlockHtml+= " "

}
}
$TXTHTML.Order = $Order
$TXTHTML.Value = $LineTextBlockHtml
$LastObjct= $null
return ($TXTHTML)

}



#

#TITLE



##############################
# Funkce odhal  nadpis 
##############################
function Find-Nadpis 
{
param ([string] $LineFindTitle )
$UpperCharCount = 0
$result = $false
foreach ($character in ($LineFindTitle.ToCharArray()|Select-Object -First 10) )
{
 #write-host "tst"
if ([Char]::IsUpper($character)){$UpperCharCount++ 
    if ($UpperCharCount -ge 3) { #Write-Host $line ($line).Length
       # Write-Host " Radek "$LineCounter
       $result = $true }
        }
    Else { $UpperCharCount = 0 }
    }
return $result
}
############################
#Odhal primou rec
############################
function Find-Speech
{
param ([string] $LineFindSpeech )

$result = $false
#Write-Host $LineFindSpeech

if ($LineFindSpeech.EndsWith('“')) {
 $result = $true}
 return $result
}

#############################
#Find textblock
#############################
function Find-TextBlock
{
param ([string] $LineFindTextblock)
$result = $false

if($LineFindTextblock.Length -gt 2){
if ( $line.StartsWith('„')){
 $result = $true
}
Else{
[char]$FirsCharTextBlock = $LineFindTextblock.Substring(0, 1)
if ([Char]::IsLetter($FirsCharTextBlock) -or [char]::IsDigit($FirsCharTextBlock) -or ($FirsCharTextBlock -eq '"') -or ($FirsCharTextBlock -eq ',') ) {
$result = $true
}
}
}
Else {$result = $false}

return $result
}


####################################################################################################################
# Main #############################################################################################################
####################################################################################################################


#only unic lines
$TXTCONT = (Get-Content $PathToTXT | Select-Object -Unique)

foreach($line in $TXTCONT) {


$Global:LineCounter++
#write prograssbar
Write-Progress -Activity "Progres on $PathToTXT " -Status "Line $LineCounter of $($TXTCONT.Count)" -PercentComplete ((($LineCounter / $TXTCONT.Count) * 100) - 1)
   
    ##########################################################
    #Find Speech or Textblock
    ##########################################################
    if ( $line.StartsWith('„')){

    if (Find-Speech -LineFindSpeech $line) {$text= (MakeSpeechObjectHTML -LineSpeechHTML $line -Order $Global:LineCounter)#}
    #Write-Host $text.value
    $Global:WriteSetter = $true
    $Global:FULLTEXTHTML += $text}
    #not speech .. is textblock?
    else{
    if (Find-TextBlock -LineFindTextblock $line ){ 
    
    $text = (Make-TextBlockHtml -LineTextBlockHtml $line -Order $Global:LineCounter )
        $Global:FULLTEXTHTML += $text }
    }

    }
    #############################################################

    Else{

    #############################################################
    #Hedani nadpisu
    #############################################################
    If ($line.Length -ge 1 -and ((Find-Nadpis -LineFindTitle $line) -eq $true)) { $text= (MakeChapterObjectHTML -LineChapterHtml $line -Order $Global:LineCounter)
    $Global:FULLTEXTHTML += $text
    $Global:WriteSetter = $true
    }
    
    #############################################################
    else{
    ############################################################
    #Hledani Text Bloku
    ############################################################
    
    if (Find-TextBlock -LineFindTextblock $line ){ 
    
    $text = (Make-TextBlockHtml -LineTextBlockHtml $line -Order $Global:LineCounter )
        if($text -ne $null){
    
        $Global:FULLTEXTHTML += $text }
        }
    }
    
    }
    $Global:LineCounter
}


