<#
.Synopsis
   Allows operators to create Terraform Workspaces in Terraform Enterprise via the API using PowerShell
.DESCRIPTION
   Allows operators to create Terraform Workspaces in Terraform Enterprise via the API using PowerShell. 
   In order for the workspace to be successfully created you are required to provide each of the following:
    
    1. Organization name (case-sensitive)
    2. Workspace name 
    3. TFE user token

.EXAMPLE
   New-TerraformWorkspace -Organization demo -WorkSpaceName "My Workspace" -Token <Token>
#>

    [CmdletBinding()]
    [Alias()]
    [OutputType([object])]
    Param
    (

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Organization,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $WorkSpaceName,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $Token

    )

    Begin
    {
        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

        $Json = @{ 

            "data"= @{ 
    
                "attributes"= @{ 
        
                    "name"="$WorkSpaceName"
                    "auto-apply"=$true
                    
                }
            "type"="workspaces"
    
            } 

        } | ConvertTo-Json

        $Post = @{

            Uri         = "https://app.terraform.io/api/v2/organizations/$Organization/workspaces"
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

            Write-Host ('##vso[task.setvariable variable=TFE_WORKSPACEID]{0}' -f $Result.id)

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
            If($Result)
            {
            
                Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

            }
        }

        If($ErrorID -eq 422)
        {
            Write-Host "$($MyInvocation.MyCommand.Name): $Message. Getting workspace ID."
            
                try
                {
                    $Get = @{

                        Uri         = "https://app.terraform.io/api/v2/organizations/$Organization/workspaces/$WorkSpaceName"
                        Headers     = @{"Authorization" = "Bearer $Token" } 
                        ContentType = 'application/vnd.api+json'
                        Method      = 'Get'
                        ErrorAction = 'stop'
    
                    }
                    
                    $Result = (Invoke-RestMethod @Get).data
                    
                    Write-Host ('##vso[task.setvariable variable=TFE_WORKSPACEID]{0}' -f $Result.id)
                    
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
                    If($Result)
                    {
            
                        Write-Host "$($MyInvocation.MyCommand.Name): Script execution complete"

                    }
                }
        }
    }
    End
    {
    }