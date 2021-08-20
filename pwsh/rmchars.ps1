param (
    [parameter(mandatory=$true,position=1)]
    [string]$dir
)

function rmchars ($nodes) {
    $chars = @("`\","`/","`"",":","<",">","^","|","*","?","+")
    foreach ($node in $nodes) {
	$oldName = $node.name
	$oldFull = $node.fullname
	$oldPath = split-path -path $oldFull
	$newName = $oldName.trim()
	[system.io.path]::getInvalidFilenameChars() | % { $newName = $newName.replace($_,'.')}
	[system.io.path]::getInvalidPathChars() | % { $newName = $newName.replace($_,'.')}
	#$invalidFile = [regex]::escape([string][system.io.path]::GetInvalidFileNameChars())
	#$invalidPath = [regex]::escape([string][system.io.path]::GetInvalidPathChars())
	#$newName = $newName -replace($invalidFile) -replace ($invalidPath)
	foreach ($char in $chars) {
	    $escapedChar = [regex]::escape($char)
	    if ($oldName -match $escapedChar) {
		$newName = $newName -replace($escapedChar)
	    }
	}
	write-host
	write-host -back black -fore yellow "OLD NAME: $oldFull"
	write-host -back black -fore green "NEW NAME: $oldPath\$newName"
    }
}

$files = gci $dir -recurse -force -file
#[array]::reverse($files)
rmchars -nodes $files

$dirs = gci $dir -recurse -force -directory
#[array]::reverse($dirs)
rmchars -nodes $dirs
