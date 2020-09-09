$PageLabel = ($Global:Book.word.string | group | Where-Object {$_.count -ge 5} )

$PageLabelBookObject = $Global:Book| Where-Object { $PageLabel.Name -eq $_.word.string }

$PageLabelBookObject| ForEach-Object -Process {
$_.Type = "Label"

}