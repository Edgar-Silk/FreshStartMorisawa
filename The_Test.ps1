# PDFium.DLLをビルドするためのスクリプト -- depot_toolsをインクルードする
# パラメーター
param (
    # オプション: x86 | x64
    [string]$Arch = 'x64',
    # 予約パラメーター
    [string]$Wrapper_Branch = ' ',

    [string]$JsonFilePath =(Get-Location).path +'/testparams.json',

    [string]$pathToTestPDF =(Get-Location).path +'/PDFiumSharp.Test/test.pdf'
)

# Project Name
$Project_Name = 'PDFiumSharp.Test'


# ビルドディレクトリー
$BuildDir = (Get-Location).path

# コンフィグ
Write-Host "Architecture: " $Arch
Write-Host "Directory to Build: " $BuildDir

# Restore NuGet packages. This us used for NUnit3 
Write-Host "Restore NuGet Packages - Xunit"
dotnet restore 

# Visual Studio MSI-Builder - コンパイラーを設定する
Write-Host "Locate VS 2017 MSBuilder.exe"
function buildVS {
    param (
        [parameter(Mandatory=$true)]
        [String] $path,

        [parameter(Mandatory=$false)]
        [bool] $clean = $true
    )
    process {
        $msBuildExe = Resolve-Path "${env:ProgramFiles(x86)}/Microsoft Visual Studio/2017/*/MSBuild/*/bin/msbuild.exe" -ErrorAction SilentlyContinue

        if ($clean) {
            Write-Host "Cleaning $($path)" -foregroundcolor green
            & "$($msBuildExe)" "$($path)" /t:Clean /m /p:Configuration=Release,Platform=$Arch /v:n
        }

        Write-Host "Building $($path)" -foregroundcolor green
        & "$($msBuildExe)" "$($path)" /t:Build /m /p:Configuration=Release,Platform=$Arch /v:n
    }
}

# DLLが存在するかチェックしWrapper/Libへコピーする
Write-Host "Checking for PDFium.DLL library..."

if ($Arch -eq 'x64') {
    $OUT_DLL_DIR = $BuildDir + '/Lib/x64'
}
elseif ($Arch -eq 'x86') {
    $OUT_DLL_DIR = $BuildDir + '/Lib/x86'
}
else {
    Write-Host "Arch not defined or invalid..."
    Exit
}

# solutionをコピーする
Write-Host "Copy pdfium DLL to PdfiumSharp.Test solution project"

$Lib_Dir = $BuildDir+"/"+$Project_Name+"/lib/"+$Arch

Write-Host "Copy pdfium DLL to PdfiumSharp.Test test directory"
$test_dir=$BuildDir+"/"+$Project_Name+"/bin/"+$Arch+"/Release/netcoreapp2.1"
$debug_test_dir=$BuildDir+"/"+$Project_Name+"/bin/Debug/netcoreapp2.1"

if ([System.IO.Directory]::Exists( $Lib_Dir )) {
    Set-Location $Lib_Dir
}
else {
    New-Item -Path $Lib_Dir -ItemType Directory
    Set-Location $Lib_Dir
}

if ([System.IO.Directory]::Exists( $test_dir )) {
    #Set-Location $Lib_Dir
}
else {
    New-Item -Path $test_dir -ItemType Directory
    #Set-Location $Lib_Dir
}

if ([System.IO.Directory]::Exists( $debug_test_dir )) {
    #Set-Location $Lib_Dir
}
else {
    New-Item -Path $debug_test_dir -ItemType Directory
    #Set-Location $Lib_Dir
}

if (Test-Path -Path $OUT_DLL_DIR'/pdfium.dll') {
    Copy-Item $OUT_DLL_DIR'/pdfium.dll' -Destination $Lib_Dir
    Copy-Item $OUT_DLL_DIR'/pdfium.dll' -Destination $test_dir
    Copy-Item $OUT_DLL_DIR'/pdfium.dll' -Destination $debug_test_dir

}


# Build the unit test project
buildVS -path "$BuildDir/$Project_Name/$Project_Name.csproj"

# Make the test
Set-Location $BuildDir/$Project_Name

Write-Host "start dotnet test..." -foregroundcolor green
 
 $a = Get-Content $JsonFilePath | ConvertFrom-Json
 $a.pathToFile=$pathToTestPDF
 $a | ConvertTo-Json | set-content $JsonFilePath
 #($env:JsonFilePath=$JsonFilePath) | 
 dotnet test #"bin/$Arch/Release/netcoreapp2.1/$Project_Name.dll" 



Set-Location $BuildDir

ls