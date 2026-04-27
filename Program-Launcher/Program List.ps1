Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ------------------------------
# App data
# ------------------------------
$programs = [ordered]@{
    "Password Change" = "C:\Zacs Apps\Password Change.exe"
    "Account Enable"  = "C:\Zacs Apps\Account Enable.exe"
    "Laptop Enable"   = "C:\Zacs Apps\Laptop Enable.exe"
    "Leavers"         = "C:\Zacs Apps\Leavers.exe"
    "Citrix"          = "C:\Zacs Apps\Citrix.exe"
    "CSV Import"      = "C:\Zacs Apps\CSV Import.exe"
}

# ------------------------------
# Form
# ------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "User Provisioning Toolkit"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(900, 650)
$form.MinimumSize = New-Object System.Drawing.Size(800, 600)
$form.BackColor = [System.Drawing.Color]::FromArgb(245, 247, 250)
$form.FormBorderStyle = "Sizable"
$form.MaximizeBox = $true
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# ------------------------------
# Header panel
# ------------------------------
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Dock = "Top"
$headerPanel.Height = 140
$headerPanel.BackColor = [System.Drawing.Color]::White
$headerPanel.Padding = New-Object System.Windows.Forms.Padding(20, 18, 20, 12)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "User Provisioning Toolkit"
$titleLabel.AutoSize = $false
$titleLabel.Size = New-Object System.Drawing.Size(820, 55)
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 20)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(34, 40, 49)
$titleLabel.Location = New-Object System.Drawing.Point(20, 12)

$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Choose a tool below to launch it directly - this program must be run as administrator."
$subtitleLabel.AutoSize = $false
$subtitleLabel.Size = New-Object System.Drawing.Size(820, 60)
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(95, 99, 104)
$subtitleLabel.Location = New-Object System.Drawing.Point(22, 62)

$headerPanel.Controls.Add($titleLabel)
$headerPanel.Controls.Add($subtitleLabel)

# ------------------------------
# Main container
# ------------------------------
$mainPanel = New-Object System.Windows.Forms.Panel
$mainPanel.Dock = "Fill"
$mainPanel.Padding = New-Object System.Windows.Forms.Padding(20, 20, 20, 20)
$mainPanel.BackColor = [System.Drawing.Color]::FromArgb(245, 247, 250)

# ------------------------------
# Section label
# ------------------------------
$instructionsLabel = New-Object System.Windows.Forms.Label
$instructionsLabel.Text = "Available programs"
$instructionsLabel.Dock = "Top"
$instructionsLabel.Height = 30
$instructionsLabel.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 11)
$instructionsLabel.ForeColor = [System.Drawing.Color]::FromArgb(55, 65, 81)
$instructionsLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

# ------------------------------
# Footer label
# ------------------------------
$footerLabel = New-Object System.Windows.Forms.Label
$footerLabel.Text = "Developer - Zac Drinkel (2026)"
$footerLabel.Dock = "Bottom"
$footerLabel.Height = 28
$footerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$footerLabel.ForeColor = [System.Drawing.Color]::FromArgb(107, 114, 128)
$footerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft

# ------------------------------
# Scrollable button area
# ------------------------------
$buttonHostPanel = New-Object System.Windows.Forms.Panel
$buttonHostPanel.Dock = "Fill"
$buttonHostPanel.Padding = New-Object System.Windows.Forms.Padding(0, 10, 0, 10)
$buttonHostPanel.BackColor = [System.Drawing.Color]::Transparent

$buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonPanel.Dock = "Fill"
$buttonPanel.WrapContents = $true
$buttonPanel.AutoScroll = $true
$buttonPanel.FlowDirection = "LeftToRight"
$buttonPanel.BackColor = [System.Drawing.Color]::Transparent
$buttonPanel.Padding = New-Object System.Windows.Forms.Padding(5)
$buttonPanel.Margin = New-Object System.Windows.Forms.Padding(0)

$buttonHostPanel.Controls.Add($buttonPanel)

# ------------------------------
# Create one large button per app
# ------------------------------
foreach ($program in $programs.GetEnumerator()) {
    $programName = $program.Key
    $programPath = $program.Value

    $appButton = New-Object System.Windows.Forms.Button
    $appButton.Text = $programName
    $appButton.Size = New-Object System.Drawing.Size(240, 95)
    $appButton.Margin = New-Object System.Windows.Forms.Padding(10)
    $appButton.FlatStyle = "Flat"
    $appButton.FlatAppearance.BorderSize = 1
    $appButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(210, 214, 220)
    $appButton.BackColor = [System.Drawing.Color]::White
    $appButton.ForeColor = [System.Drawing.Color]::FromArgb(31, 41, 55)
    $appButton.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 11)
    $appButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $appButton.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $appButton.Tag = $programPath

    $defaultBackColor = $appButton.BackColor
    $hoverBackColor = [System.Drawing.Color]::FromArgb(232, 240, 254)

    $appButton.Add_MouseEnter({
        $this.BackColor = $hoverBackColor
    })

    $appButton.Add_MouseLeave({
        $this.BackColor = $defaultBackColor
    })

    $appButton.Add_Click({
        $selectedPath = $this.Tag

        if (-not (Test-Path $selectedPath)) {
            [System.Windows.Forms.MessageBox]::Show(
                "The file could not be found:`n`n$selectedPath",
                "Launch failed",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return
        }

        try {
            Start-Process -FilePath $selectedPath -Verb RunAs
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show(
                "Unable to launch:`n`n$selectedPath`n`n$($_.Exception.Message)",
                "Launch failed",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    })

    $buttonPanel.Controls.Add($appButton)
}

# ------------------------------
# Assemble layout
# ------------------------------
$mainPanel.Controls.Add($buttonHostPanel)
$mainPanel.Controls.Add($footerLabel)
$mainPanel.Controls.Add($instructionsLabel)

$form.Controls.Add($mainPanel)
$form.Controls.Add($headerPanel)

# Show form
[void]$form.ShowDialog()