param(
    [string]$dbxToken,
    [string]$workspaceId,
    [string]$clusterName,
    [string]$nodeSku="Standard_DS3_v2",
    [int]$numWorkers = 2
)
<#
  Generic RestCall
#>
Function Invoke-DataBricksRestCall{
    param(
    [String]$uri,
    [string]$accessToken,
    [string]$invokeVerb,
    [psobject]$requestBody
    )

    try{
        $body = @{ 
         
            OutVariable     = 'status' 
            Method          = $invokeVerb 
            UseBasicParsing = $true 
            Headers         = @{ 
                Authorization  = "Bearer $($accessToken)" 
                'Content-Type' = 'application/json' 
            } 
        } 

        Invoke-WebRequest -uri $uri -Body $requestBody @body 
 
        $body.Method = 'Get' 
        $status[0].RawContent -split "\n" | Where-Object {$_ -match "(^Location: )(?<GetURL>https://.+)"} 
 
        while ($status[0].StatusCode -eq 202) 
        { 
            start-sleep -Seconds 60
            Invoke-WebRequest -uri $Matches.GetURL @Body | select StatusCode,StatusDescription,Headers 
        
        } 

        $response = $Status[0].StatusCode
    }
    catch{
        Return "Exception $_"
    }
    Return $response
} 



<#

#>


$uri = "https://$workspaceId.azuredatabricks.net/api/2.0/clusters/create"

    $body = @{
        cluster_name = $clusterName
        spark_version= "5.3.x-scala2.11"
        node_type_id = $nodeSku
        spark_conf = @{
          "spark.speculation" = $true
        }
        num_workers= $numWorkers
      } | ConvertTo-json  
try{
  $status = Invoke-ResourceMangerRestCall -uri $uri -accessToken $dbxToken -requestBody $body -invokeVerb "POST"

  return $status
} catch {
    throw $_
}
