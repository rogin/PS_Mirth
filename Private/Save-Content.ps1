function Save-Content {
    [CmdletBinding()] 
    PARAM (

        # the data to save
        [Parameter(Position = 0)]
        $Content,
        # the output file, will be appended to standard output folder
        [Parameter(Position = 1)]
        [string]$OutFile
    )    
    BEGIN { 
        Write-Debug "Save-Content Beginning"
    }
    PROCESS {
        $BaseFolder = Get-OutputFolder -create
        $destFile = Join-Path $BaseFolder $OutFile
        Write-Debug ("Saving output to {0}" -f $destFile)
        if ($Content -is [xml]) {
            $Content = $Content.OuterXml
        }
        Set-Content -Path $destFile -Value $Content
        Write-Debug "Done!"
    }
    END {
        Write-Debug "Save-Content Ending"
    }
}