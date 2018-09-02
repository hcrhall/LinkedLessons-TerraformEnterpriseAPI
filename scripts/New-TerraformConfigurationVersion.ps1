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
        $Token

    )

    Begin
    {
        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"
        
        $Json = @{

            "data"= @{
    
                "type"="configuration-version"
                "attributes"= @{
                  "auto-queue-runs"=$false
                }
            }

        } | ConvertTo-Json

        $Post = @{

            Uri         = "https://app.terraform.io/api/v2/workspaces/$WorkSpaceID/configuration-versions"
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

            Write-Host ('##vso[task.setvariable variable=TFE_UPLOADURL]{0}' -f $Result.attributes.'upload-url')
            Write-Host ('##vso[task.setvariable variable=TFE_CONFIGID]{0}' -f $Result.id)

            Return $Result

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
