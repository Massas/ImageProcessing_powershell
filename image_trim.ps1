# .NET Framework�̃A�Z���u�������[�h
Add-Type -AssemblyName System.Drawing

# ���摜�ǂݍ���
$SrcBmp = New-Object System.Drawing.Bitmap((Get-Location).Path + "\1200px-Coat_of_Arms_of_Yugra.svg.png")

# �g���~���O(�J�n�ʒu(��),�J�n�ʒu(�c),��,����)
$Rect = New-Object System.Drawing.Rectangle(256, 150, 640, 480);
$DstBmp = $SrcBmp.Clone($Rect, $SrcBmp.PixelFormat)

# �g���~���O�摜�ۑ�
$DstBmp.Save((Get-Location).Path + "\after_trim4.png", [System.Drawing.Imaging.ImageFormat]::Png)

# �I�u�W�F�N�g�j��
$SrcBmp.Dispose()
$DstBmp.Dispose()
