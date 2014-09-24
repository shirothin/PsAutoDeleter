# The Windows PowerShell auto files and directories deleter
# .
# The parameters binding format as PowerShell4.0 and after.
# parameter 1 : target directory (do not space in filenames)
# parameter 3 : delete it before this date
# parameter 3 : least number of files remains
#

[CmdletBinding()]
    param (
	[string]$args = "",
	[string]$day = "365",
    [string]$least = "6"
)

# default directory is .\Backup
if ($args.length -eq 0) {
    write-host "first param is $($args[0])"
    $args = ".\Backup"
 }

#for debug
#$args > dir.txt

echo $args
echo $day

Get-Location
Set-Location $args
Get-Location

$fso = New-Object -ComObject Scripting.FileSystemObject
$dir = Get-ChildItem -Force -File | ForEach-Object{
    if($_.PSIsContainer) {
        $fso.GetFolder($_.FullName).ShortPath
    }
    else {
        $fso.GetFile($_.FullName).ShortPath
    }
}

Set-ItemProperty -Path $dir Attributes Normal
$dir > .\files.txt

$filter = "*.*"
$filename = ".\log.txt"
$str = "--------------------------------,"
$str += "`n" + "day:," + $day + "filter:," + $filter + ",dir:" + ($args)

write-host "Item Count is $($dir.Count)"
write-host "least keep item count is $($least)"

# delete files day which find $day before today
foreach($delFile in (get-Item $filter | Where { $_.LastWriteTime -lt (Get-Date).AddDays(0 - $day) })){
	$str += ("deleted:," + $delFile.Name + "`t" + $delFile.LastWriteTime + "`n")
    $dir = Get-ChildItem -Force -File
    # at $least to end.
    ##write-host "Item Count is $($dir.Count)"
    if($dir.Count -gt $least) {
	    remove-Item $delFile
    }
}

$str += "`n" + "running time:,"
$str += Get-Date
$str += "`n"
IF (!($filename)) {
	$str > log.txt
}
ELSE {
	Add-Content $filename $str
}
