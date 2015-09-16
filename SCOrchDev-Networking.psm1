﻿#requires -Version 2 -Modules SCOrchDev-Exception
<# 
.Synopsis
    Uses NSLookup to convert a Target's IP Address

.Parameter Target
    The Target machine to lookup

.Parameter Server
    The name of the nameserver to target the lookup to

.Example
    PS C:\Users\G521601> Get-ComputerIPAddress -Host mgoapsmad1
    146.217.167.149

.Example
    PS C:\Users\G521601> Get-ComputerIPAddress -Host mgoapsmad1 -Server mgodc1
    146.217.167.149
#>
function Get-IPAddressFromDNS
{
    Param(
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True)]
        [String]
        $Target,

        [Parameter(Mandatory=$False)]
        [String]
        $Server = $env:COMPUTERNAME
    )

    $Null = $(
        $NSLookupResult = nslookup.exe $Target $Server 2>$null
        $IPAddress = ($NSLookupResult  | Select-String -AllMatches `
                                                         -Pattern '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}' `
            | Select-Object -ExpandProperty Matches `
            | Select-Object -ExpandProperty Value)
        if($IPAddress.Count -ne 2)
        {
            Throw-Exception -Type 'RecordNotFound' `
                            -Message 'DNS Record not found for target' `
                            -Property @{ 'Target' = $Target ; 
                                         'Server' = $Server ;
                                         'NSLookupResult' = $NSLookupResult }
        }
        else
        {
            $IPAddress = $IPAddress[1]
        }
    )
    Return $IPAddress
}
<# 
.Synopsis
    Uses NSLookup to find a targets name

.Parameter Target
    The Target machine to lookup

.Parameter Server
    The name of the nameserver to target the lookup to

.Example
    PS C:\Users\G521601> Get-ComputerIPAddress -Host mgoapsmad1
    146.217.167.149

.Example
    PS C:\Users\G521601> Get-ComputerIPAddress -Host mgoapsmad1 -Server mgodc1
    146.217.167.149
#>
function Get-NameFromDNS
{
    Param(
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True)]
        [String]
        $Target,

        [Parameter(Mandatory=$False)]
        [String]
        $Server = $env:COMPUTERNAME
    )

    $Null = $(
        $NSlookupResult = nslookup.exe $Target $Server
        if("$($NSlookupResult)" -match 'Name:\s+([^\s]+)')
        {
            $ComputerName = $Matches[1]
        }
        else
        {
            Throw-Exception -Type 'ComputerNameNotFoundInDNS' `
                            -Message 'Could not find Computer name in DNS' `
                            -Property @{ 'NSLookupResult' = $NSlookupResult ;
                                         'Target' = $Target ;
                                         'Server' = $Server }
        }
    )
    Return $ComputerName
}
Export-ModuleMember -Function * -Verbose:$false