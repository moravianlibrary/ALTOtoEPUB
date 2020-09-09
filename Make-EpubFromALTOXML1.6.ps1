$FileHTML = @()
$FileHtmlCount = 0
$PathToHTML = "E:\EPUB\OUT\"
$Title = "O Pejskovy a Kočičce"
$FileHtmlName = "NovyMake-html"




$FileHTML+= @" 
<?xml version='1.0' encoding='utf-8'?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$Title</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<link href="stylesheet.css" rel="stylesheet" type="text/css"/>
<link href="page_styles.css" rel="stylesheet" type="text/css"/>
</head>
<body class="calibre">
"@

$Global:Book | Sort-Object {$_.page.uuidmap.path}, LIneVPOS  | ForEach-Object -Process {




if (($_.Type -notmatch "PageNumber") -and ($_.Type -notmatch "Label") ){
$FileHTML += $_.Prefix

$_.word | ForEach-Object -Process {

$FileHTML +=($_.SubPrefix+$_.String+$_.SubSufix)

}
$FileHTML +=$_.Suffix
}
}
$FileHTML+=@"
<p class="calibre4" style="margin:0pt; border:0pt; height:1em"> </p><div class="mbppagebreak" id="calibre_pb_"></div>
</body></html>
"@


$FileHTML |Out-File -FilePath E:\EPUB\OUT\$FileHtmlName.html -Encoding utf8