# Specify the folder containing .LOD files
$folderPath = "."

# Get a list of .LOD files in the folder
$lodFiles = Get-ChildItem -Path $folderPath -Filter *.lod

# Process each .LOD file and generate .SEQ files
foreach ($lodFile in $lodFiles) {
    # Construct the output .SEQ file path by changing the extension
    $seqFilePath = [System.IO.Path]::ChangeExtension($lodFile.FullName, ".seq")

    # Read the input .LOD file
    #$lines = Get-Content $lodFile.FullName



# Initialize an ordered hashtable to store blocks
$blocks = [ordered]@{}
$frameHeadersHash = @{}
#$blocks = @()
$frameHeaderOrder = @()
$currentBlock = $null

# Read the .lod file line by line
#Get-Content -Path $lodFilePath | ForEach-Object {
Get-Content -Path $lodFile.FullName | ForEach-Object {
    $line = $_.Trim() -replace '---> ', ''
    #$line = $_.Trim()

    if ($line -match '\.img$') {
        # If a line ends with '.img', it's a new block
        $currentBlockName = $line
        $currentBlock = @{
            Name = $currentBlockName
            FrameHeader = @{}
            Frames = @()
        }
        $blocks[$currentBlockName] = $currentBlock
    } else {
        if ($line -notmatch '@') {
            # Add the line to the frames of the current block if it doesn't contain --->
            $currentBlock.Frames += $line
            # Split the line into frame entries
            $frameEntries = $line -split ','
            $frameEntries | ForEach-Object {
                $frameName = $_.Trim() -replace ' ', ''
                $frameHeader = $frameName.Substring(0, 6)
                if (-not $currentBlock.FrameHeader.ContainsKey($frameHeader)) {
                    $currentBlock.FrameHeader[$frameHeader] = @()
                }
                $currentBlock.FrameHeader[$frameHeader] += $frameName
            }
        }
    }
}

# Print the array of blocks while preserving order
#$blocks.GetEnumerator() | ForEach-Object {
#    $block = $_.Value
#    Write-Host "Block Name: $($block.Name)"
#    Write-Host "Frame Header: $($block.FrameHeader.Keys -join ', ')"
#    Write-Host "Frames: $($block.Frames -join ', ')"
#}


# Print the array of blocks while preserving order
$blocks.GetEnumerator() | ForEach-Object {
    $block = $_.Value
    Write-Host "Block Name: $($block.Name)"
    
    foreach ($frameHeader in $block.FrameHeader.Keys) {
        Write-Host "Frame Header: $frameHeader"
        Write-Host "Frames: $($block.FrameHeader[$frameHeader] -join ', ')"
    }
}

# Define the path for the output .seq file
$outputFilePath = [System.IO.Path]::ChangeExtension($lodFile.FullName, ".seq")
#    $seqFilePath = [System.IO.Path]::ChangeExtension($lodFile.FullName, ".seq")

# Create or overwrite the output .seq file
$seqFileContent = @()

# Build the .seq file content
$blocks.GetEnumerator() | ForEach-Object {
    $block = $_.Value
    $seqFileContent += "****************"
    $seqFileContent += "* Block Name: $($block.Name)"
    $seqFileContent += "`t.long 0"
    
    foreach ($frameHeader in $block.FrameHeader.Keys) {
        $seqFileContent += "$frameHeader`:`r`n`t.long 0"
        $seqFileContent += "`t.long $($block.FrameHeader[$frameHeader] -join ', ')"
    }
}

# Write the content to the output .seq file
$seqFileContent | Out-File -FilePath $outputFilePath -Encoding OEM

# Indicate that the output is saved to the .seq file
Write-Host "Output has been saved to $outputFilePath"

    #foreach ($frameHeader in $frameHeaders.Keys) {
    #    $sequences = $frameHeaders[$frameHeader] -join ','  # Join the sequences with a comma
    #    $seqFileContent += "$frameHeader`:`r`n`t.long 0`r`n`t.long $sequences"  # Add a tab before .long
#        $seqFileContent += "$frameHeader`:`r`n`t.long $sequences"  # Add a tab before .long
#    }
}
