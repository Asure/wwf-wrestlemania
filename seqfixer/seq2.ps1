# Specify the folder containing .LOD files
$folderPath = "."

# Get a list of .LOD files in the folder
$lodFiles = Get-ChildItem -Path $folderPath -Filter *.lod

# Process each .LOD file and generate .SEQ files
foreach ($lodFile in $lodFiles) {
    # Construct the output .SEQ file path by changing the extension
    $seqFilePath = [System.IO.Path]::ChangeExtension($lodFile.FullName, ".seq")

    # Read the input .LOD file
    $lines = Get-Content $lodFile.FullName
    $lines2 = Get-Content $lodFile.FullName

    # Initialize an array to store unique frame names
    $frameNames = @()

    # Process the LOD file
    foreach ($line in $lines) {
        if ($line -match "^--->") {
            # Extract frame names, trim the last 2 characters, and remove duplicates
            $frameNames += $line -replace "^--->", "" -split ',' | ForEach-Object {
                $frameName = $_.Substring(0, $_.Length - 2).Trim()
                $frameName
            }
        }
    }

    # Remove duplicates by converting the array to a HashSet
    $frameNames = $frameNames | Select-Object -Unique

    foreach ($frameName in $frameNames) {
		write-host "Checking match against $framename"
        $lines2 = $lines2 -replace "^---> ", ""
        $data = $lines2 -split ','
	}


    # Create the output .SEQ file content
    $seqFileContent = $frameNames | ForEach-Object {
        "$_`:`r`n.long 0"
    }

    # Write the content to the output .SEQ file with OEM/CP1252 encoding
    $seqFileContent | Out-File -FilePath $seqFilePath -Encoding oem

    Write-Host "Sequence file '$seqFilePath' created with OEM/CP1252 encoding."
}
