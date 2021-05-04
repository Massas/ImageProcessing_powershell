Set-StrictMode -Version Latest
$ErrorActionPreference = "STOP"
$DebugPreference = "Continue"

# アセンブリの読み込み
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ディレクトリ
$dir = $null
# ファイルの一覧
$files = $null
# 位置
$pos = $null

# ファイル表示時初期化処理(ファイル一覧の取得と一覧中のファイルのポジション取得)
function init($path) {
    Write-Host "init: start"

    $file = $null

    # 引数のパスがディレクトリか確認
    if ((Get-Item -LiteralPath $path).PSIsContainer) {
        # ディレクトリ
        $global:dir = $path
    } else {
        # フルパスをフォルダー名とファイル名に分割する
        $global:dir = Split-Path $path -Parent
        $file = $path
    }

    # ファイルの一覧を取得(拡張子がjpeg/jpg/png/bmp/gifのファイルを抽出する)
    $global:files = Get-ChildItem -LiteralPath $global:dir -File | Where-Object {$_.Extension -match "\.(jp(e)?g|png|bmp|gif)$"} | ForEach-Object { $_.FullName }

    if ($null -eq $global:files) {
        $global:files = @()
    } elseif ($global:files -Is [System.String] ) {
        $global:files = @($global:files)
    }

    # 初期位置をセット
    # 現状のこのBegin-Process-End構文内で$resultを扱う意味あるか？
    $global:pos = $global:files | ForEach-Object -Begin {
        $i = 0
        $result = -1    
        Write-Host "[Begin] i: $i"
        Write-Host "[Begin] result: $result"
    } -Process {
        if($_ -eq $file) {
            $result = $i
            Write-Host "[Process:if] i: $i"
            Write-Host "[Process:if] result: $result"    
        }
        $i = $i + 1
        Write-Host "[Process] i: $i"
        Write-Host "[Process] result: $result"

    } -End {
        $result
        Write-Host "[End] i: $i"
        Write-Host "[End] result: $result"

    }

    # ファイル指定が無い場合の初期位置
    if (($global:pos -eq -1) -And ($global:files.Count -gt 0)) {
         $global:pos = 0
    }

    Write-Host "init: end"
}

# 次のファイルへ移動
function next() {
    Write-Host "next: start"

    if ($global:pos -lt 0){
        Write-Host "next: -lt 0"
        return  # -1
    }
    if ($global:pos -eq ($global:files.Count - 1)){ 
        Write-Host "next: -eq count-1"
        return  # 末尾
    }
    # ポジションをひとつ後ろに移す
    $global:pos = $global:pos + 1

    Write-Host "next: end"
}

# 前のファイルへ移動
function prev() {
    Write-Host "prev: start"

    if ($global:pos -lt 0) {
        Write-Host "prev: -lt 0"
        return  # -1
    }
    if ($global:pos -eq 0) {
        Write-Host "prev: -eq 0"
        return  # 先頭
    }
    # ポジションをひとつ前に移す
    $global:pos = $global:pos - 1

    Write-Host "prev: end"
}

# イメージオブジェクトを取得
function get_image() {
    Write-Host "get_image: start"

    if ($global:pos -lt 0) {
        return $null　# -1 
    }

    $result = $null

    # 配列の要素を取得
    $global:files | Select-Object -Index $global:pos | ForEach-Object {
        $file = $_    

        $fs = New-Object System.IO.FileStream(
            $file,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read
        )

        if ($fs) {
            try {
                $result = [System.Drawing.Image]::FromStream($fs)
            } catch {
                $fs.Close()
                throw $_
            }
            $fs.Close()    
        }
    }
    Write-Host "get_image: end"

    return $result
}


# 画像ビューワ
function simple_imageview() {
    Write-Host "simple_imageview: start"

    # formオブジェクトを生成
    $form = New-Object System.Windows.Forms.Form

    # pictureboxオブジェクトを生成
    $pic = New-Object System.Windows.Forms.PictureBox
    $pic.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    
    # Drag & Drop
    $pic.AllowDrop = $true
    $pic.BorderStyle = 2    # Fixed3D
    $pic.Add_DragEnter({$_.Effect = "ALL"})

    # ドラッグ&ドロップ時の処理
    $pic.Add_DragDrop({

        $file = @($_.Data.GetData("FileDrop"))[0]

        # ファイル表示時初期化処理(ファイル一覧の取得と一覧中のファイルのポジション取得)
        init $file

        if ($this.Image) { 
            $this.Image.Dispose() 
        }

        # イメージオブジェクト取得処理
        $this.Image = get_image
    })

    # 方向キー操作時の処理が想定されているはずだが、マウス操作時の処理(MouseDown)が実装されているように見える
    $pic.Add_MouseDown({
        # 押下されたボタンの種類を判断する
        switch ($_.Button) {
            "Right" {   # ここは決して呼ばれない
                Write-Host "Button: Right"

                # 前のファイルへ移動する処理
                prev

                if ($this.Image) { 
                    $this.Image.Dispose() 
                }
                # イメージオブジェクト取得処理
                $this.Image = get_image
            }
            "Left" {    # 現時点ではマウスのクリックでここが呼ばれる
                Write-Host "Button: Left"

                # 次のファイルへ移動する処理
                next

                if ($this.Image) { 
                    $this.Image.Dispose() 
                }

                # イメージオブジェクト取得処理
                $this.Image = get_image
            }
            "Middle" {   # ここは決して呼ばれない
                Write-Host "Button: Middle"

                throw $_
            }
        }
    })

    $form.Controls.Add($pic)
    $form.Size = New-Object System.Drawing.Size(800,600)
    $pic.Size = $form.ClientSize
    $form.Add_Resize({$this.Controls["PICBOX"].Size = $this.ClientSize})
    $form.ShowDialog()

    if ($pic.Image) { $pic.Image.Dispose() }
    Write-Host "simple_imageview: end"
}

# main
simple_imageview
