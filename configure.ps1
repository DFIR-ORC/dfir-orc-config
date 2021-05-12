function Configure-Orc
{
    <#
        .SYNOPSIS
            Configure DFIR-ORC
        
        .PARAMETER RawBin
            Path to DFIR-ORC raw binaries. Default is 'tools\' directory in
            configuration directory

        .PARAMETER Configuration
            Path to DFIR-ORC configuration root directory containing 'tools\'
            and 'config\' subdirectories. Default is '.\'

        .PARAMETER ToolEmbedXml
            Path to ToolEmbed's XML configuration file. If not specified the
            script will lookup in this order in configuration directory:
            - ORC_embed.xml
            - DFIR-ORC_embed.xml
            - *.xml with '<toolembed>' as root element

        .PARAMETER Destination
            Path to configured DFIR-ORC output file. Default is '.\output\'
            or 'output\' in configuration root directory if provided with
            Configuration parameter

        .PARAMETER Force
            DFIR-ORC raw binaries present in tools directory will be replaced
            if -RawBin option is used

        .EXAMPLE
            .\configure.ps1 `
                -RawBin D:\dfir-orc\build\dev\latest\bin\MinSizeRel\ `
                -Configuration C:\dev\dfir-orc\ `
                -Destination C:\dev\dfir-orc\release\DFIR-Orc.exe
    #>
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo]
        $RawBin,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo]
        $Configuration = ".",

        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo]
        $ToolEmbedXml,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $Destination,

        [Switch]
        $Force
    )

    $ErrorActionPreference = "Stop"

    $OrcRawBinaries = @(
        "DFIR-Orc_x64.exe"
        "DFIR-Orc_x86.exe"
    )

    $OrcRawBinariesToClean = @()

    if($RawBin)
    {
        foreach($OrcRawBinary in $OrcRawBinaries)
        {
            if(Test-Path "${RawBin}\${OrcRawBinary}")
            {
                if($Force -Or -Not (Test-Path "${Configuration}\tools\${OrcRawBinary}"))
                {
                    Copy-Item -Force -Path "${RawBin}\${OrcRawBinary}" -Destination "${Configuration}/tools"
                    $OrcRawBinariesToClean += $OrcRawBinary
                }
                else
                {
                    Write-Warning "DFIR-ORC raw binary seems already present at ${Configuration}\tools\${OrcRawBinary} and will be used to configure DFIR-ORC."
                    Write-Warning "Use -Force option if you want to replace it"
                }
            }
            else
            {
                Write-Error "Cannot find ${OrcRawBinary} raw binary"
            }
        }
    }
    else
    {
        $RawBin = "./tools"
    }

    foreach($OrcRawBinary in $OrcRawBinaries)
    {
        if(-Not (Test-Path "${Configuration}\tools\${OrcRawBinary}"))
        {
            Write-Error "DFIR-ORC raw binary ${OrcRawBinary} is not present in ${Configuration}\tools directory"
        }
    }

    Push-Location $Configuration
    try
    {
        if(-Not $ToolEmbedXml)
        {
            $ToolEmbedXml = Get-ToolEmbedXml -Path ".\config"
        }

        if(-Not $ToolEmbedXml -Or -Not (Test-Path $ToolEmbedXml))
        {
            Write-Error "Cannot find ToolEmbed configuration"
        }
        else
        {
            Write-Output "Found ToolEmbed configuration: '${ToolEmbedXml}'"
        }

        $ENV:__COMPAT_LAYER = "RUNASINVOKER"

        # XML configuration files usually references some environment variables
        $ENV:ORC_CONFIG_FOLDER = "config"
        $ENV:ORC_OUTPUT = "DFIR-Orc.exe"

        . tools\DFIR-Orc_x64.exe ToolEmbed /Config="${ToolEmbedXml}"

        $ToolEmbedOutput = Get-ToolEmbedOutput -Path $ToolEmbedXml
    }
    finally
    {
        Pop-Location
    }

    if(! $Destination)
    {
        $Destination = "${Configuration}\output"
    }

    if($Destination -notmatch '\.exe$')
    {
        $DestinationDir = $Destination
        $ExecutableName = Split-Path $ToolEmbedOutput -leaf
        $Destination = "$Destination/$ExecutableName"
    }
    else
    {
        $DestinationDir = Split-Path $Destination
    }

    if(-Not (Test-Path $DestinationDir))
    {
        New-Item -ItemType Directory $DestinationDir | Out-Null
        Write-Output "Create '$DestinationDir' directory"
    }

    if("${Configuration}/${ToolEmbedOutput}" -ne $Destination)
    {
        Move-Item -Force -Path "${Configuration}/${ToolEmbedOutput}" -Destination $Destination
    }

    Write-Output `
        "`n`nDFIR-ORC configuration is done: '$(Resolve-Path ${Destination})'`n"

    # Clean DFIR-ORC raw binaries
    if($RawBin)
    {
        foreach($OrcRawBinary in $OrcRawBinariesToClean)
        {
            if(Test-Path "$Configuration\tools\$OrcRawBinary")
            {
                Remove-Item -Path "${Configuration}\tools\${OrcRawBinary}"
            }
        }
    }
}

function Get-ToolEmbedXml
{
    param(
        [System.IO.DirectoryInfo]
        $Path
    )

    $EmbedFileNames = @(
        "ORC_embed.xml"
        "DFIR-ORC_embed.xml"
        "Embed.xml"
    )

    foreach($EmbedFileName in $EmbedFileNames)
    {
        if(Test-Path "$Path\$EmbedFileName")
        {
            $ToolEmbedXml = "$Path/$EmbedFileName"
            if(Get-Item -Path $ToolEmbedXml | Select-Xml -XPath toolembed)
            {
                return $ToolEmbedXml
            }
        }
    }

    # Lookup for an xml file with 'toolembed' as root element
    $ToolEmbedXml = `
        Get-ChildItem -Filter *.xml ${Path}/ | `
        Select-Xml -XPath toolembed | `
        Select-Object -First 1 | `
        Select-Object -ExpandProperty Path

    return $ToolEmbedXml
}

function Get-ToolEmbedOutput
{
    <#
        .SYNOPSIS
            Look into ToolEmbed XML configuration for '<output>' element value
    #>
    [OutputType([String])]
    param(
        [System.IO.FileInfo]
        $Path
    )

    $Output = `
        Select-Xml -XPath "toolembed/output" ${Path} | `
        Select-Object -ExpandProperty Node | `
        Select-Object -ExpandProperty InnerText

    return [Environment]::ExpandEnvironmentVariables($Output)
}

Configure-Orc @args
