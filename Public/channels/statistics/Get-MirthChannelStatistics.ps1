function Get-MirthChannelStatistics {
    <#
    .SYNOPSIS
        Get channel statistics
    .DESCRIPTION
        Get channel statistics. Can limit per channels, deployed only, in aggregate, etc. Caller
        can toggle between GET and (default) POST requests.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Get-MirthChannelStatistics

        Default call which includes all deployed channels
    .EXAMPLE
        Get-MirthChannelStatistics -ChannelId "abc","def" -includeUndeployed

        Limit to these channels and check those that are undeployed
    .EXAMPLE
        Get-MirthChannelStatistics -IncludeMetadataId 1,3 -AggregateStats -AsGet

        Uses a GET request for aggregated stats of all deployed channels and limted to those metadata IDs
    #>
    
    
    [CmdletBinding(DefaultParameterSetName = "IncludeMetadataId")] 
    PARAM (

        # A MirthConnection is required. You can obtain one from Connect-Mirth.
        [Parameter(ParameterSetName = "__AllParameterSets", ValueFromPipeline = $True)]
        [MirthConnection] $connection = $currentConnection,

        # The IDs of the channels to retrieve. If absent, all channels will be retrieved.
        [Parameter(ParameterSetName = "__AllParameterSets", ValueFromPipelineByPropertyName = $True, Position = 0)]
        [string[]]$ChannelId,

        #If true, statistics for undeployed channels will also be included.
        [Parameter(ParameterSetName = "__AllParameterSets")]
        [switch]$IncludeUndeployed,

        #The ids of connectors to include. Cannot include and exclude connectors.
        [Parameter(ParameterSetName = "IncludeMetadataId")]
        [int[]]$IncludeMetadataId,
        
        #The ids of connectors to exclude. Cannot include and exclude connectors.
        [Parameter(ParameterSetName = "ExcludeMetadataId")]
        [int[]]$ExcludeMetadataId,

        #If true, statistics will be aggregated into one result
        [Parameter(ParameterSetName = "__AllParameterSets")]
        [switch]$AggregateStats,

        # If true, return the raw xml response instead of a hashtable
        [Parameter(ParameterSetName = "__AllParameterSets")]
        [switch] $Raw,

        # If true, switch request from POST to GET
        [Parameter(ParameterSetName = "__AllParameterSets")]
        [switch] $AsGet,

        # Saves the response from the server as a file in the current location.
        [Parameter(ParameterSetName = "__AllParameterSets")]
        [switch] $saveXML,
        
        # Optional output filename for the saveXML switch, default is "Save-[command]-Output.xml"
        [Parameter(ParameterSetName = "__AllParameterSets")]
        [string] $outFile = 'Save-' + $MyInvocation.MyCommand + '-Output.xml'
    )         
    BEGIN { 
        Write-Debug "[$([datetime]::Now)] $($MyInvocation.MyCommand.Name) BEGIN"
    }
    PROCESS { 
        if ($null -eq $connection) { 
            Throw "You must first obtain a MirthConnection by invoking Connect-Mirth"    
        }

        $useGet = $PSBoundParameters.ContainsKey("asGet")

        $PSBoundParameters.Remove("asGet");
        $PSBoundParameters.Remove("Raw");
        $PSBoundParameters.Remove("saveXML");
        $PSBoundParameters.Remove("outFile");

        $CallParams = if ($useGet) {
            New-MirthChannelStatisticsGetRequest @PSBoundParameters
        } else {
            New-MirthChannelStatisticsPostRequest @PSBoundParameters
        }

        Write-Debug "Invoking $($CallParams.Method) Mirth $($CallParams.Uri) "
        try { 
            $r = Invoke-RestMethod @CallParams
            Write-Debug "...done."

            #a non-match returns an empty string,
            #so safety check before printing XML content
            if ($r -is [System.Xml.XmlDocument]) {
                Write-Verbose $r.innerXml
            }

            if ($saveXML) { 
                Save-Content $r $outFile
            }
            
            if ($Raw) {
                $r
            } else {
                ConvertFrom-Xml $r.DocumentElement
            }
        } catch {
            Write-Error $_
        }        
    }
    END { 
        Write-Debug "[$([datetime]::Now)] $($MyInvocation.MyCommand.Name) END"
    }
}
