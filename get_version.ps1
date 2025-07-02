# Extract version from pyproject.toml and export as environment variable
$toml = Get-Content "pyproject.toml" -Raw -ErrorAction Stop
if ($toml -match 'version\s*=\s*"([^"]+)"') {
  $Env:PROJECT_VERSION = $matches[1]
  Write-Host "PROJECT_VERSION set to: $Env:PROJECT_VERSION"
}
else {
  throw "Version not found in pyproject.toml"
}
