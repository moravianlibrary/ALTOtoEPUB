﻿$PathToHTML = "C:\EPUB\OUT\OEBPS\"

$UUID = "urn:uuid:9a038280-10af-11e4-8e0d-005056827e51"
$TitleName = "Testovaci"
$language = "cs"
$date_opf = (Get-Date -Format "yyyy-mm-dd").ToString() #fomat - 2020-7-7
$description_opf = "Testovaci nazev"
#################################################################################################

$metadata_OPF= @"
<?xml version='1.0' encoding='utf-8'?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="BookId">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
    <!--Required Metadata-->
    <dc:title>$TitleName</dc:title>
    <dc:language>$LAnguage</dc:language>
    <dc:identifier id="BookId" opf:scheme="uuid">$UUID</dc:identifier>
    <!--Use the Same for the toc.ncx file -->
    <dc:creator opf:role="aut">Daniel Dolejš</dc:creator>
    <dc:publisher>MZK</dc:publisher>
    <dc:date>$date_opf</dc:date>
    <meta name="obalka" content="../Images/imagecover.jpg"/>
    <!--Required for KindleGen-->
    <!-- Optional Metadata -->
    <!-- Optional Metadata -->
    <dc:description>$description_opf</dc:description>
  </metadata>
"@


#########################################################################

$Manifest_opfHead= @"
<manifest>
    <item href="toc.ncx" id="ncx" media-type="application/x-dtbncx+xml"/>
    <item href="Styles/stylesheet.css" id="css" media-type="text/css"/>
	    <item href="Text/content.html" id="kniha" media-type="application/xhtml+xml"/>
   
"@

$Manifest_opfBack= @"
<item href="Styles/page_styles.css" id="id" media-type="text/css"/>
</manifest>

"@

###################################
#create image manifes
$Manifest_opfImg = $null
Get-ChildItem -Path $PathToHTML"Images\" |Sort-Object Name |ForEach-Object -Process {


$Manifest_opfImg += @"
<item href="Images/$_" id="image$_" media-type="image/jpeg"/>

"@

}

######################################
#Create Text manifest

$Manifest_opfText = $null
Get-ChildItem -Path $PathToHTML"Text\" |Sort-Object Name |ForEach-Object -Process {

$TextName = $_.BaseName
$Manifest_opfText += @"
<item href="Text/$_" id="kniha_$TextName.xhtml" media-type="application/xhtml+xml"/>

"@

}

#####################################
#create spine part
$OpfSpineToc = @"
<spine toc="ncx">
<itemref idref="kniha_content.xhtml"/>
"@

Get-ChildItem -Path $PathToHTML"Text\" | Where-Object {$_.Name -notmatch "content"} | Sort-Object Name |ForEach-Object -Process {
$TextName = $_.BaseName
$OpfSpineToc += @"
<itemref idref="kniha_$TextName.xhtml"/>

"@
}
$OpfSpineToc += @"
<guide>
    <reference href="Text/content.html" title="Cover" type="cover"/>
  </guide>
</spine></package>

"@


#write to FIle 
($metadata_OPF+$Manifest_opfHead+$Manifest_opfImg+$Manifest_opfText+$Manifest_opfBac+$OpfSpineToc) | Out-File -FilePath $PathToHTML"content.opf" -Encoding utf8