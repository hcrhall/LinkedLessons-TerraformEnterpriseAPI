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
        $Uri,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateScript({Test-Path -Path $_})]                   
        $Path

    )

    Begin
    {
        Write-Host "$($MyInvocation.MyCommand.Name): Script execution started"                                          

        $Put = @{

            Uri         = $Uri
            Method      = 'Put'
            InFile      = $Path
            ErrorAction = 'Stop'
    
        }

    }
    Process
    {

        try
        {

            Invoke-RestMethod @Put

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
                                 