# https://kramerius.mzk.cz/search/iiif/uuid:b76e42f4-4451-48dd-852b-b28e69065b67/100,0,100,200/pct:50/0/gray.jpg


#{scheme}://{server}{/prefix}/{identifier}/{region}/{size}/{rotation}/{quality}.{format}


$pathToOutFolder = "E:/EPUB/OUT/"
$IIFApi = "https://kramerius.mzk.cz/search/iiif/"


#main loop
$Global:Images | ForEach-Object -Process {

$WebPath = ( $IIFApi+$_.UUID+"/"+$_.HPOS+","+$_.VPOS+","+$_.WIDTH+","+$_.HEIGHT+"/pct:50/0/gray.jpg" )
$OutfilePath = $pathToOutFolder+"images/"+$_.Number+".jpg"

Invoke-WebRequest $WebPath -OutFile $OutfilePath


}