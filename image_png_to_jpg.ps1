Add-Type -AssemblyName System.Drawing
# 画像読み込み
$src_image = [System.Drawing.Image]::FromFile((Get-Location).Path + "\1200px-Coat_of_Arms_of_Yugra.svg.png")
# JPG形式で保存
$src_image.Save((Get-Location).Path + "\test_png2jpg.jpg", [System.Drawing.Imaging.ImageFormat]::Jpeg)
# オブジェクトを破棄
$src_image.Dispose()
