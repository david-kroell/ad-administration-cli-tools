# Gets all users from specific OU(s) and creates home directories

# Inputs needed:
# base path for home directories
# Administrative Principle (user with FullControl)
# OU

Import-Module ActiveDirectory

$allOus = Get-ADOrganizationalUnit -Filter *

$baseHomeDir = Read-Host 'What is the base directory of your homes?'
$administrativePrinciple = Read-Host 'Who should be the Principle with FullControl?'

$allOus | % {$counter = 1}{
    Write-Host $counter $_.DistinguishedName 
    $counter++
}

Write-Output ''

$inputIndizes = Read-Host 'Select OU (multiselect colon-seperated)'

Write-Output 'Home directories created for:'

$selectedIndizes = $inputIndizes.split(',')

$selectedIndizes | %{
    $curOU = $allOus[ $_ - 1].DistinguishedName # get current ou object

    # loop over every user in current OU
    Get-ADUser -SearchBase $curOU -Filter * | %{

    Write-Output $_.SamAccountName

        $newDir = New-Item -ItemType directory -Path $($baseHomeDir + '\' + $_.SamAccountName)

        $Acl = Get-Acl $newDir
        # remove all acls from object
        $Acl.Access | ForEach-Object {
            $Acl.RemoveAccessRule($_) | Out-Null #prevent output
        }

        # break inheritance
        $Acl.SetAccessRuleProtection($true, $false)

        # $_.SamAccountName equals the folder name
        $ArAdmin = New-Object  System.Security.AccessControl.FileSystemAccessRule($administrativePrinciple, "FullControl", "ContainerInherit,ObjectInherit","None", "Allow")
        $ArUser = New-Object  System.Security.AccessControl.FileSystemAccessRule($_.SamAccountName ,"Modify","ContainerInherit,ObjectInherit","None", "Allow")

        # add users and admin permissions
        $Acl.SetAccessRule($ArAdmin)
        $Acl.SetAccessRule($ArUser)

        Set-Acl $newDir.FullName $Acl
    }
}
