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

    # Initialize a new hashtable to store frame headers and their associated sequences
    $frameHeaders = @{}

    # Process the LOD file
    foreach ($line in $lines) {
        # Check if the line starts with ---> and split it into sequences
        if ($line -match "^--->") {
            $sequences = ($line -replace "^--->", "").Split(',')

            foreach ($sequence in $sequences) {
                # Trim the last 2 characters to obtain the frame header
                $frameHeader = $sequence.Substring(0, $sequence.Length - 2).Trim()

                # Initialize the frame header entry if it doesn't exist
                if (-not $frameHeaders.ContainsKey($frameHeader)) {
                    $frameHeaders[$frameHeader] = @()
                }

                # Add the sequence to the corresponding frame header in the hashtable
                $frameHeaders[$frameHeader] += $sequence
            }
        }
    }

    # Create the output .SEQ file content
    $seqFileContent = @()

    # Iterate through the keys
    foreach ($frameHeader in $frameHeaders.Keys) {
        $sequences = $frameHeaders[$frameHeader] -join ','  # Join the sequences with a comma
        $seqFileContent += "$frameHeader`:`r`n`t.long 0`r`n`t.long $sequences"  # Add a tab before .long
#        $seqFileContent += "$frameHeader`:`r`n`t.long $sequences"  # Add a tab before .long
    }

    # Write the content to the output .SEQ file with CP1252 encoding
    $seqFileContent | Out-File -FilePath $seqFilePath -Encoding oem

    Write-Host "Sequence file '$seqFilePath' created with OEM/CP1252 encoding."
}
