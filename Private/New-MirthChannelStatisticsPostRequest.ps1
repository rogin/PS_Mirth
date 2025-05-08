function New-MirthChannelStatisticsPostRequest {
    <#
    .SYNOPSIS
        Generate a valid POST request for channel statistics.
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

        $uri = $serverUrl + "/api/channels/statistics/_getStatistics"

        $payload = @{}

        if ($PSBoundParameters.ContainsKey('ChannelId')) {
            $payload['channelIds'] = $ChannelId
        }

        $payload['includeUndeployed'] = $PSBoundParameters.ContainsKey('IncludeUndeployed')
        $payload['aggregateStats'] = $PSBoundParameters.ContainsKey('AggregateStats')


        switch ($PSCmdlet.ParameterSetName) {
            'IncludeMetadataId' {
                $payload['includeMetadataId'] = $IncludeMetadataId
            }
            'ExcludeMetadataId' {
                $payload['excludeMetadataId'] = $ExcludeMetadataId
            }
            Default { Write-Error "Unknown parameter set used" }
        }

        Write-Debug "Payload = $($payload.GetEnumerator())"

        $headers = $DEFAULT_HEADERS.Clone()
        $headers.Add("accept", "application/xml")

        return @{
            "Uri"        = $uri
            "Method"     = "POST"
            "WebSession" = $session
            "Headers"    = $headers
            "Form"       = $payload
        }
    }
    
    end {
        Write-Debug "[$([datetime]::Now)] $($MyInvocation.MyCommand.Name) END"
    }
}