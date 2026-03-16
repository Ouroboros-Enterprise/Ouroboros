param(
    [switch]$CompileOnly
)

$javaDir = $PSScriptRoot
$targetDir = Join-Path $javaDir "target\classes"

$jlineJars = @(
    "$env:USERPROFILE\.m2\repository\org\jline\jline-terminal\3.29.0\jline-terminal-3.29.0.jar",
    "$env:USERPROFILE\.m2\repository\org\jline\jline-terminal-jna\3.29.0\jline-terminal-jna-3.29.0.jar",
    "$env:USERPROFILE\.m2\repository\org\jline\jline-native\3.29.0\jline-native-3.29.0.jar"
) | Where-Object { Test-Path $_ }

$sourceFiles = Get-ChildItem (Join-Path $javaDir "src") -Recurse -Filter *.java | Select-Object -ExpandProperty FullName

New-Item -ItemType Directory -Force $targetDir | Out-Null

$compileClassPath = $jlineJars -join ';'
$runClassPath = @($targetDir) + $jlineJars -join ';'

& javac -cp $compileClassPath -d $targetDir $sourceFiles

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if (-not $CompileOnly) {
    & java -cp $runClassPath com.ouroboros.Main
    exit $LASTEXITCODE
}