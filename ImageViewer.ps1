Set-StrictMode -Version Latest
$ErrorActionPreference = "STOP"
$DebugPreference = "Continue"

# �A�Z���u���̓ǂݍ���
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# �f�B���N�g��
$dir = $null
# �t�@�C���̈ꗗ
$files = $null
# �ʒu
$pos = $null

# �t�@�C���\��������������(�t�@�C���ꗗ�̎擾�ƈꗗ���̃t�@�C���̃|�W�V�����擾)
function init($path) {
    Write-Host "init: start"

    $file = $null

    # �����̃p�X���f�B���N�g�����m�F
    if ((Get-Item -LiteralPath $path).PSIsContainer) {
        # �f�B���N�g��
        $global:dir = $path
    } else {
        # �t���p�X���t�H���_�[���ƃt�@�C�����ɕ�������
        $global:dir = Split-Path $path -Parent
        $file = $path
    }

    # �t�@�C���̈ꗗ���擾(�g���q��jpeg/jpg/png/bmp/gif�̃t�@�C���𒊏o����)
    $global:files = Get-ChildItem -LiteralPath $global:dir -File | Where-Object {$_.Extension -match "\.(jp(e)?g|png|bmp|gif)$"} | ForEach-Object { $_.FullName }

    if ($null -eq $global:files) {
        $global:files = @()
    } elseif ($global:files -Is [System.String] ) {
        $global:files = @($global:files)
    }

    # �����ʒu���Z�b�g
    # ����̂���Begin-Process-End�\������$result�������Ӗ����邩�H
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

    # �t�@�C���w�肪�����ꍇ�̏����ʒu
    if (($global:pos -eq -1) -And ($global:files.Count -gt 0)) {
         $global:pos = 0
    }

    Write-Host "init: end"
}

# ���̃t�@�C���ֈړ�
function next() {
    Write-Host "next: start"

    if ($global:pos -lt 0){
        Write-Host "next: -lt 0"
        return  # -1
    }
    if ($global:pos -eq ($global:files.Count - 1)){ 
        Write-Host "next: -eq count-1"
        return  # ����
    }
    # �|�W�V�������ЂƂ��Ɉڂ�
    $global:pos = $global:pos + 1

    Write-Host "next: end"
}

# �O�̃t�@�C���ֈړ�
function prev() {
    Write-Host "prev: start"

    if ($global:pos -lt 0) {
        Write-Host "prev: -lt 0"
        return  # -1
    }
    if ($global:pos -eq 0) {
        Write-Host "prev: -eq 0"
        return  # �擪
    }
    # �|�W�V�������ЂƂO�Ɉڂ�
    $global:pos = $global:pos - 1

    Write-Host "prev: end"
}

# �C���[�W�I�u�W�F�N�g���擾
function get_image() {
    Write-Host "get_image: start"

    if ($global:pos -lt 0) {
        return $null�@# -1 
    }

    $result = $null

    # �z��̗v�f���擾
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


# �摜�r���[��
function simple_imageview() {
    Write-Host "simple_imageview: start"

    # form�I�u�W�F�N�g�𐶐�
    $form = New-Object System.Windows.Forms.Form

    # picturebox�I�u�W�F�N�g�𐶐�
    $pic = New-Object System.Windows.Forms.PictureBox
    $pic.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    
    # Drag & Drop
    $pic.AllowDrop = $true
    $pic.BorderStyle = 2    # Fixed3D
    $pic.Add_DragEnter({$_.Effect = "ALL"})

    # �h���b�O&�h���b�v���̏���
    $pic.Add_DragDrop({

        $file = @($_.Data.GetData("FileDrop"))[0]

        # �t�@�C���\��������������(�t�@�C���ꗗ�̎擾�ƈꗗ���̃t�@�C���̃|�W�V�����擾)
        init $file

        if ($this.Image) { 
            $this.Image.Dispose() 
        }

        # �C���[�W�I�u�W�F�N�g�擾����
        $this.Image = get_image
    })

    # �����L�[���쎞�̏������z�肳��Ă���͂������A�}�E�X���쎞�̏���(MouseDown)����������Ă���悤�Ɍ�����
    $pic.Add_MouseDown({
        # �������ꂽ�{�^���̎�ނ𔻒f����
        switch ($_.Button) {
            "Right" {   # �����͌����ČĂ΂�Ȃ�
                Write-Host "Button: Right"

                # �O�̃t�@�C���ֈړ����鏈��
                prev

                if ($this.Image) { 
                    $this.Image.Dispose() 
                }
                # �C���[�W�I�u�W�F�N�g�擾����
                $this.Image = get_image
            }
            "Left" {    # �����_�ł̓}�E�X�̃N���b�N�ł������Ă΂��
                Write-Host "Button: Left"

                # ���̃t�@�C���ֈړ����鏈��
                next

                if ($this.Image) { 
                    $this.Image.Dispose() 
                }

                # �C���[�W�I�u�W�F�N�g�擾����
                $this.Image = get_image
            }
            "Middle" {   # �����͌����ČĂ΂�Ȃ�
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
