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

    # Initialize a hashtable to store frame names and their corresponding frames
    $frameNames = @{}

    # Process the LOD file
    $frameName = $null

    foreach ($line in $lines) {
        if ($line -match "^--->") {
            # Extract the frame header
            $header = $line -replace "^--->", ""
            $frameName = $header.Substring(0, $header.Length - 2).Trim()

            # Initialize an array for frames associated with the frame name
            $frames = @()

            # Search for matching frames in the entire .LOD file
            $frames += $lines | ForEach-Object {
                $_ -split ',' | ForEach-Object {
                    $frame = $_.Trim()
                    if ($frame -eq $frameName) {
                        $frame
                    }
                }
            }

            # Remove duplicates from the array of frames
            $frames = $frames | Select-Object -Unique

            # Store the frame name and its matching frames in the hashtable
            $frameNames[$frameName] = $frames -join ','
        }
    }

    # Create the output .SEQ file content
    $seqFileContent = $frameNames.Keys | ForEach-Object {
        $frameName = $_
        $frames = $frameNames[$frameName]
        "$frameName`:`r`n.long 0`r`n.long $frames"
    }

    # Write the content to the output .SEQ file with OEM/CP1252 encoding
    $seqFileContent | Out-File -FilePath $seqFilePath -Encoding oem

    Write-Host "Sequence file '$seqFilePath' created with OEM/CP1252 encoding."
}
