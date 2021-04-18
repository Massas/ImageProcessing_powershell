
function Folder_watch($foldername){
    Write-Host "START: Folder_watch (Get-Date)"
    $Watcher = New-Object System.IO.FileSystemWatcher "$foldername"

    While ($True) {
        # 10•b‚¨‚«‚ÉŠÄŽ‹
        $Result = $Watcher.WaitForChanged([System.IO.WatcherChangeTypes]::All, 10000)
        If ($Result.TimedOut -eq $False) {
            Write-Host "CHANGED: Folder_watch (Get-Date)"
            $Result
        }
#        Write-Host "NOT CHANGED: Folder_watch (Get-Date)"
    }
}

# main
while ($true) {
    $select = Read-Host "please enter folder full path name"
    if(($select -ne 'q') -or ($select -ne 'Q')){
        # watch folder
        Folder_watch($select)
    }else {
        Write-Host "terminate this program (Get-Date)"
        Start-Sleep 1
        return
    }   
}