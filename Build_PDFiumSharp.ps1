#initialize parameters
param(
    [string] $Arch ='x64',

    [string] $Wrapper_Branch=' '
)

#ProjectName

$Project_Name ='PDFiumSharp'

#Current Path
$CurrentPath=(Get-Location).Path

#Display Config
Write-Host "Architecture: " $Arch
Write-Host "Directory to Build: " $CurrentPath

Write-Host "Restore NuGet Packages - NUnit3"
dotnet restore 

#Locate Visual Studio
function buildVStudio{
    param(
    [parameter(Mandatory=$true)]
    [String] $path,

    [parameter(Mandatory=$false)]
    [bool] $clean =$true
    )

    process{
        $msBuildExe = Resolve-Path "${env:ProgramFiles(x86)}/Microsoft Visual Studio/2017/*/MSBuild/*/bin/msbuild.exe" -ErrorAction SilentlyContinue

        if($clean){
            Write-Host "Cleaning $($path)" -ForegroundColor blue
            & "$($msBuildExe)" "$($path)" /t:Clean /m /p:Configuration=Release,Platform=$Arch /v:n
        }

        Write-Host "Building $($path)" -ForegroundColor blue
            & "$($msBuildExe)" "$($path)" /t:Build /m /p:Configuration=Release,Platform=$Arch /v:n
        
    }

}

buildVStudio -path "$CurrentPath/$Project_Name/$Project_Name.csproj"



#Check if the pdfium.dll library exists
Write-Host "Checking for PDFium.dll Library..."

if($Arch -eq 'x64'){
    $OUT_DLL_DIR = $CurrentPath + '/Lib/x64'
}elseif($Arch -eq 'x86'){
    $OUT_DLL_DIR = $CurrentPath + '/Lib/x86'
}else {
    Write-Host "Arch not defined or invalid..."
    Exit
}


#Copy pdfium.dll to appropriate folder
Write-Host "Copying pdfium.dll to pdfiumSharp Remake solution project.."

$lib_Dir=$CurrentPath+"/"+$Project_Name+"/lib/"+$Arch

if ([System.IO.Directory]::Exists( $lib_Dir )) {
    Set-Location $lib_Dir
}
else {
    New-Item -Path $lib_Dir -ItemType Directory
    Set-Location $lib_Dir
}

if (Test-Path -Path $OUT_DLL_DIR'/pdfium.dll') {
    Copy-Item $OUT_DLL_DIR'/pdfium.dll' -Destination $lib_Dir
}

#make nuget package
Write-Host "Now making Nuget Package..." -ForegroundColor Blue

Set-Location $CurrentPath"/"$Project_Name
nuget pack "$Project_Name.csproj" -properties "Configuration=Release;Platform=$Arch"

#set directory for nuget package
$OUT_NUGET_DIR = $CurrentPath+'/NuGet/'+$Arch

if ([System.IO.Directory]::Exists($OUT_NUGET_DIR)) {
    Set-Location $OUT_NUGET_DIR
}
else {
    New-Item -Path $OUT_NUGET_DIR -ItemType Directory
    Set-Location $OUT_NUGET_DIR
}

Write-Host "Copy Nuget files to " $OUT_NUGET_DIR

Copy-Item -Path "$CurrentPath/$Project_Name/*.*.*.*.nupkg" -Destination $OUT_NUGET_DIR

#Copy-Item -Path "$lib_Dir/pdfium.dll" -Destination

Set-Location $CurrentPath