$PathToHTML = "E:\EPUB\OUT\"
$Title = "O Pejskovy a Kočičce"
$FileHtmlName = "TESTBezCiselStranky"


#end of file
$end1 ='<p class="calibre4" style="margin:0pt; border:0pt; height:1em"> </p><div class="mbppagebreak" id="calibre_pb_'
$end2 = '"></div>'
#set first header in file 0 
echo "<?xml version='1.0' encoding='utf-8'?>" > "$PathToHTML$FileHtmlName.html"
echo '<html xmlns="http://www.w3.org/1999/xhtml">' >> "$PathToHTML$FileHtmlName.html"
echo "<head>" >> "$PathToHTML$FileHtmlName.html"
echo "<title>$Title</title>" >> "$PathToHTML$FileHtmlName.html"
echo '<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>' >> "$PathToHTML$FileHtmlName.html"
echo '<link href="stylesheet.css" rel="stylesheet" type="text/css"/>' >> "$PathToHTML$FileHtmlName.html"
echo '<link href="page_styles.css" rel="stylesheet" type="text/css"/>' >> "$PathToHTML$FileHtmlName.html"
echo '</head>' >> "$PathToHTML$FileHtmlName.html"
echo '<body class="calibre">' >> "$PathToHTML$FileHtmlName.html"

$Global:Book | Sort-Object {$_.page.uuidmap.path}, LIneVPOS  | ForEach-Object -Process {


if (($_.Type -notmatch "PageNumber") -and ($_.Type -notmatch "Label") ){
#start of block
echo $_.Prefix >> "$PathToHTML$FileHtmlName.html"


$_.word | ForEach-Object -Process {

echo $_.SubPrefix$_.String$_.SubSufix >> "$PathToHTML$FileHtmlName.html"

}

#end of Block
echo $_.Suffix >> "$PathToHTML$FileHtmlName.html"
}
}

echo $end1$FileHtmlName$end2 >> "$PathToHTML$FileHtmlName.html"
echo "</body></html>" >> "$PathToHTML$FileHtmlName.html"