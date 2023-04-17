function Get-MirthServerUpdateSettings { 
    [CmdletBinding()] 
    PARAM (

        # A MirthConnection is required. You can obtain one from Connect-Mirth.
        [Parameter(ValueFromPipeline = $True)]
        [MirthConnection]$connection = $currentConnection,

        # Saves the response from the server as a file in the current location.
        [Parameter()]
        [switch]$saveXML,

        # Optional output filename for the saveXML switch, default is "Save-[command]-Output.xml"
        [Parameter()]
        [string]$outFile = 'Save-' + $MyInvocation.MyCommand + '-Output.xml'
    )     
    BEGIN { 
        Write-Debug "Get-MirthServerUpdateSettings Beginning"
    }
    PROCESS {
        if ($null -eq $connection) { 
            Throw "You must first obtain a MirthConnection by invoking Connect-Mirth"    
        }          
        [Microsoft.PowerShell.Commands.WebRequestSession]$session = $connection.session
        $serverUrl = $connection.serverUrl
 
        $uri = $serverUrl + '/api/server/updateSettings'
        $headers = $DEFAULT_HEADERS.Clone();
        $headers.Add("accept", "application/xml")

        Write-Debug "Invoking GET Mirth $uri "
        try { 
            $r = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -WebSession $session
            
            if ($saveXML) { 
                Save-Content $r $outFile
            }
            Write-Verbose $r
            
            $r
        }
        catch {
            Write-Error $_
        }
    }
    END { 
        Write-Debug "Get-MirthServerUpdateSettings Ending"
    }
}