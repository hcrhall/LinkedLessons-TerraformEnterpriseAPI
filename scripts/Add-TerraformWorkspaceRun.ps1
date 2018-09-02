<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $WorkSpaceID,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $ConfigVersionID,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $Token

    )

    Begin
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

        $Comment = "Run Requested By $($env:RELEASE_REQUESTEDFOR) for $($env:RELEASE_RELEASENAME) build number $($env:BUILD_BUILDNUMBER) "
        
        $Json = @{
          "data"= @{
            "attributes"= @{
              "is-destroy"=$false
              "message"= $Comment
            }
            "type"="runs"
            "relationships"= @{
              "workspace"= @{
                "data"= @{
                  "type"= "workspaces"
                  "id"= "$WorkSpaceID"
                }
              }
              "configuration-version"= @{
                "data"= @{
                  "type"= "configuration-versions"
                  "id"= "$ConfigVersionID"
                }
              }
            }
          }
        } | ConvertTo-Json -Depth 5

        $Post = @{

            Uri         = "https://app.terraform.io/api/v2/runs"
            Headers     = @{"Authorization" = "Bearer $Token" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $Json
            ErrorAction = 'stop'
    
        }

    }
    Process
    {

        try
        {
            
            $Result = (Invoke-RestMethod @Post).data

            Write-Host ('##vso[task.setvariable variable=TFE_RUNID]{0}' -f $Result.id)

        }
        catch
        {

            $ErrorID = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.status
            $Message = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.detail
            $Exception = ($Error[0].ErrorDetails.Message | ConvertFrom-Json).errors.title
            
            Write-Error -Exception $Exception -Message $Message -ErrorId $ErrorID

        }
        finally
        {

            Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

        }

    }
    End
    {
    }