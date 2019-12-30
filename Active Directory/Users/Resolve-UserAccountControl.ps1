Function Resolve-UserAccountControl()
{

    param(
        [Parameter(Mandatory)]
        [string]
        $Username
    )

    begin {
        $uacPropertyFlags = @(
            'SCRIPT',
            'ACCOUNTDISABLE',
            'RESERVED',
            'HOMEDIR_REQUIRED',
            'LOCKOUT',
            'PASSWD_NOTREQD',
            'PASSWD_CANT_CHANGE',
            'ENCRYPTED_TEXT_PWD_ALLOWED',
            'TEMP_DUPLICATE_ACCOUNT',
            'NORMAL_ACCOUNT',
            'RESERVED',
            'INTERDOMAIN_TRUST_ACCOUNT',
            'WORKSTATION_TRUST_ACCOUNT',
            'SERVER_TRUST_ACCOUNT',
            'RESERVED',
            'RESERVED',
            'DONT_EXPIRE_PASSWORD',
            'MNS_LOGON_ACCOUNT',
            'SMARTCARD_REQUIRED',
            'TRUSTED_FOR_DELEGATION',
            'NOT_DELEGATED',
            'USE_DES_KEY_ONLY',
            'DONT_REQ_PREAUTH',
            'PASSWORD_EXPIRED',
            'TRUSTED_TO_AUTH_FOR_DELEGATION',
            'RESERVED',
            'PARTIAL_SECRETS_ACCOUNT'
            'RESERVED'
            'RESERVED'
            'RESERVED'
            'RESERVED'
            'RESERVED'
        )

        $userUAC = (Get-ADUser -Identity $Username -Properties useraccountcontrol).useraccountcontrol
    }

    process {
        $flags = New-Object System.Collections.Generic.List[System.Object]
        foreach ($i in $uacPropertyFlags)
        {
            if ($userUAC -bAnd [math]::Pow(2, [array]::IndexOf($uacPropertyFlags, $i)))
            {
                $flags.add($i)
            }
        }
    }
             
    end {
        $flags    
    }
}  