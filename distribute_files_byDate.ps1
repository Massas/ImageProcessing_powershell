
function Copy-FilesByDate(){

    add-type -AssemblyName System.Drawing
     
    # ファイルが保存されているパス
    $filePath = 'C:\work\PowerShell\image_processing'
    # コピー先のパス
    $targetPath = 'C:\work\PowerShell\image_processing\dest_distributeByDate'
    # 拡張子で絞り込む
    $include = @("*.jpg","*.JPG","*.jpeg","*.png")
    # ファイルの項目を取得
    $files = Get-ChildItem -Path $filePath -Include $include -Recurse -File
     
    foreach($file in Get-ChildItem $files){
#        $img=[System.Drawing.Image]::FromFile($file.fullname)

        # ファイルの更新日時(年)を取得
        $year = $file.LastWriteTime.Year.ToString()
        # ファイルの更新日時(月)を取得
        $month = $file.LastWriteTime.Month.ToString()
        # ファイルの更新日時(日)を取得
        $day = $file.LastWriteTime.Day.ToString()
        # パスの結合
        $dir = Join-Path $targetPath $year | Join-Path -ChildPath $month | Join-Path -ChildPath $day    
    
        # パスが存在するかの確認。存在しない場合、フォルダを作成
        if(!(Test-Path $dir))
        {
            New-Item $dir -ItemType Directory
        }
        # ファイルをコピー
        $file | Copy-Item -Destination $dir
    }
     
    Write-Host "処理終了"
}

# main
while ($true) {
    $select = Read-Host "please enter"
    if(($select -ne 'q') -or ($select -ne 'Q')){
        # distribute by date
        Copy-FilesByDate
    }else {
        $date = Get-Date
        Write-Host "terminate this program ($date)"
        Start-Sleep 1
        return
    }   
}