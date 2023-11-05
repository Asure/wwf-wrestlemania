# Initialize a hash table to store frame headers and their associated frame collections, including block names
$frameHeadersHash = @{}
$blocks = @()
$frameHeaderOrder = @()

# Read the .LOD file line by line, replace '--->' with an empty string
Get-Content -Path 'bam.lod' | ForEach-Object {
    $line = $_.Trim() -replace '---> ', ''
    
    if ($line -match '\.img$') {
        # If a line ends with '.img', it's a new block
        $blockName = $line
    }
    else {
        # Split the line into frame entries
        $frameEntries = $line -split ','
        $frameHeader = $null
        $frameEntries | ForEach-Object {
            $frameName = $_.Trim() -replace ' ', ''
            $frameHeader = $frameName.Substring(0, 6)
            if (-not $frameHeadersHash.ContainsKey($frameHeader)) {
                $frameHeadersHash[$frameHeader] = @{}
                $frameHeaderOrder += $frameHeader
            }
            $frameHeadersHash[$frameHeader][$blockName] += $frameName
        }
    }
}

# Create an array of frames in the order of frameHeaderOrder
$frameHeaderOrder | ForEach-Object {
    $frameHeader = $_
    $frameCollection = $frameHeadersHash[$frameHeader]
    
    $blocks += @{
        frameheader = $frameHeader
        framecollections = $frameCollection
    }
}

# Print the array of frames
$blocks | ForEach-Object {
    Write-Output "frameheader: $($_.frameheader)"
    $_.framecollections | ForEach-Object {
        $blockName = $_.Key
        $frameCollection = $_.Value -join ','
        Write-Output "blockname: $blockName"
        Write-Output "framecollection: $frameCollection`n"
    }
}

# Create or overwrite the output file and write the array of frames in the specified format
$outputFilePath = "output.txt"
$frameHeaderOrder | ForEach-Object {
    $frameHeader = $_
    $frameCollection = $frameHeadersHash[$frameHeader]
    
    $frameCollection.GetEnumerator() | ForEach-Object {
        $blockName = $_.Key
        $frameNames = $_.Value -join ','
        
        $outputLines = @(
            "$frameHeader`:",
            "`t.long 0",
            "`t.long $frameNames"
        )
        
        Add-Content -Path $outputFilePath -Value $outputLines
    }
}

# Indicate that the output is saved to the file
Write-Host "Output has been saved to $outputFilePath"
