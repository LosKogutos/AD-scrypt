
#Variables declaration
$csv = $PSScriptRoot+ "/User_and_Groups.csv" 
$csvFile = Get-Content -Path $csv 
$csvFinale = $csvFile.ToString().Split(",") 
$MainFilePath = $PSScriptRoot +'\User_and_Groups.csv'
$ImportedData = Import-Csv  $MainFilePath -Delimiter ";" -Header 'Enumerator','UserId', 'GroupName' 
$UserName = $ImportedData | Select "UserId"
$GroupName = $ImportedData | Select "GroupName"
$EnumeratorName = $ImportedData | Select "Enumerator"
$ExportedDataFile = $PSScriptRoot + '\User_and_Groups_ResultFile.csv'
$ErrorFile = $PSScriptRoot + '\User_and_Groups_errors.txt'
$iterator = 0;

$ImportedData  | Select -Skip 1| ForEach-Object {
    $iterator ++
    $tempUser = $_.UserId 
    $tempGroup = $_.GroupName
    $tempUserDisplayName = Get-ADUser -Filter {samaccountname -eq $tempUser} | Select -ExpandProperty name 
    $tempUserObject = Get-ADUser -Filter {samaccountname -eq $tempUser} -Properties *
    $tempGroupObject = (Get-adgroup $tempGroup).distinguishedName
    $hostname = Get-ADComputer -Filter {Description -eq $tempUserDisplayName}  | Select -ExpandProperty name 
    
    
    
    #adding user to group
    try {
    $addgroup = Add-ADGroupMember $tempGroup -Members $tempUser -ErrorAction Continue
    }
    catch {
      "Exception String: $($_.Exception.Message)" >> $ErrorFile
    }
    
    if ( $tempUserObject.memberOf -contains $tempGroupObject) {
    $newRow = New-Object PSObject -Property @{'Enumerator' = $iterator ; 'UserId' = $tempUser ;  'GroupName' = $tempGroup ; 'Hostname' = "Used added" ; 'Result' = "$tempUser successfully added/checked in group" }
    $newRow | Export-Csv $ExportedDataFile -NoType -Append
    } else { 
        $newRow = New-Object PSObject -Property @{'Enumerator' = $iterator ; 'UserId' = $tempUser ;  'GroupName' = $tempGroup ; 'Hostname' = "Used added" ; 'Result' = "$tempUser error while adding to group" }
        $newRow | Export-Csv $ExportedDataFile -NoType -Append
    }

    #adding pc to group 
    $hostnameObject = Get-ADComputer -Filter {Description -eq $tempUserDisplayName} -Properties memberof
    if ($hostnameObject.Count-gt 1 ) {
        
        foreach ($hoster in $hostnameObject) {
            $hosterName = $hoster | select -ExpandProperty name
            
            #Check if successfully added to group
            try {
              $addhost = Add-ADGroupMember $tempGroup -Members $hosterName$
            }
            catch {
              "Exception String: $($_.Exception.Message)" >> $ErrorFile
            }
                #Writing results to csv
                if ( $hoster.memberOf -eq $tempGroupObject) {
                    $newRow2 = New-Object PSObject -Property @{'Enumerator' = $iterator ; 'UserId' = $tempUser ;  'GroupName' = $tempGroup ; 'Hostname' = $hosterName ; 'Result' = "$hosterName added/checked in group" }
                    $newRow2 | Export-Csv $ExportedDataFile -Append
                } else {
                      $newRow2 = New-Object PSObject -Property @{'Enumerator' = $iterator ; 'UserId' = $tempUser ;  'GroupName' = $tempGroup ; 'Hostname' = $hosterName ; 'Result' = "$hosterName error while adding to group" }
                    $newRow2 | Export-Csv $ExportedDataFile -Append
                }
        }
    } elseif($hostnameObject -eq "" ) {
         #Check if there is no pc assigned to user
         if ( $hostnameObject.memberOf -contains $tempGroupObject) {
            $newRow2 = New-Object PSObject -Property @{'Enumerator' = $iterator ; 'UserId' = $tempUser ;  'GroupName' = $tempGroup ; 'Hostname' = $hostname ; 'Result' = "User does not have PC assigned" }
            $newRow2 | Export-Csv $ExportedDataFile -Append
        } else {
            $newRow2 = New-Object PSObject -Property @{'Enumerator' = $iterator ; 'UserId' = $tempUser ;  'GroupName' = $tempGroup ; 'Hostname' = $hostname ; 'Result' = "User does not have PC assigned and is not in the group" }
            $newRow2 | Export-Csv $ExportedDataFile -Append
        }

    } else {
            #Check if pc successfully added to group
            try {
               $addhost = Add-ADGroupMember $tempGroup -Members $hostname$
            }
            catch {
              "Exception String: $($_.Exception.Message)" >> $ErrorFile
            }
         #Writing results to csv
         if ( $hostnameObject.memberOf -contains $tempGroupObject) {
            $newRow2 = New-Object PSObject -Property @{'Enumerator' = $iterator ; 'UserId' = $tempUser ;  'GroupName' = $tempGroup ; 'Hostname' = $hostname ; 'Result' = "$hostname successfully added/checked in group" }
            $newRow2 | Export-Csv $ExportedDataFile -Append
        } else {
            $newRow2 = New-Object PSObject -Property @{'Enumerator' = $iterator ; 'UserId' = $tempUser ;  'GroupName' = $tempGroup ; 'Hostname' = $hostname ; 'Result' = "$hostname error while adding to group" }
            $newRow2 | Export-Csv $ExportedDataFile -Append
        }
    }


}   