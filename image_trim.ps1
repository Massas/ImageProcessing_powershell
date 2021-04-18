# .NET Frameworkのアセンブリをロード
Add-Type -AssemblyName System.Drawing

# 元画像読み込み
$SrcBmp = New-Object System.Drawing.Bitmap((Get-Location).Path + "\1200px-Coat_of_Arms_of_Yugra.svg.png")

# トリミング(開始位置(横),開始位置(縦),幅,高さ)
$Rect = New-Object System.Drawing.Rectangle(256, 150, 640, 480);
$DstBmp = $SrcBmp.Clone($Rect, $SrcBmp.PixelFormat)

# トリミング画像保存
$DstBmp.Save((Get-Location).Path + "\after_trim4.png", [System.Drawing.Imaging.ImageFormat]::Png)

# オブジェクト破棄
$SrcBmp.Dispose()
$DstBmp.Dispose()
