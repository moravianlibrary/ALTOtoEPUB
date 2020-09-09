# https://kramerius.mzk.cz/search/iiif/uuid:b76e42f4-4451-48dd-852b-b28e69065b67/100,0,100,200/pct:50/0/gray.jpg


#{scheme}://{server}{/prefix}/{identifier}/{region}/{size}/{rotation}/{quality}.{format}
$pathToINFolder = "C:/EPUB/IN/"
$pathToCoverJson = $pathToInFolder+"MAP/Cover.json"

$pathToOutFolder = "C:/EPUB/OUT/OEBPS/Images"
$IIFApi = "https://kramerius.mzk.cz/search/iiif/"


#main loop
$Global:Images | ForEach-Object -Process {

$WebPath = ( $IIFApi+$_.UUID+"/"+$_.HPOS+","+$_.VPOS+","+$_.WIDTH+","+$_.HEIGHT+"/pct:50/0/gray.jpg" )
$OutfilePath = $pathToOutFolder+"\"+$_.Number+".jpg"

Invoke-WebRequest $WebPath -OutFile $OutfilePath


}


##############################################################################
#Download Cover
#################

#Load Img info 
$json_Img = Get-Content $pathToCoverJson | ConvertFrom-Json

Invoke-WebRequest (($json_Img.'@id')+"/0,0,"+($json_Img.width)+','+($json_Img.height)+"/pct:50/0/color.jpg") -OutFile $pathToOutFolder"\cover.jpg"