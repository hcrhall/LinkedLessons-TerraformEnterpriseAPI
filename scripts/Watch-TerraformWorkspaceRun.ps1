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
        $RunID,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $Token

    )

    Begin
    {

        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"

        $Get = @{

            Uri         = "https://app.terraform.io/api/v2/runs/$RunID"
            Headers     = @{"Authorization" = "Bearer $Token" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Get'
            ErrorAction = 'stop'

        }

        $State = @("applying","canceled","confirmed","discarded","pending","planning","policy_checked","policy_checking","policy_override")

    }
    Process
    {

        try
        {

            do
            {

                $Result = (Invoke-RestMethod @Get).data

                $Status = $Result.attributes.status

                Write-Host "$($MyInvocation.MyCommand.Name): Terraform workspace in '$Status' state"

            }
            while ($Status -in $State)


            switch ($Status)
            {
                'applied'{ Return 0 }
                'planned'{ Return 0 }
                'errored'{ Return 1 }
            }

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