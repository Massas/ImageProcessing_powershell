
function RectangleF_clone($file){
    $date = Get-Date
    Write-Host "START: RectangleF_clone ($date)"
    Write-Host "filename: $file"

    # Create a Bitmap object from a file.
    $myBitmap = New-Object System.Drawing.Bitmap($file.Filename);

    # Clone a portion of the Bitmap object.
    $cloneRect = New-Object System.Drawing.RectangleF(0, 0, 100, 100);
    $format = $myBitmap.PixelFormat;
    $cloneBitmap = $myBitmap.Clone($cloneRect, $format);

    $filenamestr = Read-Host "please enter save file name"
    $savename = $filenamestr + '.png'
    Write-Host "savename: $savename"
    $cloneBitmap.Save((Get-Location).Path + $savename, [System.Drawing.Imaging.ImageFormat]::Png)
}

# main
Add-Type -AssemblyName System.Windows.Forms

while ($true) {
    $select = Read-Host "please enter and start program."
    if(($select -ne 'q') -or ($select -ne 'Q')){
        $dirname = Get-Location
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = $dirname }
        $null = $FileBrowser.ShowDialog()

        RectangleF_clone($FileBrowser)
    }else {
        $date = Get-Date
        Write-Host "terminate this program ($date)"
        Start-Sleep 1
        return
    }   
}