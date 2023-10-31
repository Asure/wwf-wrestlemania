# Specify the folder containing .asm files
$folderPath = ".\"

# Get a list of all .asm files in the folder
$asmFiles = Get-ChildItem -Path $folderPath -Filter "*.asm"

# Regular expressions to match sections and labels
$sectionPattern = "^#\\*\*"
#$labelPattern = '#([A-Za-z0-9_]+)'
# Update, only lower case labels!
$labelPattern = '#([a-zA-Z0-9_]+)'

# Function to generate a random 2-letter section descriptor that is unique
function Get-UniqueRandomSectionDescriptor {
    $alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $usedDescriptors = @()
    do {
        $descriptor = -join ((97..122) + (97..122) | Get-Random -Count 4 | ForEach-Object {[char]$_})
    } while ($usedDescriptors -contains $descriptor)
    $usedDescriptors += $descriptor
    return $descriptor
}

# Create a default section at the beginning of the file
$defaultSection = @{
    "SectionNumber" = 0
    "SectionName" = "Default Section"
    "SectionDescriptor" = Get-UniqueRandomSectionDescriptor
    "SectionHeader" = "#** Default Section"
    "SectionStart" = 0
    "SectionEnd" = 0
    "Labels" = @()
}

foreach ($asmFile in $asmFiles) {
    Write-Host "Processing file: $($asmFile.Name)"

    $content = Get-Content $asmFile.FullName
    $sections = @($defaultSection)

    $sectionNumber = 1
    $sectionStartLineNumber = $null
    $lineNumber = 0

    foreach ($line in $content) {
        $lineNumber++
        if ($line -match $sectionPattern) {
            # Start of a new section
            $sectionStartLineNumber = $lineNumber
            $section = @{
                "SectionNumber" = $sectionNumber
                "SectionName" = $null
                "SectionDescriptor" = $null
                "SectionHeader" = $line
                "SectionStart" = $sectionStartLineNumber
                "SectionEnd" = $null
                "Labels" = @()
            }
            $sections += $section
            $sectionNumber++

            # If this is the first real section, update the default section's SectionEnd
            if ($defaultSection["SectionEnd"] -eq 0) {
                $defaultSection["SectionEnd"] = $sectionStartLineNumber - 1
            }
        } else {
            # Track the line number of the last line in the section
            if ($sectionStartLineNumber -ne $null) {
                $section["SectionEnd"] = $lineNumber

                # If SectionName is not set, set it to the current line
                if ($section["SectionName"] -eq $null) {
                    $section["SectionName"] = $line
                }

                # Extract and store labels for the section
                $labels = [regex]::Matches($line, $labelPattern) | ForEach-Object { $_.Groups[1].Value }
                $section["Labels"] += $labels
            }
        }
    }

    # add the default section now we have the end etc..
    $sections += ($defaultSection)

    # Process sections
    foreach ($section in $sections) {
        # Check if the section has labels
        if ($section["Labels"].Count -gt 0) {
            # Display the section name and generate a unique 2-letter section descriptor
            Write-Host "Processing section: $($section['SectionHeader'])"
            Write-Host "Section Name: $($section["SectionName"])"
	    Write-Host "Labels todo: $($section["Labels"])"
            $section["SectionDescriptor"] = Get-UniqueRandomSectionDescriptor

            $startLineNumber = $section["SectionStart"]
            $endLineNumber = $section["SectionEnd"]

            # Create a single replacement operation for this section
            $replaceOperation = @{}
            foreach ($label in $section["Labels"]) {
                # Define the replacement pattern
                $replacement = "$($section['SectionDescriptor'])$label"
                $replaceOperation[$label] = $replacement
            }

            for ($i = $startLineNumber - 1; $i -lt $endLineNumber; $i++) {
                # Replace labels with their respective replacements within the line
                $content[$i] = [regex]::Replace($content[$i], $labelPattern, {
                    param($match)
                    $replacement = $replaceOperation[$match.Groups[1].Value]
                    if ($replacement) { $replacement } else { $match.Value }
                })
            }
        }
    }

    # Replace #* with * in the entire content
    $content = $content -replace "#\*", "*"
    # Memory optimize, remove lines starting with * and ;
    # Disabled for debugging.
    #$content = $content | Where-Object { -not ($_ -match '^\*') }
    #$content = $content | Where-Object { -not ($_ -match '^\;') }

    # Save the modified content to a .axx file with the same name as the original .asm file
    $outputFileName = [System.IO.Path]::ChangeExtension($asmFile.Name, "axx")
    $outputFilePath = Join-Path -Path $folderPath -ChildPath $outputFileName
    $content | Set-Content $outputFilePath

    Write-Host "All labels within each section have been replaced with 'sectiondescriptor + label' in $($asmFile.Name)"
}

Write-Host "Processing complete for all .asm files in the folder."
