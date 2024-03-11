param(
    [string]$baseDir  # Define the runtime dir
)

# Check if the <baseDir> parameter is provided
if (-not $baseDir) {
    Write-Host "Usage: GenerateHash.ps1 -baseDir <node_name>"
    exit 1
}

# Base directory path where the folders are located
#$baseDir = "D:\IBM\mqsi\Nodes\components\PSAAEDIIIBPROD\servers"

# Output CSV file name
$outputCSV = "FileHashes.csv"

# Placeholder hash for failed attempts
$placeholderHash = "0000000000000000000000000000000000000000000000000000000000000000"

# Check if the CSV file already exists and delete it
if (Test-Path $outputCSV) {
    Remove-Item -Path $outputCSV
}

# Write the header to the CSV file
Add-Content -Path $outputCSV -Value "FileName,Hash"

# Loop through each folder in the base directory
Get-ChildItem -Path $baseDir -Directory | ForEach-Object {
    # Build the target directory path by appending "\run" to each folder's FullName
    $targetDir = Join-Path -Path $_.FullName -ChildPath "run"

    # Check if the target directory exists
    if (Test-Path $targetDir) {
        # If it exists, get all files under it recursively
        Get-ChildItem -Path $targetDir -File -Recurse | ForEach-Object {
            # Store the full file name in a variable
            $fileName = $_.FullName

            try {
                # Calculate the SHA256 hash for each file
                $hash = Get-FileHash -Algorithm SHA256 -Path $fileName -ErrorAction Stop

                # Create a CSV row
                $csvRow = "$fileName,$($hash.Hash)"
            } catch {
                # Use placeholder hash value for failed attempts
                $csvRow = "$fileName,$placeholderHash"
            }
            # Append the row to the CSV file
            Add-Content -Path $outputCSV -Value $csvRow
        }
    }
}
