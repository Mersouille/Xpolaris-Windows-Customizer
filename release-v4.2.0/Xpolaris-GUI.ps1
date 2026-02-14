#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Xpolaris Windows Customizer - Interface Graphique WPF
.DESCRIPTION
    Interface graphique moderne pour personnaliser Windows sans bloatware
.NOTES
    Version: 4.1.0
    Date: 13 fevrier 2026
    Auteur: Xpolaris
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configuration globale
if ($MyInvocation.MyCommand.Path) {
    $Global:ISOPath = Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    $Global:ISOPath = Split-Path -Parent ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)
}

$Global:WorkDir = "$Global:ISOPath\CustomizeWork"
$Global:MountDir = "$Global:WorkDir\Mount"
$Global:CustomISODir = "$Global:WorkDir\CustomISO"
$Global:OutputISO = "$Global:ISOPath\Windows_Custom_Xpolaris.iso"
$Global:SelectedISOPath = ""
$Global:DarkMode = $true
$Global:ExtractedWimPath = ""
$Global:ExtractedEditionName = ""

# Interface XAML
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Xpolaris Windows Customizer Pro" 
        Height="800" Width="1200"
        WindowStartupLocation="CenterScreen"
        Background="#1A1A2E"
        FontFamily="Segoe UI">
    
    <Window.Resources>
        <Style x:Key="ModernButton" TargetType="Button">
            <Setter Property="Background" Value="#6A11CB"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="20,10"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#2575FC"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="border" Property="Background" Value="#404040"/>
                                <Setter Property="Foreground" Value="#808080"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#EEEEEE"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Margin" Value="5,4"/>
        </Style>
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="#EEEEEE"/>
            <Setter Property="FontSize" Value="13"/>
        </Style>
        <Style TargetType="GroupBox">
            <Setter Property="Foreground" Value="#00C9FF"/>
            <Setter Property="BorderBrush" Value="#404040"/>
            <Setter Property="Margin" Value="8"/>
            <Setter Property="Padding" Value="10"/>
        </Style>
        <Style TargetType="TabItem">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="15,8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border x:Name="Border" Background="#2D2D44" CornerRadius="6,6,0,0" Margin="2,0" Padding="15,8">
                            <ContentPresenter x:Name="ContentSite" ContentSource="Header" HorizontalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#6A11CB"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#4A4A6A"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Border Grid.Row="0" Padding="20,15">
            <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                    <GradientStop Color="#6A11CB" Offset="0"/>
                    <GradientStop Color="#2575FC" Offset="1"/>
                </LinearGradientBrush>
            </Border.Background>
            <Grid>
                <StackPanel>
                    <TextBlock Text="XPOLARIS WINDOWS CUSTOMIZER PRO" FontSize="26" FontWeight="Bold" Foreground="White"/>
                    <TextBlock Text="Version 4.1.0 - Interface Moderne" FontSize="12" Foreground="#CCCCCC" Margin="0,5,0,0"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                    <Button Name="btnTheme" Content="Theme" Style="{StaticResource ModernButton}" Width="100" Background="#2D2D44" Margin="5,0"/>
                    <Button Name="btnAbout" Content="A propos" Style="{StaticResource ModernButton}" Width="100" Background="#2D2D44"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- Main Content -->
        <TabControl Name="mainTabControl" Grid.Row="1" Background="#2D2D2D" BorderThickness="0" Margin="10">
            
            <!-- Tab 1: Selection ISO -->
            <TabItem Header="Selection ISO" FontSize="14">
                <Grid Margin="15">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <GroupBox Grid.Row="0" Header="Fichier ISO Source">
                        <StackPanel>
                            <TextBlock Text="Selectionnez votre fichier ISO Windows 11 :" Margin="0,0,0,10"/>
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <TextBox Name="txtISOPath" Grid.Column="0" Height="35" Padding="10,8" FontSize="13" Background="#383838" Foreground="White" BorderBrush="#555555" IsReadOnly="True"/>
                                <Button Name="btnBrowseISO" Grid.Column="1" Content="Parcourir..." Style="{StaticResource ModernButton}" Width="130" Margin="10,0,0,0"/>
                            </Grid>
                            <TextBlock Name="lblISOInfo" Text="[INFO] Glissez-deposez votre fichier ISO ici ou utilisez le bouton Parcourir" Foreground="#888888" FontStyle="Italic" Margin="0,10,0,0"/>
                        </StackPanel>
                    </GroupBox>

                    <GroupBox Grid.Row="1" Header="Edition Windows" Margin="0,10,0,0">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            <StackPanel Grid.Row="0">
                                <TextBlock Text="Selectionnez l'edition a extraire :" Margin="0,0,0,10"/>
                                <Button Name="btnLoadEditions" Content="Charger les editions disponibles" Style="{StaticResource ModernButton}" HorizontalAlignment="Left"/>
                            </StackPanel>
                            <ListBox Name="lstEditions" Grid.Row="1" Margin="0,15,0,0" Background="#383838" Foreground="White" BorderBrush="#555555" FontSize="13" Padding="5"/>
                            
                            <!-- Champ affichant l'edition selectionnee -->
                            <Border Grid.Row="2" Background="#2D2D44" CornerRadius="4" Padding="10,8" Margin="0,10,0,0">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="Edition choisie : " Foreground="#888888" VerticalAlignment="Center"/>
                                    <TextBlock Name="lblSelectedEdition" Text="Aucune selection" Foreground="#00C9FF" FontWeight="SemiBold" VerticalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                            
                            <!-- Bouton d'extraction optionnel (moins visible) -->
                            <Button Name="btnExtractEdition" Grid.Row="3" Content="Pre-extraire (optionnel)" Style="{StaticResource ModernButton}" HorizontalAlignment="Right" Margin="0,10,0,0" IsEnabled="False" Background="#555555" FontSize="11" Padding="10,5" ToolTip="Optionnel : Pre-extrait l'edition avant le processus complet"/>
                        </Grid>
                    </GroupBox>
                </Grid>
            </TabItem>

            <!-- Tab 2: Personnalisation -->
            <TabItem Header="Personnalisation" FontSize="14">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <Grid Margin="15">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <GroupBox Grid.Column="0" Grid.Row="0" Header="Applications a supprimer">
                            <StackPanel>
                                <CheckBox Name="chkCortana" Content="Cortana" IsChecked="True"/>
                                <CheckBox Name="chkXbox" Content="Xbox et services gaming" IsChecked="True"/>
                                <CheckBox Name="chkOneDrive" Content="OneDrive" IsChecked="True"/>
                                <CheckBox Name="chkTeams" Content="Microsoft Teams" IsChecked="True"/>
                                <CheckBox Name="chkSkype" Content="Skype" IsChecked="True"/>
                                <CheckBox Name="chkNews" Content="Actualites et Meteo" IsChecked="True"/>
                                <CheckBox Name="chkMaps" Content="Cartes Windows" IsChecked="True"/>
                                <CheckBox Name="chkFeedback" Content="Feedback Hub" IsChecked="True"/>
                                <CheckBox Name="chkTips" Content="Astuces Windows" IsChecked="True"/>
                                <CheckBox Name="chkSolitaire" Content="Solitaire Collection" IsChecked="True"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Column="1" Grid.Row="0" Header="Optimisations systeme">
                            <StackPanel>
                                <CheckBox Name="chkTelemetry" Content="Desactiver la telemetrie" IsChecked="True"/>
                                <CheckBox Name="chkDefender" Content="Optimiser Windows Defender" IsChecked="False"/>
                                <CheckBox Name="chkUpdates" Content="Controler Windows Update" IsChecked="False"/>
                                <CheckBox Name="chkStartMenu" Content="Menu Demarrer classique" IsChecked="True"/>
                                <CheckBox Name="chkTaskbar" Content="Barre des taches simplifiee" IsChecked="True"/>
                                <CheckBox Name="chkExplorer" Content="Afficher extensions fichiers" IsChecked="True"/>
                                <CheckBox Name="chkWidgets" Content="Desactiver les widgets" IsChecked="True"/>
                                <CheckBox Name="chkCopilot" Content="Desactiver Copilot" IsChecked="True"/>
                                <CheckBox Name="chkRecall" Content="Desactiver Recall" IsChecked="True"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Column="0" Grid.Row="1" Header="Services a desactiver">
                            <StackPanel>
                                <CheckBox Name="chkDiagTrack" Content="DiagTrack (Telemetrie)" IsChecked="True"/>
                                <CheckBox Name="chkWSearch" Content="Windows Search (optionnel)" IsChecked="False"/>
                                <CheckBox Name="chkSuperFetch" Content="SysMain/SuperFetch" IsChecked="False"/>
                                <CheckBox Name="chkPrint" Content="Spouleur d'impression" IsChecked="False"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Column="1" Grid.Row="1" Header="Options avancees">
                            <StackPanel>
                                <CheckBox Name="chkCompact" Content="Compression systeme (ESD)" IsChecked="False"/>
                                <CheckBox Name="chkCleanup" Content="Nettoyage composants" IsChecked="True"/>
                                <CheckBox Name="chkOptimizeWim" Content="Optimiser install.wim" IsChecked="True"/>
                            </StackPanel>
                        </GroupBox>
                    </Grid>
                </ScrollViewer>
            </TabItem>

            <!-- Tab 3: Creation ISO -->
            <TabItem Header="Creation ISO" FontSize="14">
                <Grid Margin="15">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <GroupBox Grid.Row="0" Header="Fichier de sortie">
                        <StackPanel>
                            <TextBlock Text="Dossier de destination :" Margin="0,0,0,10"/>
                            <Grid Margin="0,0,0,15">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <TextBox Name="txtOutputFolder" Grid.Column="0" Height="35" Padding="10,8" FontSize="13" Background="#383838" Foreground="White" BorderBrush="#555555" IsReadOnly="True" Text="C:\"/>
                                <Button Name="btnBrowseFolder" Grid.Column="1" Content="Dossier..." Style="{StaticResource ModernButton}" Width="130" Margin="10,0,0,0"/>
                            </Grid>
                            <TextBlock Text="Nom du fichier ISO a creer :" Margin="0,0,0,10"/>
                            <TextBox Name="txtOutputISO" Height="35" Padding="10,8" FontSize="13" Background="#383838" Foreground="White" BorderBrush="#555555" Text="Windows_Custom_Xpolaris.iso"/>
                            <TextBlock Name="lblOutputPath" Text="Fichier final : C:\Windows_Custom_Xpolaris.iso" Foreground="#888888" FontStyle="Italic" Margin="0,10,0,0"/>
                        </StackPanel>
                    </GroupBox>

                    <GroupBox Grid.Row="1" Header="Processus complet" Margin="0,10,0,0">
                        <StackPanel>
                            <TextBlock Text="Le processus complet effectuera automatiquement :" Margin="0,0,0,10"/>
                            <StackPanel Margin="15,0,0,0">
                                <TextBlock Text="- Extraction de l'edition Windows selectionnee" Foreground="#4CAF50"/>
                                <TextBlock Text="- Suppression des composants non desires" Foreground="#4CAF50"/>
                                <TextBlock Text="- Application des personnalisations" Foreground="#4CAF50"/>
                                <TextBlock Text="- Integration des scripts de post-installation" Foreground="#4CAF50"/>
                                <TextBlock Text="- Creation de l'ISO final" Foreground="#4CAF50"/>
                                <TextBlock Text="- Nettoyage des fichiers temporaires" Foreground="#4CAF50"/>
                            </StackPanel>
                            <Button Name="btnStartComplete" Content="DEMARRER LE PROCESSUS COMPLET" Style="{StaticResource ModernButton}" Height="50" FontSize="16" Margin="0,20,0,0" Background="#4CAF50"/>
                            <Button Name="btnStop" Content="Arreter le processus" Style="{StaticResource ModernButton}" Height="35" Margin="0,10,0,0" Background="#F44336" IsEnabled="False"/>
                            <Button Name="btnCleanup" Content="Nettoyer (demonter images WIM bloquees)" Style="{StaticResource ModernButton}" Height="35" Margin="0,10,0,0" Background="#FF9800"/>
                        </StackPanel>
                    </GroupBox>

                    <GroupBox Grid.Row="2" Header="Progression" Margin="0,10,0,0">
                        <StackPanel>
                            <TextBlock Name="lblCurrentStepTab" Text="En attente..." FontSize="14" FontWeight="SemiBold" Margin="0,0,0,10"/>
                            <TextBlock Text="La barre de progression est visible en bas de la fenetre" FontSize="12" Foreground="#888888" FontStyle="Italic"/>
                        </StackPanel>
                    </GroupBox>
                </Grid>
            </TabItem>

            <!-- Tab 4: Logs -->
            <TabItem Header="Logs" FontSize="14">
                <Grid Margin="15">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    <TextBox Name="txtLogs" Grid.Row="0" Background="#1E1E1E" Foreground="#00FF00" FontFamily="Consolas" FontSize="12" IsReadOnly="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" Padding="10"/>
                    <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,10,0,0">
                        <Button Name="btnClearLogs" Content="Effacer" Style="{StaticResource ModernButton}" Width="120" Margin="0,0,10,0"/>
                        <Button Name="btnExportLogs" Content="Exporter" Style="{StaticResource ModernButton}" Width="120"/>
                    </StackPanel>
                </Grid>
            </TabItem>
        </TabControl>

        <!-- Status Bar -->
        <Border Grid.Row="2" Background="#252536" Padding="15,10">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock Name="lblStatus" Grid.Column="0" Text="[OK] Pret" Foreground="#4CAF50" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <Grid Grid.Column="1" Margin="20,0">
                    <ProgressBar Name="progressBar" Height="20" Minimum="0" Maximum="100" Value="0" Background="#404040" Foreground="#6A11CB"/>
                    <TextBlock Name="lblProgressPercent" Text="0%" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="White" FontWeight="Bold"/>
                </Grid>
                <TextBlock Name="lblCurrentStep" Grid.Column="1" Text="En attente..." Foreground="#AAAAAA" VerticalAlignment="Center" HorizontalAlignment="Center" Margin="0,25,0,0"/>
                <TextBlock Name="lblVersion" Grid.Column="2" Text="v4.1.0 | Xpolaris 2026" Foreground="#666666" VerticalAlignment="Center"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

# Charger le XAML
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [Windows.Markup.XamlReader]::Load($reader)

# Recuperer les controles
$btnBrowseISO = $window.FindName("btnBrowseISO")
$btnLoadEditions = $window.FindName("btnLoadEditions")
$btnExtractEdition = $window.FindName("btnExtractEdition")
$btnStartComplete = $window.FindName("btnStartComplete")
$btnStop = $window.FindName("btnStop")
$btnCleanup = $window.FindName("btnCleanup")
$btnTheme = $window.FindName("btnTheme")
$btnAbout = $window.FindName("btnAbout")
$btnClearLogs = $window.FindName("btnClearLogs")
$btnExportLogs = $window.FindName("btnExportLogs")
$btnBrowseFolder = $window.FindName("btnBrowseFolder")

$txtISOPath = $window.FindName("txtISOPath")
$txtOutputISO = $window.FindName("txtOutputISO")
$txtOutputFolder = $window.FindName("txtOutputFolder")
$txtLogs = $window.FindName("txtLogs")
$lstEditions = $window.FindName("lstEditions")
$progressBar = $window.FindName("progressBar")
$lblCurrentStep = $window.FindName("lblCurrentStep")
$lblProgressPercent = $window.FindName("lblProgressPercent")
$lblStatus = $window.FindName("lblStatus")
$lblISOInfo = $window.FindName("lblISOInfo")
$lblVersion = $window.FindName("lblVersion")
$lblOutputPath = $window.FindName("lblOutputPath")
$lblSelectedEdition = $window.FindName("lblSelectedEdition")
$mainTabControl = $window.FindName("mainTabControl")

# ============================================
# FONCTIONS UTILITAIRES
# ============================================

function Write-Log {
    param([string]$Message, [string]$Type = "Info")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = switch ($Type) {
        "Success" { "[OK]" }
        "Error"   { "[ERREUR]" }
        "Warning" { "[ATTENTION]" }
        default   { "[INFO]" }
    }
    $logMessage = "[$timestamp] $prefix $Message"
    $window.Dispatcher.Invoke([action]{
        $txtLogs.AppendText("$logMessage`r`n")
        $txtLogs.ScrollToEnd()
    })
}

function Update-Progress {
    param([int]$Value, [string]$Status = "")
    $window.Dispatcher.Invoke([action]{
        $progressBar.Value = $Value
        $lblProgressPercent.Text = "$Value%"
        if ($Status) { $lblCurrentStep.Text = $Status }
    })
}

# ============================================
# FONCTIONS DE SELECTION
# ============================================

function Select-ISOFile {
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Fichiers ISO (*.iso)|*.iso"
    $openFileDialog.Title = "Selectionnez un fichier ISO Windows"
    
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtISOPath.Text = $openFileDialog.FileName
        $Global:SelectedISOPath = $openFileDialog.FileName
        Write-Log "ISO selectionne : $($openFileDialog.FileName)" "Success"
        
        $fileInfo = Get-Item $openFileDialog.FileName
        $sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        $lblISOInfo.Text = "[OK] ISO charge : $($fileInfo.Name) ($sizeMB MB)"
        $lblISOInfo.Foreground = "#4CAF50"
    }
}

function Select-OutputFolder {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Selectionnez le dossier de destination"
    
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtOutputFolder.Text = $folderBrowser.SelectedPath
        $fullPath = Join-Path $folderBrowser.SelectedPath $txtOutputISO.Text
        $lblOutputPath.Text = "Fichier final : $fullPath"
        Write-Log "Dossier de destination : $($folderBrowser.SelectedPath)" "Success"
    }
}

# ============================================
# FONCTIONS PRINCIPALES
# ============================================

function Load-Editions {
    if ([string]::IsNullOrEmpty($Global:SelectedISOPath)) {
        Write-Log "Veuillez d'abord selectionner un fichier ISO" "Warning"
        return
    }
    
    Write-Log "Chargement des editions disponibles..." "Info"
    $btnLoadEditions.IsEnabled = $false
    
    try {
        $mountResult = Mount-DiskImage -ImagePath $Global:SelectedISOPath -PassThru
        $driveLetter = ($mountResult | Get-Volume).DriveLetter
        $installWim = "${driveLetter}:\sources\install.wim"
        
        if (Test-Path $installWim) {
            $images = Get-WindowsImage -ImagePath $installWim
            $lstEditions.Items.Clear()
            foreach ($image in $images) {
                $item = "$($image.ImageIndex) - $($image.ImageName)"
                $lstEditions.Items.Add($item)
            }
            Write-Log "$($images.Count) edition(s) trouvee(s)" "Success"
        }
        
        Dismount-DiskImage -ImagePath $Global:SelectedISOPath | Out-Null
    }
    catch {
        Write-Log "Erreur lors du chargement : $_" "Error"
    }
    finally {
        $btnLoadEditions.IsEnabled = $true
    }
}

function Extract-SelectedEdition {
    if ($lstEditions.SelectedIndex -lt 0) {
        Write-Log "Veuillez selectionner une edition dans la liste" "Warning"
        return
    }
    
    if ([string]::IsNullOrEmpty($Global:SelectedISOPath)) {
        Write-Log "Veuillez d'abord selectionner un fichier ISO" "Warning"
        return
    }
    
    $selectedEdition = $lstEditions.SelectedItem
    $editionIndex = [int]($selectedEdition.Split(" - ")[0])
    
    Write-Log "========================================" "Info"
    Write-Log "EXTRACTION DE L'EDITION" "Info"
    Write-Log "Edition : $selectedEdition" "Info"
    Write-Log "========================================" "Info"
    
    $btnExtractEdition.IsEnabled = $false
    $btnLoadEditions.IsEnabled = $false
    
    $refreshUI = {
        param($ms)
        $window.Dispatcher.Invoke([action]{}, "Background")
        if ($ms -gt 0) { Start-Sleep -Milliseconds $ms }
    }
    
    try {
        Update-Progress 0 "Montage de l'ISO..."
        & $refreshUI 100
        
        $mountResult = Mount-DiskImage -ImagePath $Global:SelectedISOPath -PassThru
        $driveLetter = ($mountResult | Get-Volume).DriveLetter
        $installWim = "${driveLetter}:\sources\install.wim"
        
        if (-not (Test-Path $installWim)) {
            throw "Fichier install.wim non trouve dans l'ISO"
        }
        
        Write-Log "ISO monte sur ${driveLetter}:" "Success"
        Update-Progress 10 "ISO monte"
        & $refreshUI 200
        
        $workDir = "$Global:ISOPath\CustomizeWork"
        if (-not (Test-Path $workDir)) {
            New-Item -ItemType Directory -Path $workDir -Force | Out-Null
        }
        
        $outputWim = "$workDir\install_extracted.wim"
        
        Update-Progress 15 "Preparation de l'export..."
        & $refreshUI 100
        
        Write-Log "Export DISM de l'edition $editionIndex..." "Info"
        Write-Log "Cette operation peut prendre 5-15 minutes..." "Info"
        
        Update-Progress 20 "Export de l'edition..."
        & $refreshUI 100
        
        if (Test-Path $outputWim) {
            Remove-Item $outputWim -Force
        }
        
        $dismJob = Start-Job -ScriptBlock {
            param($source, $index, $dest)
            & dism /Export-Image /SourceImageFile:"$source" /SourceIndex:$index /DestinationImageFile:"$dest" /Compress:max /CheckIntegrity 2>&1
            return $LASTEXITCODE
        } -ArgumentList $installWim, $editionIndex, $outputWim
        
        $progress = 20
        while ($dismJob.State -eq "Running" -and $progress -lt 85) {
            $progress += 2
            Update-Progress $progress "Export en cours... ($progress%)"
            & $refreshUI 3000
        }
        
        Wait-Job $dismJob | Receive-Job | Out-Null
        Remove-Job $dismJob
        
        if (-not (Test-Path $outputWim)) {
            throw "Echec de l'export DISM"
        }
        
        $newSize = [math]::Round((Get-Item $outputWim).Length / 1GB, 2)
        Write-Log "Edition exportee ($newSize GB)" "Success"
        
        Update-Progress 90 "Finalisation..."
        & $refreshUI 200
        
        Dismount-DiskImage -ImagePath $Global:SelectedISOPath | Out-Null
        Write-Log "ISO demonte" "Success"
        
        $Global:ExtractedWimPath = $outputWim
        $Global:ExtractedEditionName = $selectedEdition
        
        Update-Progress 100 "Extraction terminee !"
        & $refreshUI 200
        
        Write-Log "========================================" "Success"
        Write-Log "EXTRACTION TERMINEE AVEC SUCCES !" "Success"
        Write-Log "Edition extraite : $selectedEdition" "Success"
        Write-Log "Taille : $newSize GB" "Success"
        Write-Log "Fichier : $outputWim" "Info"
        Write-Log "========================================" "Success"
        Write-Log "Vous pouvez maintenant cliquer sur DEMARRER LE PROCESSUS COMPLET" "Info"
        
        $editionDisplayName = $selectedEdition
        if ($selectedEdition -match "^\d+\s*-\s*(.+)$") {
            $editionDisplayName = $Matches[1]
        }
        
        $lstEditions.Items.Clear()
        $lstEditions.Items.Add("1 - $editionDisplayName (Pre-extraite)")
        $lstEditions.SelectedIndex = 0
        
        Write-Log "Edition selectionnee automatiquement" "Success"
    }
    catch {
        Write-Log "ERREUR : $_" "Error"
        Update-Progress 0 "Erreur"
        
        try {
            Dismount-DiskImage -ImagePath $Global:SelectedISOPath -ErrorAction SilentlyContinue | Out-Null
        } catch {}
    }
    finally {
        $btnExtractEdition.IsEnabled = $true
        $btnLoadEditions.IsEnabled = $true
    }
}

function Start-Cleanup {
    Write-Log "========== NETTOYAGE MANUEL ==========" "Warning"
    Write-Log "Recherche des images WIM montees..." "Info"
    
    $workDir = "$Global:ISOPath\CustomizeWork"
    $mountDir = "$workDir\Mount"
    
    $cleanupCount = 0
    
    Write-Log "Dechargement des ruches registre..." "Info"
    try {
        & reg unload "HKLM\WIM_SOFTWARE" 2>&1 | Out-Null
        Write-Log "  Ruche WIM_SOFTWARE dechargee" "Success"
        $cleanupCount++
    } catch {}
    try {
        & reg unload "HKLM\WIM_NTUSER" 2>&1 | Out-Null
        Write-Log "  Ruche WIM_NTUSER dechargee" "Success"
        $cleanupCount++
    } catch {}
    
    Write-Log "Recherche des images Windows montees..." "Info"
    try {
        $mountedImages = Get-WindowsImage -Mounted -ErrorAction SilentlyContinue
        if ($mountedImages) {
            foreach ($img in $mountedImages) {
                Write-Log "  Image trouvee : $($img.Path)" "Info"
                & dism /Unmount-Wim /MountDir:"$($img.Path)" /Discard 2>&1 | Out-Null
                Write-Log "  Image demontee : $($img.Path)" "Success"
                $cleanupCount++
            }
        } else {
            Write-Log "  Aucune image montee trouvee" "Info"
        }
    } catch {
        Write-Log "  Erreur lors de la recherche : $_" "Warning"
    }
    
    if (Test-Path $mountDir) {
        Write-Log "Tentative de demontage du dossier Mount local..." "Info"
        try {
            & dism /Unmount-Wim /MountDir:"$mountDir" /Discard 2>&1 | Out-Null
            Write-Log "  Dossier Mount local demonte" "Success"
            $cleanupCount++
        } catch {}
    }
    
    Write-Log "Nettoyage des montages corrompus..." "Info"
    try {
        & dism /Cleanup-Wim 2>&1 | Out-Null
        Write-Log "  Nettoyage DISM effectue" "Success"
    } catch {}
    
    if (Test-Path $mountDir) {
        Write-Log "Suppression du contenu de Mount..." "Info"
        try {
            Remove-Item "$mountDir\*" -Recurse -Force -ErrorAction Stop
            Write-Log "  Contenu de Mount supprime" "Success"
            $cleanupCount++
        } catch {
            Write-Log "  Impossible de supprimer certains fichiers" "Warning"
            Write-Log "  Conseil : Redemarrez l'ordinateur puis reessayez" "Info"
        }
    }
    
    if ($Global:SelectedISOPath -and (Test-Path $Global:SelectedISOPath)) {
        Write-Log "Demontage de l'ISO source..." "Info"
        try {
            Dismount-DiskImage -ImagePath $Global:SelectedISOPath -ErrorAction SilentlyContinue | Out-Null
            Write-Log "  ISO source demonte" "Success"
            $cleanupCount++
        } catch {}
    }
    
    Write-Log "========================================" "Success"
    Write-Log "Nettoyage termine ! ($cleanupCount operation(s))" "Success"
    
    [System.Windows.MessageBox]::Show(
        "Nettoyage termine !`n`n$cleanupCount operation(s) effectuee(s).`n`nSi vous ne pouvez toujours pas supprimer le dossier Mount, redemarrez l'ordinateur.",
        "Nettoyage",
        "OK",
        "Information"
    )
}

function Start-CompleteProcess {
    if ([string]::IsNullOrEmpty($Global:SelectedISOPath)) {
        Write-Log "Veuillez d'abord selectionner un fichier ISO source" "Warning"
        return
    }
    
    if ([string]::IsNullOrEmpty($txtOutputFolder.Text)) {
        Write-Log "Veuillez selectionner un dossier de destination" "Warning"
        return
    }
    
    if ($lstEditions.SelectedIndex -lt 0) {
        Write-Log "Veuillez d'abord charger et selectionner une edition Windows" "Warning"
        return
    }
    
    $outputPath = Join-Path $txtOutputFolder.Text $txtOutputISO.Text
    $selectedEdition = $lstEditions.SelectedItem
    $editionIndex = [int]($selectedEdition.Split(" - ")[0])
    
    Write-Log "========================================" "Info"
    Write-Log "DEMARRAGE DU PROCESSUS COMPLET" "Info"
    Write-Log "ISO Source : $Global:SelectedISOPath" "Info"
    Write-Log "ISO Destination : $outputPath" "Info"
    Write-Log "Edition selectionnee : $selectedEdition" "Info"
    Write-Log "========================================" "Info"
    
    $btnStartComplete.IsEnabled = $false
    $btnStop.IsEnabled = $true
    
    $refreshUI = {
        param($ms)
        $window.Dispatcher.Invoke([action]{}, "Background")
        if ($ms -gt 0) { Start-Sleep -Milliseconds $ms }
    }
    
    $workDir = "$Global:ISOPath\CustomizeWork"
    $mountDir = "$workDir\Mount"
    $customISODir = "$workDir\CustomISO"
    
    try {
        # ETAPE 1 : Preparation
        Update-Progress 0 "Preparation..."
        & $refreshUI 300
        
        Write-Log "Montage de l'ISO source..." "Info"
        Update-Progress 2 "Montage de l'ISO source..."
        & $refreshUI 100
        
        $mountResult = Mount-DiskImage -ImagePath $Global:SelectedISOPath -PassThru
        $driveLetter = ($mountResult | Get-Volume).DriveLetter
        $sourceDir = "${driveLetter}:"
        $installWim = "$sourceDir\sources\install.wim"
        
        if (-not (Test-Path $installWim)) {
            throw "Fichier install.wim non trouve dans l'ISO"
        }
        
        Write-Log "ISO monte sur $sourceDir" "Success"
        Update-Progress 5 "ISO monte"
        & $refreshUI 200
        
        Write-Log "Creation des dossiers de travail..." "Info"
        @($workDir, $mountDir, $customISODir) | ForEach-Object {
            if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
        }
        
        Update-Progress 8 "Copie des fichiers ISO..."
        Write-Log "Copie des fichiers de l'ISO source..." "Info"
        
        Copy-Item "$sourceDir\*" $customISODir -Recurse -Force -Exclude "install.wim"
        
        Write-Log "Fichiers copies" "Success"
        Update-Progress 15 "Fichiers copies"
        & $refreshUI 300
        
        # ETAPE 2 : Export edition
        $singleEditionWim = "$workDir\install_singleedition.wim"
        
        $preExtractedWim = $Global:ExtractedWimPath
        if ($preExtractedWim -and (Test-Path $preExtractedWim)) {
            Write-Log "Utilisation de l'edition pre-extraite..." "Info"
            Update-Progress 18 "Copie de l'edition pre-extraite..."
            & $refreshUI 100
            
            Copy-Item $preExtractedWim $singleEditionWim -Force
            
            Update-Progress 28 "Edition copiee"
            & $refreshUI 200
        }
        else {
            Write-Log "Extraction de l'edition $selectedEdition..." "Info"
            Update-Progress 16 "Extraction de l'edition Windows..."
            & $refreshUI 100
            
            Write-Log "Export DISM en cours (peut prendre plusieurs minutes)..." "Info"
            
            $dismJob = Start-Job -ScriptBlock {
                param($source, $index, $dest)
                & dism /Export-Image /SourceImageFile:"$source" /SourceIndex:$index /DestinationImageFile:"$dest" /Compress:max /CheckIntegrity 2>&1
                return $LASTEXITCODE
            } -ArgumentList $installWim, $editionIndex, $singleEditionWim
            
            $progress = 16
            while ($dismJob.State -eq "Running" -and $progress -lt 28) {
                $progress += 1
                Update-Progress $progress "Export de l'edition... ($progress%)"
                & $refreshUI 2000
            }
            
            Wait-Job $dismJob | Receive-Job | Out-Null
            Remove-Job $dismJob
        }
        
        if (-not (Test-Path $singleEditionWim)) {
            throw "Echec de l'export de l'edition Windows"
        }
        
        Write-Log "Edition extraite avec succes" "Success"
        
        Copy-Item $singleEditionWim "$customISODir\sources\install.wim" -Force
        
        Update-Progress 30 "Edition extraite"
        & $refreshUI 300
        
        # ETAPE 3 : Montage de l'image
        Write-Log "Montage de l'image Windows pour personnalisation..." "Info"
        Update-Progress 32 "Montage de l'image..."
        & $refreshUI 100
        
        $customInstallWim = "$customISODir\sources\install.wim"
        
        Mount-WindowsImage -ImagePath $customInstallWim -Index 1 -Path $mountDir -ErrorAction Stop | Out-Null
        
        Write-Log "Image Windows montee" "Success"
        Update-Progress 40 "Image montee"
        & $refreshUI 300
        
        # ETAPE 4 : Suppression bloatware
        Write-Log "Suppression des applications indesirables..." "Info"
        Update-Progress 42 "Suppression bloatware..."
        & $refreshUI 100
        
        $appsToRemove = @(
            "Microsoft.BingNews"
            "Microsoft.BingWeather"
            "Microsoft.GetHelp"
            "Microsoft.Getstarted"
            "Microsoft.MicrosoftOfficeHub"
            "Microsoft.MicrosoftSolitaireCollection"
            "Microsoft.People"
            "Microsoft.PowerAutomateDesktop"
            "Microsoft.Todos"
            "Microsoft.WindowsAlarms"
            "Microsoft.WindowsFeedbackHub"
            "Microsoft.WindowsMaps"
            "Microsoft.Xbox.TCUI"
            "Microsoft.XboxGameOverlay"
            "Microsoft.XboxGamingOverlay"
            "Microsoft.XboxIdentityProvider"
            "Microsoft.XboxSpeechToTextOverlay"
            "Microsoft.YourPhone"
            "Microsoft.ZuneMusic"
            "Microsoft.ZuneVideo"
            "Clipchamp.Clipchamp"
            "Microsoft.549981C3F5F10"
            "MicrosoftTeams"
        )
        
        $provisionedApps = Get-AppxProvisionedPackage -Path $mountDir -ErrorAction SilentlyContinue
        $removedCount = 0
        
        foreach ($appPattern in $appsToRemove) {
            $matchingApps = $provisionedApps | Where-Object { $_.DisplayName -like "*$appPattern*" }
            foreach ($app in $matchingApps) {
                try {
                    Remove-AppxProvisionedPackage -Path $mountDir -PackageName $app.PackageName -ErrorAction SilentlyContinue | Out-Null
                    $removedCount++
                } catch {}
            }
        }
        
        Write-Log "$removedCount application(s) supprimee(s)" "Success"
        Update-Progress 55 "Bloatware supprime"
        & $refreshUI 300
        
        # ETAPE 5 : Optimisations registre
        Write-Log "Application des optimisations registre..." "Info"
        Update-Progress 58 "Optimisations registre..."
        & $refreshUI 100
        
        $regSoftware = "$mountDir\Windows\System32\config\SOFTWARE"
        $regNtuser = "$mountDir\Users\Default\NTUSER.DAT"
        
        & reg load "HKLM\WIM_SOFTWARE" $regSoftware 2>&1 | Out-Null
        & reg load "HKLM\WIM_NTUSER" $regNtuser 2>&1 | Out-Null
        
        Update-Progress 62 "Desactivation telemetrie..."
        & $refreshUI 200
        
        & reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        Write-Log "  Telemetrie desactivee" "Info"
        
        Update-Progress 65 "Desactivation Cortana..."
        & $refreshUI 200
        
        & reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        Write-Log "  Cortana desactive" "Info"
        
        Update-Progress 68 "Blocage apps suggerees..."
        & $refreshUI 200
        
        & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        Write-Log "  Apps suggerees bloquees" "Info"
        
        Update-Progress 70 "Configuration explorateur..."
        & $refreshUI 200
        
        & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f 2>&1 | Out-Null
        Write-Log "  Explorateur configure" "Info"
        
        Update-Progress 72 "Desactivation widgets..."
        & $refreshUI 200
        
        & reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f 2>&1 | Out-Null
        Write-Log "  Widgets desactives" "Info"
        
        & reg unload "HKLM\WIM_SOFTWARE" 2>&1 | Out-Null
        & reg unload "HKLM\WIM_NTUSER" 2>&1 | Out-Null
        
        Write-Log "Optimisations appliquees" "Success"
        Update-Progress 75 "Optimisations terminees"
        & $refreshUI 300
        
        # ETAPE 6 : Demontage
        Write-Log "Nettoyage de l'image et demontage..." "Info"
        Update-Progress 76 "Nettoyage composants..."
        & $refreshUI 100
        
        & dism /Image:"$mountDir" /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1 | Out-Null
        
        Update-Progress 78 "Demontage de l'image..."
        Write-Log "Demontage avec sauvegarde (peut prendre plusieurs minutes)..." "Info"
        
        Dismount-WindowsImage -Path $mountDir -Save -ErrorAction Stop | Out-Null
        
        Write-Log "Image demontee et sauvegardee" "Success"
        Update-Progress 85 "Image sauvegardee"
        & $refreshUI 300
        
        Dismount-DiskImage -ImagePath $Global:SelectedISOPath | Out-Null
        
        # ETAPE 7 : Creation ISO
        Write-Log "Creation de l'ISO bootable..." "Info"
        Update-Progress 86 "Recherche oscdimg.exe..."
        & $refreshUI 100
        
        $oscdimgPaths = @(
            "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe",
            "C:\Program Files (x86)\Windows Kits\11\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
        )
        
        $oscdimgPath = $null
        foreach ($path in $oscdimgPaths) {
            if (Test-Path $path) {
                $oscdimgPath = $path
                break
            }
        }
        
        if (-not $oscdimgPath) {
            throw "oscdimg.exe non trouve. Installez Windows ADK."
        }
        
        Write-Log "oscdimg.exe trouve" "Success"
        Update-Progress 88 "Creation ISO en cours..."
        & $refreshUI 200
        
        $bootFile1 = "$customISODir\boot\etfsboot.com"
        $bootFile2 = "$customISODir\efi\microsoft\boot\efisys.bin"
        
        if (-not (Test-Path $bootFile1) -or -not (Test-Path $bootFile2)) {
            throw "Fichiers de boot manquants dans l'ISO"
        }
        
        Write-Log "Generation de l'ISO (cette operation peut durer 5-10 minutes)..." "Info"
        
        $oscdimgJob = Start-Job -ScriptBlock {
            param($oscdimg, $source, $dest)
            Set-Location $source
            $bootData = "2#p0,e,b`"boot\etfsboot.com`"#pEF,e,b`"efi\microsoft\boot\efisys.bin`""
            & $oscdimg -m -o -u2 -udfver102 -l"XPOLARIS_WIN" -bootdata:$bootData $source $dest 2>&1
            return $LASTEXITCODE
        } -ArgumentList $oscdimgPath, $customISODir, $outputPath
        
        $progress = 88
        while ($oscdimgJob.State -eq "Running" -and $progress -lt 96) {
            $progress += 1
            Update-Progress $progress "Generation ISO... ($progress%)"
            & $refreshUI 3000
        }
        
        Wait-Job $oscdimgJob | Receive-Job | Out-Null
        Remove-Job $oscdimgJob
        
        if (-not (Test-Path $outputPath)) {
            throw "Echec de la creation de l'ISO"
        }
        
        Write-Log "ISO creee avec succes" "Success"
        Update-Progress 98 "ISO creee"
        & $refreshUI 300
        
        # ETAPE 8 : Nettoyage final
        Write-Log "Nettoyage des fichiers temporaires..." "Info"
        Update-Progress 99 "Nettoyage..."
        & $refreshUI 100
        
        Remove-Item $singleEditionWim -Force -ErrorAction SilentlyContinue
        Remove-Item $mountDir -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $customISODir -Recurse -Force -ErrorAction SilentlyContinue
        
        # TERMINE !
        Update-Progress 100 "Termine !"
        & $refreshUI 200
        
        Write-Log "========================================" "Success"
        Write-Log "PROCESSUS TERMINE AVEC SUCCES !" "Success"
        Write-Log "Fichier cree : $outputPath" "Success"
        $fileInfo = Get-Item $outputPath
        $sizeGB = [math]::Round($fileInfo.Length / 1GB, 2)
        Write-Log "Taille du fichier : $sizeGB GB" "Success"
        Write-Log "========================================" "Success"
        
        $result = [System.Windows.MessageBox]::Show(
            "Processus termine avec succes !`n`nFichier cree :`n$outputPath`n`nVoulez-vous ouvrir le dossier de destination ?",
            "Succes",
            "YesNo",
            "Information"
        )
        
        if ($result -eq "Yes") {
            Start-Process "explorer.exe" -ArgumentList "/select,`"$outputPath`""
        }
    }
    catch {
        Write-Log "ERREUR : $_" "Error"
        Update-Progress 0 "Erreur"
        
        Write-Log "Nettoyage apres erreur..." "Warning"
        
        try {
            & reg unload "HKLM\WIM_SOFTWARE" 2>&1 | Out-Null
            & reg unload "HKLM\WIM_NTUSER" 2>&1 | Out-Null
        } catch {}
        
        try {
            $mountedImages = Get-WindowsImage -Mounted -ErrorAction SilentlyContinue
            foreach ($img in $mountedImages) {
                if ($img.Path -like "*CustomizeWork*") {
                    Dismount-WindowsImage -Path $img.Path -Discard -ErrorAction SilentlyContinue | Out-Null
                }
            }
        } catch {}
        
        try {
            if ($mountDir -and (Test-Path $mountDir)) {
                & dism /Unmount-Wim /MountDir:"$mountDir" /Discard 2>&1 | Out-Null
            }
        } catch {}
        
        try {
            if ($Global:SelectedISOPath -and (Test-Path $Global:SelectedISOPath)) {
                Dismount-DiskImage -ImagePath $Global:SelectedISOPath -ErrorAction SilentlyContinue | Out-Null
            }
        } catch {}
    }
    finally {
        $btnStartComplete.IsEnabled = $true
        $btnStop.IsEnabled = $false
    }
}

function Toggle-Theme {
    $Global:DarkMode = -not $Global:DarkMode
    
    if ($Global:DarkMode) {
        Write-Log "Passage en theme sombre" "Info"
        if ($window) { $window.Background = "#1A1A2E" }
        if ($btnTheme) { $btnTheme.Content = "Theme Sombre" }
        if ($txtLogs) {
            $txtLogs.Foreground = "#00FF00"
            $txtLogs.Background = "#1E1E1E"
        }
        if ($txtISOPath) { 
            $txtISOPath.Background = "#383838"
            $txtISOPath.Foreground = "White"
        }
        if ($txtOutputISO) { 
            $txtOutputISO.Background = "#383838"
            $txtOutputISO.Foreground = "White"
        }
        if ($lstEditions) {
            $lstEditions.Background = "#383838"
            $lstEditions.Foreground = "White"
        }
    }
    else {
        Write-Log "Passage en theme clair" "Info"
        if ($window) { $window.Background = "#F5F5F5" }
        if ($btnTheme) { $btnTheme.Content = "Theme Clair" }
        if ($txtLogs) {
            $txtLogs.Foreground = "#000000"
            $txtLogs.Background = "#FFFFFF"
        }
        if ($txtISOPath) { 
            $txtISOPath.Background = "#FFFFFF"
            $txtISOPath.Foreground = "Black"
        }
        if ($txtOutputISO) { 
            $txtOutputISO.Background = "#FFFFFF"
            $txtOutputISO.Foreground = "Black"
        }
        if ($lstEditions) {
            $lstEditions.Background = "#FFFFFF"
            $lstEditions.Foreground = "Black"
        }
    }
}

# ============================================
# EVENEMENTS
# ============================================

$btnBrowseISO.Add_Click({ Select-ISOFile })
$btnLoadEditions.Add_Click({ Load-Editions })
$btnExtractEdition.Add_Click({ Extract-SelectedEdition })
$btnBrowseFolder.Add_Click({ Select-OutputFolder })
$btnStartComplete.Add_Click({ Start-CompleteProcess })
$btnCleanup.Add_Click({ Start-Cleanup })
$btnTheme.Add_Click({ Toggle-Theme })
$btnClearLogs.Add_Click({ if ($txtLogs) { $txtLogs.Clear() } })
$btnAbout.Add_Click({
    [System.Windows.MessageBox]::Show(
        "Xpolaris Windows Customizer Pro`nVersion 4.1.0`n`n(c) 2026 Xpolaris`n`nInterface graphique moderne pour personnaliser Windows",
        "A propos",
        "OK",
        "Information"
    )
})

$lstEditions.Add_SelectionChanged({
    if ($lstEditions.SelectedIndex -ge 0) {
        $btnExtractEdition.IsEnabled = $true
        # Mettre a jour le label de l'edition selectionnee
        $selectedItem = $lstEditions.SelectedItem
        if ($selectedItem -match "^\d+\s*-\s*(.+)$") {
            $lblSelectedEdition.Text = $Matches[1]
        } else {
            $lblSelectedEdition.Text = $selectedItem
        }
        $lblSelectedEdition.Foreground = "#4CAF50"
    } else {
        $lblSelectedEdition.Text = "Aucune selection"
        $lblSelectedEdition.Foreground = "#00C9FF"
    }
})

$txtOutputISO.Add_TextChanged({
    if ($txtOutputFolder -and $txtOutputISO -and $lblOutputPath) {
        $fullPath = Join-Path $txtOutputFolder.Text $txtOutputISO.Text
        $lblOutputPath.Text = "Fichier final : $fullPath"
    }
})

# Initialiser le chemin de destination par defaut
if ($txtOutputFolder -and $txtOutputISO -and $lblOutputPath) {
    $defaultFolder = [Environment]::GetFolderPath("Desktop")
    $txtOutputFolder.Text = $defaultFolder
    $fullPath = Join-Path $defaultFolder $txtOutputISO.Text
    $lblOutputPath.Text = "Fichier final : $fullPath"
}

# Message de bienvenue
Write-Log "========================================" "Info"
Write-Log "Bienvenue dans Xpolaris Windows Customizer Pro" "Info"
Write-Log "Version 4.1.0" "Info"
Write-Log "========================================" "Info"
Write-Log "1. Selectionnez un fichier ISO Windows 11" "Info"
Write-Log "2. Chargez et selectionnez une edition" "Info"
Write-Log "3. Configurez les options dans l'onglet Personnalisation" "Info"
Write-Log "4. Lancez le processus complet" "Info"
Write-Log "========================================" "Info"

# Afficher la fenetre
$window.ShowDialog() | Out-Null
