function New-MirthChannelStatisticsGetRequest {
    <#
    .SYNOPSIS
        Generate a valid GET request for channel statistics.
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
        [switch]$AggregateStats
    )
    
    begin {
        Write-Debug "[$([datetime]::Now)] $($MyInvocation.MyCommand.Name) BEGIN"
    }
    
    process {
        [Microsoft.PowerShell.Commands.WebRequestSession]$session = $connection.session
        $serverUrl = $connection.serverUrl

        $uri = $serverUrl + "/api/channels/statistics"

        $parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('ChannelId')) {
            foreach ($value in $ChannelId) {
                $parameters.Add('channelId', $value)
            }
        }
        if ($PSBoundParameters.ContainsKey('IncludeUndeployed')) {
            $parameters.Add('includeUndeployed', $IncludeUndeployed)
        }
        if ($PSBoundParameters.ContainsKey('AggregateStats')) {
            $parameters.Add('aggregateStats', $AggregateStats)
        }

        switch ($PSCmdlet.ParameterSetName) {
            'IncludeMetadataId' {
                foreach ($value in $IncludeMetadataId) {
                    $parameters.Add('includeMetadataId', $value)
                }
            }
            'ExcludeMetadataId' {
                foreach ($value in $ExcludeMetadataId) {
                    $parameters.Add('excludeMetadataId', $value)
                }
            }
            Default { Write-Error "Unknown parameter set used" }
        }

        $uri = $uri + '?' + $parameters.toString()

        $headers = $DEFAULT_HEADERS.Clone()
        $headers.Add("accept", "application/xml")

        return @{
            "Uri"        = $uri
            "Method"     = "GET"
            "WebSession" = $session
            "Headers"    = $headers
        }
    }
    
    end {
        Write-Debug "[$([datetime]::Now)] $($MyInvocation.MyCommand.Name) END"
    }
}