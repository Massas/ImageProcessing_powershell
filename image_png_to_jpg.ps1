Add-Type -AssemblyName System.Drawing
# �摜�ǂݍ���
$src_image = [System.Drawing.Image]::FromFile((Get-Location).Path + "\1200px-Coat_of_Arms_of_Yugra.svg.png")
# JPG�`���ŕۑ�
$src_image.Save((Get-Location).Path + "\test_png2jpg.jpg", [System.Drawing.Imaging.ImageFormat]::Jpeg)
# �I�u�W�F�N�g��j��
$src_image.Dispose()
