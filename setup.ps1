[cmdletbinding()]
param(
    [ValidateSet('local','allremote')]
    [string]$envType
)

$global:setupdefaultsettings = new-object psobject -property @{
    LocalContactConString = 'Server=(localdb)\\mssqllocaldb;Database=aspnet-ContactManager-53bc9b9d-9d6a-45d4-8429-2a2761773502;Trusted_Connection=True;MultipleActiveResultSets=true'
    ScriptDir = $PSScriptRoot
}

function Invoke-SqlNonQuery{
    [cmdletbinding()]
    param(
        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$connectionString,

        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$sql,

        [Parameter(Position=2)]
        [string]$sqlcmdpath = ("$env:ProgramFiles\Microsoft SQL Server\110\Tools\Binn\SQLCMD.EXE")
    )
    process{
        try{
            if( -not (test-path $sqlcmdpath)){
                throw ('sqlcmd not found at [{0}]' -f $sqlcmdpath)
            }
            
            # TODO: parse from connection string passed in
            $server = '(localdb)\mssqllocaldb'
            $database = 'aspnet-ContactMangaer-53bc9b9d-9d6a-45d4-8429-2a2761773502'
            # & sqlcmd --% -S "(localdb)\mssqllocaldb" -d aspnet-ContactMangaer-53bc9b9d-9d6a-45d4-8429-2a2761773502 -E -Q "Select * from Contact" -W
            & $sqlcmdpath -S $server -d $database -E -Q $sql -W
        }
        catch{
            $_
        }
    }
}

function CreateAppSettingsSecrets{
    [cmdletbinding()]
    param(
        [Parameter(Position=0)]
        [string]$contactConnectionString,

        [Parameter(Position=1)]
        [string]$sourceRootPath = $global:setupdefaultsettings.ScriptDir
    )
    process{
        $jsonContent = @'
{
    "ConnectionStrings": {
        "ContactConnection": "$ContactConnectionValue$"
    }
}
'@
        $jsonContent = $jsonContent.Replace('$ContactConnectionValue$',$contactConnectionString)
        $appSecretsRelpath = 'ContactManager\ContactManager\appsettings.secrets.user'
        $destFilePath = (Join-Path -Path $global:setupdefaultsettings.ScriptDir -ChildPath $appSecretsRelpath)
        'Creating appsetings secrets file at [{0}]' -f $destFilePath | Write-Verbose
        Out-File -InputObject $jsonContent -LiteralPath $destFilePath -Encoding ascii
    }
}

function SetupLocal{
    [cmdletbinding()]
    param(
        [string]$localContactConString = ($global:setupdefaultsettings.LocalContactConString)
    )
    process{
        # localdb is automatically created no need to create
        
        # create appsettings.secrets.user with the connection string
        CreateAppSettingsSecrets -contactConnectionString $localContactConString
        
        'Running: dotnet ef database update' | Write-Output
        & dotnet ef database update
        
        $sql = @'
        INSERT INTO Contact (Address, FirstName, LastName, Phone)
        VALUES (a3, f3, l3,p3);
'@
        Invoke-SqlNonQuery -connectionString $localContactConString -sql $sql
    }
}

function SetupRemote{
    [cmdletbinding()]
    param()
    process{
        
    }
}


try{
    Push-Location -Path (Join-Path $global:setupdefaultsettings.ScriptDir 'ContactManager\ContactManager')
    SetupLocal
}
catch{
    $_ | Write-Warning
}
Pop-Location

