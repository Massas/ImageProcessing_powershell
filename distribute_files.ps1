
function Copy-Files(){

    add-type -AssemblyName System.Drawing
     
    # �t�@�C�����ۑ�����Ă���p�X
    $filePath = 'C:\work\PowerShell\image_processing'
    # �R�s�[��̃p�X
    $targetPath = 'C:\work\PowerShell\image_processing\dest_distribute'
    # �g���q�ōi�荞��
    $include = @("*.jpg","*.JPG","*.jpeg","*.png")
    # �t�@�C���̍��ڂ��擾
    $files = Get-ChildItem -Path $filePath -Include $include -Recurse -File
     
    foreach($file in Get-ChildItem $files){
        $img=[System.Drawing.Image]::FromFile($file.fullname)
        $resolution = "$($img.Width)" + "x" + "$($img.Height)"
    
        # �p�X�̌���
        $dir = Join-Path $targetPath $resolution
    
        # �p�X�����݂��邩�̊m�F�B���݂��Ȃ��ꍇ�A�t�H���_���쐬
        if(!(Test-Path $dir))
        {
            New-Item $dir -ItemType Directory
        }
        # �t�@�C�����R�s�[
        $file | Copy-Item -Destination $dir
    }
     
    Write-Host "�����I��"
}

# main
while ($true) {
    $select = Read-Host "please enter"
    if(($select -ne 'q') -or ($select -ne 'Q')){
        # distribute
        Copy-Files
    }else {
        $date = Get-Date
        Write-Host "terminate this program ($date)"
        Start-Sleep 1
        return
    }   
}