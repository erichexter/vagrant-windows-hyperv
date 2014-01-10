function Get-file-hash($source_path, $delimiter) {
    $source_files = @()
    (Get-ChildItem $source_path -rec | ForEach-Object -Process {
      Get-FileHash -Path $_.FullName -Algorithm MD5 } ) |
        ForEach-Object -Process {
          $source_files += ($_.Path -replace $source_path, "") + $delimiter + $_.Hash
        }
    $source_files
}

function Get-Remote-Session($guest_ip, $username, $password) {
    $secstr = convertto-securestring -AsPlainText -Force -String $password
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
    New-PSSession -ComputerName $guest_ip -Credential $cred
}

function Get-remote-file-hash($source_path, $delimiter, $session) {
    Invoke-Command -Session $session -ScriptBlock ${function:Get-file-hash} -ArgumentList $source_path, $delimiter
}

function Sync-Remote-Machine($remove_files, $copy_files, $source_root_path, $destination_root_path) {
    ForEach ($item in $copy_files) {
      $from = $source_root_path + $item
      $to = $destination_root_path + $item
      # Copy VM can also take a VM object
      # Copy-VMFile -VM $vm
      Copy-VMFile "Super-Win_orig" -SourcePath $from -DestinationPath $to -CreateFullPath -FileSource Host -Force
    }
}

function Create-Remote-Folders($empty_source_folders, $destination_root_path) {
    ForEach ($item in $empty_source_folders) {
        $new_name =  $destination_root_path + $item
        New-Item "$new_name" -type directory -Force
    }
}

function Get-Empty-folders-From-Source($source_root_path) {
  Get-ChildItem $source_root_path -recurse |
        Where-Object {$_.PSIsContainer -eq $True} |
            Where-Object {$_.GetFiles().Count -eq 0} |
                Select-Object FullName | ForEach-Object -Process {
                    $empty_source_folders += ($_.FullName -replace $source_root_path, "")
                }
}

$delimiter = " || "
$source_root_path = "E:\\Test_Sync"
$destination_root_path = "C:\\Users\\Vagrant\\Desktop\\Test_Sync"
$guest_ip = "10.18.20.62"
$username = "vagrant"
$password = "happy"
$session = Get-Remote-Session $guest_ip $username $password

$source_files = Get-file-hash $source_root_path $delimiter
$destination_files = Get-remote-file-hash $destination_root_path $delimiter $session

# Compare source and destination files
$remove_files = @()
$copy_files = @()
Compare-Object -ReferenceObject $source_files -DifferenceObject $destination_files | ForEach-Object {
  if ($_.SideIndicator -eq "=>") {
      $remove_files += $_.InputObject.Split($delimiter)[0]
  } else {
      $copy_files += $_.InputObject.Split($delimiter)[0]
  }
}

# Update the files to remote machine
Sync-Remote-Machine $remove_files $copy_files $source_root_path $destination_root_path

# Create any empty folders which missed to sync to remote machine
$empty_source_folders = @()
$directories = Get-Empty-folders-From-Source $source_root_path

$result = Invoke-Command -Session $session -ScriptBlock ${function:Create-Remote-Folders} -ArgumentList $empty_source_folders, $destination_root_path
# Always remove the connection after Use
Remove-PSSession -Id $session.Id
