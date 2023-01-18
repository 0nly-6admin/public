$WhatIfPreference = $false
$directory = 'C:\Scripts\departure\'
$destination = '\\SMBMAP\Inventories\SEC Access Control\LEAVERS_PROFILE'
$targetOU = 'OU=_User Accounts Disabled,DC=yourdomain,DC=com'
#$EVLeavers = 'EV_leavers'

# File server for user profile
$smb_server = 'SMB_SERVER_NAME'
$home_folder_smb_server = 'SMB_SERVER_PROFILE'
$home_folder_location = 'SMB_PROFILE_DIRECTORY'
$home_folder_destination = 'SMB_PROFILE_DESTINATION'

$user = Get-ADUser -SearchBase 'DC=yourdomain,DC=com' -Filter * | Out-GridView -PassThru –title "Select User to Disable" | Select-Object -ExpandProperty DistinguishedName

Write-Host $user

#Write-Warning '******************************************'
#Write-Warning '***** WARNING, LAST CHANCE TO CANCEL *****'
#Write-Warning '******************************************'
#Write-Warning $('Do you really want to disable user : ' + $user) -WarningAction Inquire 

Function Show-MsgBox ($Text,$Title="",[Windows.Forms.MessageBoxButtons]$Button = "OK",[Windows.Forms.MessageBoxIcon]$Icon="Information"){
[Windows.Forms.MessageBox]::Show("$Text", "$Title", [Windows.Forms.MessageBoxButtons]::$Button, $Icon) | Where-Object{(!($_ -eq "OK"))}}
If((Show-MsgBox -Title 'Employee Departure' -Text $('Would you like to disable user: ' + $user) -Button YesNo -Icon Warning) -eq 'No'){Exit}

$user = Get-ADUser $user

$transcript = $($directory + $user.samAccountName + '_transcript_' + (get-date -Format dd-MM-yyyy) + '.txt')
$groups_extract = $($directory + $user.samAccountName + '_groups_' + (get-date -Format dd-MM-yyyy) + '.csv')

Start-Transcript -Path $transcript
Write-Information $('***** Starting script for user: ' + $user.SamAccountName + ' at ' + (Get-Date) + ' *****')

Write-Information $('***** Extracting groups for user: ' + $user.SamAccountName + ' *****')
Write-Information $('***** Exporting groups to: ' + $groups_extract + ' *****')
$groups = Get-ADPrincipalGroupMembership -Identity $user.SamAccountName | Select-Object Name, distinguishedName | Sort-Object Name
$groups | Export-Csv -Path $groups_extract -Encoding UTF8 -NoTypeInformation

foreach($group in $groups){
    if($group.distinguishedName -ne 'CN=Domain Users,CN=Users,DC=yourdomain,DC=com'){
        Write-Information $('***** Removing user: ' + $user.SamAccountName + ' from: ' + $group.distinguishedName + ' *****')
        Remove-ADGroupMember -Identity $group.distinguishedName -Members $user.DistinguishedName -Confirm:$false -Verbose
    }
}

Write-Information $('***** Adding user ' + $user.SamAccountName + ' to : ' + $EVLeavers + ' *****')
# Add-ADGroupMember -Identity $EVLeavers -Members $user.SamAccountName
Write-Information $('***** Disabling user ' + $user.SamAccountName + ' *****')
Set-ADUser $user.samAccountName -Enabled:$false -Verbose
Write-Information $('***** Hidding user ' + $user.SamAccountName + ' from GAL *****')
Set-ADUser $user.samAccountName -Add @{msexchhidefromaddresslists=$true} -Verbose
Write-Information $('***** Moving user ' + $user.SamAccountName + ' to: ' + $targetOU + ' *****')
Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOU -Verbose

##########################################
# Move home folder to backup location
$user = (Get-ADUser -Identity $user.SamAccountName)

$home_folder = $($home_folder_location + $user.Name)
$home_folder_backup = $($home_folder_destination + $user.GivenName + "_" + $user.Name)

$home_folder_smb_session = New-CimSession -ComputerName $home_folder_smb_server
$home_folder_smb_path = $('*\Home\' + $user.samAccountName + '\*')
$OpenFiles = Get-SmbOpenFile -CimSession $home_folder_smb_session | Where-Object{$_.Path -like $home_folder_smb_path}
foreach($OpenFile in $OpenFiles){
    $OpenFile | Close-SmbOpenFile -Force
}
Remove-CimSession -CimSession $home_folder_smb_session

Write-Information $('Trying to move home folder to backup destination')
if(Test-Path $home_folder){
    
    Write-Information $('Moving : ' + $home_folder + 'to : ' + $home_folder_backup )
    try{
        Move-Item -Path $home_folder -Destination $home_folder_backup -Force
    }
    catch{
        Write-Error $('Unable to move home folder to the destination')
        }
}

Write-Information $('***** Script Ended at: ' + (get-date) + '*****')

try { Stop-Transcript } catch {}

    if(!(Test-Path -Path $destination)){
        Write-Warning $('Network path not found : ' + $destination)
    }

    if(Test-Path -Path $transcript){
        try{
            Move-Item -Path $transcript  -Destination $destination -Force
        }
        catch{
            Write-Error $('Error copying file: ' + $transcript)
        }
    }
    else{
        Write-Warning $('File ' + $($transcript) + "cannot be found")
    }
    if(Test-Path -Path $groups_extract){

        $smb_session = New-CimSession -ComputerName $smb_server
        $smb_path = $('*\Home\' + $user.samAccountName + '\*')

        $OpenFiles = Get-SmbOpenFile -CimSession $smb_session | Where-Object{$_.Path -like $smb_path}
        foreach($OpenFile in $OpenFiles){
            $OpenFile | Close-SmbOpenFile -Force
        }
        Remove-CimSession -CimSession $smb_session
        
        try{
            Move-Item -Path $groups_extract  -Destination $destination -Force
        }
        catch{
            Write-Error $('Error copying file: ' + $groups_extract)
        }
    }
    else{
        Write-Warning $('File ' + $($groups_extract) + 'cannot be found')
    }
    
Write-Host $('Script Completed for user : ' + $user.SamAccountName)
Write-Host $('Script Ended at: ' + $(Get-Date))
