Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Directory List Generator"
$form.Width = 500
$form.Height = 300

# Source path
#-------------
$srcFolder = New-Object System.Windows.Forms.Label
$srcFolder.Text = "Root Folder:"
$srcFolder.Top = 20
$srcFolder.Left = 10
$form.Controls.Add($srcFolder)

$txtSrcFolder = New-Object System.Windows.Forms.TextBox
$txtSrcFolder.Top = 20
$txtSrcFolder.Left = 110
$txtSrcFolder.Width = 250
$txtSrcFolder.Text = "C:\Users\User\Videos"
$form.Controls.Add($txtSrcFolder)

$srcBtnBrowse = New-Object System.Windows.Forms.Button
$srcBtnBrowse.Text = "Browse"
$srcBtnBrowse.Top = 18
$srcBtnBrowse.Left = 370
$form.Controls.Add($srcBtnBrowse)

$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$srcBtnBrowse.Add_Click({
    if ($folderDialog.ShowDialog() -eq "OK") {
        $txtSrcFolder.Text = $folderDialog.SelectedPath
    }
})
#----------- Source Path End -----------

#Destination Path
#-----------------
$destFolder = New-Object System.Windows.Forms.Label
$destFolder.Text = "Destination Path:"
$destFolder.Top = 50
$destFolder.Left = 10
$form.Controls.Add($destFolder)

$txtDestFolder = New-Object System.Windows.Forms.TextBox
$txtDestFolder.Top = 50
$txtDestFolder.Left = 110
$txtDestFolder.Width = 250
$txtDestFolder.Text = "C:\Users\User\Videos"
$form.Controls.Add($txtDestFolder)

$destBtnBrowse = New-Object System.Windows.Forms.Button
$destBtnBrowse.Text = "Browse"
$destBtnBrowse.Top = 48
$destBtnBrowse.Left = 370
$form.Controls.Add($destBtnBrowse)

$destBtnBrowse.Add_Click({
    if ($folderDialog.ShowDialog() -eq "OK") {
        $txtDestFolder.Text = $folderDialog.SelectedPath
    }
})
#----------- Destination Path End --------

# Parameters
#-----------------------------
$chkboxSize = New-Object System.Windows.Forms.CheckBox
$chkboxSize.Text = "Include file size"
$chkboxSize.Top = 80
$chkboxSize.Left = 10
$form.Controls.Add($chkboxSize)

$chkboxTree = New-Object System.Windows.Forms.CheckBox
$chkboxTree.Text = "Include Tree of Directory"
$chkboxTree.Top = 80
$chkboxTree.Left = 140
$chkboxTree.Width = 200
$form.Controls.Add($chkboxTree)
#---- Parameters End --------------

$FileNumLabel = New-object System.Windows.Forms.Label
$FileNumLabel.Text = "Output File Mode:"
$FileNumLabel.Top = 110
$FileNumLabel.Left = 10
$FileNumLabel.Width = 110
$form.Controls.Add($FileNumLabel)


$cmbFileNum = New-Object System.Windows.Forms.ComboBox
$cmbFileNum.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbFileNum.Top = 105
$cmbFileNum.Left = 120
$cmbFileNum.Items.AddRange(@("One","For Each Folder"))
$cmbFileNum.SelectedIndex = 1
$form.Controls.Add($cmbFileNum)


$FileTypeLabel = New-Object System.Windows.Forms.Label
$FileTypeLabel.Text = "Output File Type:"
$FileTypeLabel.Top = 140
$FileTypeLabel.Left = 10
$form.Controls.Add($FileTypeLabel)

$cmbFileType = New-Object System.Windows.Forms.ComboBox
$cmbFileType.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbFileType.Top = 135
$cmbFileType.Left = 120
$cmbFileType.Items.AddRange(@("txt","csv"))
$cmbFileType.SelectedIndex = 0
$form.Controls.Add($cmbFileType)

$FileRecurseLabel = New-Object System.Windows.Forms.Label
$FileRecurseLabel.Text = "Folder Scope:"
$FileRecurseLabel.Top = 170
$FileRecurseLabel.Left = 10
$form.Controls.Add($FileRecurseLabel)

$cmbFileRecurse = New-Object System.Windows.Forms.ComboBox
$cmbFileRecurse.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbFileRecurse.Top = 165
$cmbFileRecurse.Left = 120
$cmbFileRecurse.Items.AddRange(@("Root Only","Root and Subfolders","Subfolders of root"))
$cmbFileRecurse.SelectedIndex = 0
$form.Controls.Add($cmbFileRecurse)


#--------- Output File END -----------
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Generate"
$btnRun.Top = 200
$btnRun.Left = 100
$form.Controls.Add($btnRun)


$btnRun.Add_Click({
    $SourcePath = $txtSrcFolder.Text
    $DestPath = $txtDestFolder.Text

    $includeSize =$chkboxSize.Checked
    $FolderScope = $cmbFileRecurse.SelectedItem
    $OutputMode = $cmbFileNum.SelectedItem
    $FileType = $cmbFileType.SelectedItem


    [System.Windows.Forms.MessageBox]::Show(
        "Would run script on:`n$SourcePath and Output File at: `n$DestPath"
    )
    $Date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

    # Root and/or subfolders
    switch($FolderScope){
        "Root Only"{$Folders = @(Get-Item $SourcePath)}
        "Root and Subfolders"{
            $Folders = @()
            $Folders += Get-Item $SourcePath
            $Folders += Get-ChildItem -Path $SourcePath -Directory -Recurse | Sort-Object FullName
        }
        "Subfolders of root" {$Folders = Get-ChildItem -Path $SourcePath -Directory -Recurse| Sort-Object FullName}
       
    }
    $FileDetails =@("Name","CreationTime","LastWriteTime")
    if($includeSize){$FileDetails +=@{Name="SizeBytes"; Expression={$_.Length}}}
    $RootFolderPath = (Split-Path $SourcePath -Leaf) -replace '[:\\/*?"<>|\[\]]', '_'
    $IsSingleFile = ($OutputMode -eq "One")

    if($FileType -eq "txt"){

        if ($IsSingleFile){
            $FinalOutput = Join-Path $DestPath "directory_list_${RootFolderPath}_$Date.txt"

            $Folders | ForEach-Object{
                $FolderPath = $_.FullName
                $header = @(
                "=============="
                "Folder : $FolderPath"
                "=============="
                )
                
                $header | Out-File -Encoding utf8 -Append -FilePath $FinalOutput
                Get-ChildItem -Path $FolderPath -File |
                Select-Object $FileDetails | 
                Format-List -Property * | 
                Out-File -Encoding utf8 -Append -FilePath $FinalOutput
            }

        }else{
            $Folders | ForEach-Object {
                $FolderPath = $_.FullName

                $RelativeName = $_.FullName.Replace($SourcePath, "").TrimStart('\')

                if ([string]::IsNullOrWhiteSpace($RelativeName)) {$SafeName = Split-Path $SourcePath -Leaf}
                else {$SafeName = ($RelativeName -replace '[:\\/*?"<>|\[\]]', '_')}

                $OutputFile = Join-Path $DestPath "directory_list_${SafeName}_$Date.txt"
                                $header = @(
                "=============="
                "Folder : $FolderPath"
                "=============="
                )
                $header | Out-File -Encoding utf8 -FilePath $OutputFile
                Get-ChildItem -Path $FolderPath -File | 
                Select-Object $FileDetails | 
                Format-List -Property * | 
                Out-File -Encoding UTF8 -Append -FilePath $OutputFile 
            }     
        }
    }else{#csv
        if ($IsSingleFile){
            $FinalOutput = Join-Path $DestPath "directory_list_${RootFolderPath}_$Date.csv"
            $AllFiles = foreach ($folder in $Folders) {

                $FolderPath = $folder.FullName
                $files = Get-ChildItem -Path $FolderPath -File -ErrorAction SilentlyContinue

                # always emit folder row
                [PSCustomObject]@{
                    Path          = $FolderPath
                    Name          = "<FOLDER>"
                    CreationTime  = $folder.CreationTime
                    LastWriteTime = $folder.LastWriteTime
                    Length        = $null
                }

                # emit files (if any)
                foreach ($file in $files) {
                    [PSCustomObject]@{
                        Path          = $FolderPath
                        Name          = $file.Name
                        CreationTime  = $file.CreationTime
                        LastWriteTime = $file.LastWriteTime
                        Length        = $file.Length
                    }
                }
            }

            $AllFiles | Export-Csv -Path $FinalOutput -NoTypeInformation -Encoding utf8

        }
        else{
            $Folders | ForEach-Object{
                $FolderPath =$_.FullName
                $RelativeName = $_.FullName.Replace($SourcePath, "").TrimStart('\')
                if ([string]::IsNullOrWhiteSpace($RelativeName)) {$SafeName = Split-Path $SourcePath -Leaf}
                    else {$SafeName = ($RelativeName -replace '[:\\/*?"<>|\[\]]', '_')}

                $OutputFile = Join-Path $DestPath "directory_list_${SafeName}_$Date.csv"
                Get-ChildItem -Path $FolderPath -File | 
                Select-Object @{
                        Name="Path"
                        Expression={$FolderPath}
                    }, Name, CreationTime, LastWriteTime, Length | 
                #Format-List -Property * | 
                Export-Csv -Path $OutputFile -NoTypeInformation -Encoding utf8

            }
        }
    }



    


 })

$form.ShowDialog()
