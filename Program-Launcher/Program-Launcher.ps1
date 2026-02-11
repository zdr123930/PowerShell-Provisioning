Add-Type -AssemblyName System.Windows.Forms

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "APP NAME"
$form.Size = New-Object System.Drawing.Size(300,300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"

# Create ListBox
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,10)
$listBox.Size = New-Object System.Drawing.Size(200,120)

# Add programs and their paths to the list
$programs = @{
    "App 1" = "PATH\TO\APP1"
    "App 2" = "PATH\TO\APP2"
    "App 3" = "PATH\TO\APP3"
    "App 4" = "PATH\TO\APP4"
    "App 5" = "PATH\TO\APP5"
    "App 6" = "PATH\TO\APP6"
}

$programs.Keys | ForEach-Object {
    $listBox.Items.Add($_)
}

# Create Button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,140)
$button.Size = New-Object System.Drawing.Size(100,30)
$button.Text = "Launch"
$button.Add_Click({
    $selectedProgram = $listBox.SelectedItem
    if ($selectedProgram -ne $null) {
        $programPath = $programs[$selectedProgram]
        Start-Process $programPath -Verb RunAs
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select a program to launch.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Add controls to form
$form.Controls.Add($listBox)
$form.Controls.Add($button)

# Show the form
$form.ShowDialog() | Out-Null
