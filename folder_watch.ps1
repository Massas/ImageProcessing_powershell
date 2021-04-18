
function Folder_watch($foldername){
    $date = Get-Date
    Write-Host "START: Folder_watch ($date)"
    $Watcher = New-Object System.IO.FileSystemWatcher "$foldername"

    While ($True) {
        # 10•b‚¨‚«‚ÉŠÄŽ‹
        $Result = $Watcher.WaitForChanged([System.IO.WatcherChangeTypes]::All, 10000)
        If ($Result.TimedOut -eq $False) {
            $date = Get-Date
            Write-Host "CHANGED: Folder_watch ($date)"
            $Result
        }
#        $date = Get-Date
#        Write-Host "NOT CHANGED: Folder_watch ($date)"
    }
}

# main
while ($true) {
    $select = Read-Host "please enter folder full path name"
    if(($select -ne 'q') -or ($select -ne 'Q')){
        # watch folder
        Folder_watch($select)
    }else {
        $date = Get-Date
        Write-Host "terminate this program ($date)"
        Start-Sleep 1
        return
    }   
}