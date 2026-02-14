#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Xpolaris Windows Customizer - Interface Graphique WPF
.DESCRIPTION
    Interface graphique moderne pour personnaliser Windows sans bloatware
.NOTES
    Version: 4.3.0
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
                    <TextBlock Text="Version 4.3.0 - Interface Complete" FontSize="12" Foreground="#CCCCCC" Margin="0,5,0,0"/>
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
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <!-- Colonne 1 -->
                        <GroupBox Grid.Column="0" Grid.Row="0" Header="Applications a supprimer (Appx)">
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
                                <CheckBox Name="chkClipchamp" Content="Clipchamp" IsChecked="True"/>
                                <CheckBox Name="chkTodos" Content="Microsoft To Do" IsChecked="True"/>
                                <CheckBox Name="chkPowerAutomate" Content="Power Automate Desktop" IsChecked="True"/>
                                <CheckBox Name="chkPeople" Content="Contacts (People)" IsChecked="True"/>
                                <CheckBox Name="chkOfficeHub" Content="Office Hub" IsChecked="True"/>
                                <CheckBox Name="chkZuneMusic" Content="Groove Musique / Zune" IsChecked="True"/>
                                <CheckBox Name="chkZuneVideo" Content="Films et TV / Zune Video" IsChecked="True"/>
                            </StackPanel>
                        </GroupBox>

                        <!-- Colonne 2 -->
                        <GroupBox Grid.Column="1" Grid.Row="0" Header="Composants Windows a supprimer">
                            <StackPanel>
                                <CheckBox Name="chkRemoveIE" Content="Internet Explorer 11" IsChecked="True"/>
                                <CheckBox Name="chkRemoveWMP" Content="Windows Media Player Legacy" IsChecked="True"/>
                                <CheckBox Name="chkRemovePaint3D" Content="Paint 3D et 3D Viewer" IsChecked="True"/>
                                <CheckBox Name="chkRemoveFax" Content="Telecopie et numerisation" IsChecked="True"/>
                                <CheckBox Name="chkRemoveHelloFace" Content="Hello Face (sans camera IR)" IsChecked="False"/>
                                <CheckBox Name="chkRemoveWordPad" Content="WordPad" IsChecked="True"/>
                                <CheckBox Name="chkRemoveXboxSvc" Content="Composants Xbox (services)" IsChecked="True"/>
                                <CheckBox Name="chkRemovePhoneLink" Content="Phone Link / Your Phone" IsChecked="True"/>
                                <CheckBox Name="chkRemoveLangPacks" Content="Packs langues additionnels" IsChecked="False" ToolTip="Garde uniquement fr-FR"/>
                                <CheckBox Name="chkRemoveMixedReality" Content="Mixed Reality Portal" IsChecked="True"/>
                                <CheckBox Name="chkRemoveWallet" Content="Microsoft Wallet" IsChecked="True"/>
                            </StackPanel>
                        </GroupBox>

                        <!-- Colonne 3 -->
                        <GroupBox Grid.Column="2" Grid.Row="0" Header="Optimisations systeme">
                            <StackPanel>
                                <CheckBox Name="chkTelemetry" Content="Desactiver la telemetrie" IsChecked="True"/>
                                <CheckBox Name="chkDefender" Content="Optimiser Windows Defender" IsChecked="False"/>
                                <CheckBox Name="chkUpdates" Content="Controler Windows Update" IsChecked="False"/>
                                <CheckBox Name="chkStartMenu" Content="Menu Demarrer classique" IsChecked="True"/>
                                <CheckBox Name="chkTaskbar" Content="Barre des taches simplifiee" IsChecked="True"/>
                                <CheckBox Name="chkExplorer" Content="Afficher extensions fichiers" IsChecked="True"/>
                                <CheckBox Name="chkShowHidden" Content="Afficher fichiers caches" IsChecked="True"/>
                                <CheckBox Name="chkSyncNotif" Content="Masquer notifs OneDrive Explorer" IsChecked="True"/>
                                <CheckBox Name="chkWidgets" Content="Desactiver les widgets" IsChecked="True"/>
                                <CheckBox Name="chkCopilot" Content="Desactiver Copilot" IsChecked="True"/>
                                <CheckBox Name="chkRecall" Content="Desactiver Recall" IsChecked="True"/>
                                <CheckBox Name="chkPerformance" Content="Optimiser effets visuels" IsChecked="True"/>
                                <CheckBox Name="chkContentDelivery" Content="Bloquer apps auto-installees" IsChecked="True" ToolTip="Bloque 11 cles ContentDeliveryManager"/>
                            </StackPanel>
                        </GroupBox>

                        <!-- Ligne 2 -->
                        <GroupBox Grid.Column="0" Grid.Row="1" Header="Services a desactiver">
                            <StackPanel>
                                <CheckBox Name="chkDiagTrack" Content="DiagTrack (Telemetrie)" IsChecked="True"/>
                                <CheckBox Name="chkWSearch" Content="Windows Search (optionnel)" IsChecked="False"/>
                                <CheckBox Name="chkSuperFetch" Content="SysMain/SuperFetch" IsChecked="False"/>
                                <CheckBox Name="chkPrint" Content="Spouleur d'impression" IsChecked="False"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Column="1" Grid.Row="1" Header="Post-Installation Xpolaris">
                            <StackPanel>
                                <CheckBox Name="chkOEMBranding" Content="Branding OEM Xpolaris" IsChecked="True" ToolTip="Ajoute Xpolaris comme fabricant dans Systeme"/>
                                <CheckBox Name="chkActivateAdmin" Content="Activer compte Administrateur" IsChecked="True"/>
                                <CheckBox Name="chkWallpaper" Content="Fond d'ecran Xpolaris" IsChecked="True" ToolTip="Copie et applique le wallpaper Xpolaris"/>
                                <CheckBox Name="chkRemoveBloatPost" Content="Script RemoveBloatware post-install" IsChecked="True" ToolTip="Nettoyage supplementaire au 1er demarrage"/>
                                <CheckBox Name="chkAppsManager" Content="Xpolaris Apps Manager (tache)" IsChecked="True" ToolTip="Installe les apps recommandees au login"/>
                                <CheckBox Name="chkSetupComplete" Content="SetupComplete.cmd (post-install)" IsChecked="True" ToolTip="Script maitre d'automatisation post-installation"/>
                                <CheckBox Name="chkAutoUnattend" Content="autounattend.xml (install auto)" IsChecked="True" ToolTip="Installation Windows automatisee"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Column="2" Grid.Row="1" Header="Options avancees">
                            <StackPanel>
                                <CheckBox Name="chkCompact" Content="Compression systeme (ESD)" IsChecked="False"/>
                                <CheckBox Name="chkCleanup" Content="Nettoyage composants" IsChecked="True"/>
                                <CheckBox Name="chkOptimizeWim" Content="Optimiser install.wim" IsChecked="True"/>
                            </StackPanel>
                        </GroupBox>

                        <!-- Ligne 3 : Applications a installer via winget -->
                        <GroupBox Grid.Column="0" Grid.ColumnSpan="2" Grid.Row="2" Header="Applications a installer (post-installation via winget)">
                            <WrapPanel>
                                <CheckBox Name="chkInstall7Zip" Content="7-Zip" IsChecked="True" Margin="5,3" ToolTip="winget: 7zip.7zip"/>
                                <CheckBox Name="chkInstallNotepadPP" Content="Notepad++" IsChecked="True" Margin="5,3" ToolTip="winget: Notepad++.Notepad++"/>
                                <CheckBox Name="chkInstallChrome" Content="Google Chrome" IsChecked="True" Margin="5,3" ToolTip="winget: Google.Chrome"/>
                                <CheckBox Name="chkInstallCCleaner" Content="CCleaner" IsChecked="True" Margin="5,3" ToolTip="winget: Piriform.CCleaner"/>
                                <CheckBox Name="chkInstallVLC" Content="VLC Media Player" IsChecked="True" Margin="5,3" ToolTip="winget: VideoLAN.VLC"/>
                                <CheckBox Name="chkInstallTeamViewer" Content="TeamViewer" IsChecked="False" Margin="5,3" ToolTip="winget: TeamViewer.TeamViewer"/>
                            </WrapPanel>
                        </GroupBox>

                        <GroupBox Grid.Column="2" Grid.Row="2" Header="Info apps">
                            <TextBlock TextWrapping="Wrap" FontSize="11" Foreground="#AAAAAA" Margin="3">Les applications cochees seront installees automatiquement au premier demarrage de Windows via winget (necessite connexion internet). Un fallback par telechargement direct est disponible si winget est absent.</TextBlock>
                        </GroupBox>

                        <!-- Ligne 4 : Boutons rapides -->
                        <Border Grid.Column="0" Grid.ColumnSpan="3" Grid.Row="3" Background="#2D2D44" CornerRadius="6" Padding="10,8" Margin="8,5">
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                                <Button Name="btnSelectAll" Content="Tout cocher" Style="{StaticResource ModernButton}" Width="140" Background="#4CAF50" Margin="5,0" FontSize="12"/>
                                <Button Name="btnDeselectAll" Content="Tout decocher" Style="{StaticResource ModernButton}" Width="140" Background="#F44336" Margin="5,0" FontSize="12"/>
                                <Button Name="btnRecommended" Content="Config recommandee" Style="{StaticResource ModernButton}" Width="180" Background="#FF9800" Margin="5,0" FontSize="12"/>
                            </StackPanel>
                        </Border>
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
                <TextBlock Name="lblVersion" Grid.Column="2" Text="v4.3.0 | Xpolaris 2026" Foreground="#666666" VerticalAlignment="Center"/>
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
$btnSelectAll = $window.FindName("btnSelectAll")
$btnDeselectAll = $window.FindName("btnDeselectAll")
$btnRecommended = $window.FindName("btnRecommended")

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

# Nouveaux controles - Composants Windows
$chkRemoveIE = $window.FindName("chkRemoveIE")
$chkRemoveWMP = $window.FindName("chkRemoveWMP")
$chkRemovePaint3D = $window.FindName("chkRemovePaint3D")
$chkRemoveFax = $window.FindName("chkRemoveFax")
$chkRemoveHelloFace = $window.FindName("chkRemoveHelloFace")
$chkRemoveWordPad = $window.FindName("chkRemoveWordPad")
$chkRemoveXboxSvc = $window.FindName("chkRemoveXboxSvc")
$chkRemovePhoneLink = $window.FindName("chkRemovePhoneLink")
$chkRemoveLangPacks = $window.FindName("chkRemoveLangPacks")
$chkRemoveMixedReality = $window.FindName("chkRemoveMixedReality")
$chkRemoveWallet = $window.FindName("chkRemoveWallet")

# Nouveaux controles - Apps supplementaires
$chkClipchamp = $window.FindName("chkClipchamp")
$chkTodos = $window.FindName("chkTodos")
$chkPowerAutomate = $window.FindName("chkPowerAutomate")
$chkPeople = $window.FindName("chkPeople")
$chkOfficeHub = $window.FindName("chkOfficeHub")
$chkZuneMusic = $window.FindName("chkZuneMusic")
$chkZuneVideo = $window.FindName("chkZuneVideo")

# Nouveaux controles - Optimisations supplementaires
$chkShowHidden = $window.FindName("chkShowHidden")
$chkSyncNotif = $window.FindName("chkSyncNotif")
$chkPerformance = $window.FindName("chkPerformance")
$chkContentDelivery = $window.FindName("chkContentDelivery")

# Nouveaux controles - Post-Installation
$chkOEMBranding = $window.FindName("chkOEMBranding")
$chkActivateAdmin = $window.FindName("chkActivateAdmin")
$chkWallpaper = $window.FindName("chkWallpaper")
$chkRemoveBloatPost = $window.FindName("chkRemoveBloatPost")
$chkAppsManager = $window.FindName("chkAppsManager")
$chkSetupComplete = $window.FindName("chkSetupComplete")
$chkAutoUnattend = $window.FindName("chkAutoUnattend")

# Nouveaux controles - Applications a installer
$chkInstall7Zip = $window.FindName("chkInstall7Zip")
$chkInstallNotepadPP = $window.FindName("chkInstallNotepadPP")
$chkInstallChrome = $window.FindName("chkInstallChrome")
$chkInstallCCleaner = $window.FindName("chkInstallCCleaner")
$chkInstallVLC = $window.FindName("chkInstallVLC")
$chkInstallTeamViewer = $window.FindName("chkInstallTeamViewer")

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

function Import-Editions {
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

function Export-SelectedEdition {
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
        } catch { $null = $_ }
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
    } catch { $null = $_ }
    try {
        & reg unload "HKLM\WIM_NTUSER" 2>&1 | Out-Null
        Write-Log "  Ruche WIM_NTUSER dechargee" "Success"
        $cleanupCount++
    } catch { $null = $_ }
    
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
        } catch { $null = $_ }
    }
    
    Write-Log "Nettoyage des montages corrompus..." "Info"
    try {
        & dism /Cleanup-Wim 2>&1 | Out-Null
        Write-Log "  Nettoyage DISM effectue" "Success"
    } catch { $null = $_ }
    
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
        } catch { $null = $_ }
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
        
        # ETAPE 4 : Suppression bloatware (basee sur les checkboxes)
        Write-Log "Suppression des applications indesirables..." "Info"
        Update-Progress 42 "Suppression bloatware..."
        & $refreshUI 100
        
        $appsToRemove = @()
        
        # Apps Appx basees sur les checkboxes
        if ($chkCortana.IsChecked) { $appsToRemove += "Microsoft.549981C3F5F10" }
        if ($chkXbox.IsChecked) {
            $appsToRemove += @("Microsoft.Xbox.TCUI", "Microsoft.XboxGameOverlay", "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider", "Microsoft.XboxSpeechToTextOverlay")
        }
        if ($chkOneDrive.IsChecked) { $appsToRemove += "Microsoft.OneDrive" }
        if ($chkTeams.IsChecked) { $appsToRemove += "MicrosoftTeams" }
        if ($chkSkype.IsChecked) { $appsToRemove += "Microsoft.SkypeApp" }
        if ($chkNews.IsChecked) { $appsToRemove += @("Microsoft.BingNews", "Microsoft.BingWeather") }
        if ($chkMaps.IsChecked) { $appsToRemove += "Microsoft.WindowsMaps" }
        if ($chkFeedback.IsChecked) { $appsToRemove += "Microsoft.WindowsFeedbackHub" }
        if ($chkTips.IsChecked) { $appsToRemove += @("Microsoft.GetHelp", "Microsoft.Getstarted") }
        if ($chkSolitaire.IsChecked) { $appsToRemove += "Microsoft.MicrosoftSolitaireCollection" }
        if ($chkClipchamp.IsChecked) { $appsToRemove += @("Clipchamp.Clipchamp", "Microsoft.Clipchamp") }
        if ($chkTodos.IsChecked) { $appsToRemove += "Microsoft.Todos" }
        if ($chkPowerAutomate.IsChecked) { $appsToRemove += "Microsoft.PowerAutomateDesktop" }
        if ($chkPeople.IsChecked) { $appsToRemove += "Microsoft.People" }
        if ($chkOfficeHub.IsChecked) { $appsToRemove += "Microsoft.MicrosoftOfficeHub" }
        if ($chkZuneMusic.IsChecked) { $appsToRemove += "Microsoft.ZuneMusic" }
        if ($chkZuneVideo.IsChecked) { $appsToRemove += "Microsoft.ZuneVideo" }
        
        $provisionedApps = Get-AppxProvisionedPackage -Path $mountDir -ErrorAction SilentlyContinue
        $removedCount = 0
        
        foreach ($appPattern in $appsToRemove) {
            $matchingApps = $provisionedApps | Where-Object { $_.DisplayName -like "*$appPattern*" }
            foreach ($app in $matchingApps) {
                try {
                    Remove-AppxProvisionedPackage -Path $mountDir -PackageName $app.PackageName -ErrorAction SilentlyContinue | Out-Null
                    $removedCount++
                } catch { $null = $_ }
            }
        }
        
        Write-Log "$removedCount application(s) Appx supprimee(s)" "Success"
        Update-Progress 50 "Bloatware Appx supprime"
        & $refreshUI 300
        
        # ETAPE 4b : Suppression composants Windows (DISM)
        $componentsToRemove = @()
        if ($chkRemoveIE.IsChecked) { $componentsToRemove += "Internet-Explorer-Optional-amd64" }
        if ($chkRemoveWMP.IsChecked) { $componentsToRemove += "WindowsMediaPlayer" }
        if ($chkRemovePaint3D.IsChecked) { $componentsToRemove += @("Microsoft.Windows.MSPaint", "Microsoft.Microsoft3DViewer") }
        if ($chkRemoveFax.IsChecked) { $componentsToRemove += "FaxServicesClientPackage" }
        if ($chkRemoveHelloFace.IsChecked) { $componentsToRemove += "Hello-Face" }
        if ($chkRemoveWordPad.IsChecked) { $componentsToRemove += "Microsoft-Windows-WordPad" }
        if ($chkRemoveXboxSvc.IsChecked) { $componentsToRemove += @("Microsoft-Xbox-Game-CallableUI", "Microsoft-Xbox-GameBar") }
        if ($chkRemovePhoneLink.IsChecked) { $componentsToRemove += @("Microsoft.YourPhone", "Microsoft.WindowsPhone") }
        if ($chkRemoveMixedReality.IsChecked) { $componentsToRemove += "Microsoft.MixedReality.Portal" }
        if ($chkRemoveWallet.IsChecked) { $componentsToRemove += "Microsoft.Wallet" }
        
        if ($componentsToRemove.Count -gt 0) {
            Write-Log "Suppression de $($componentsToRemove.Count) composants Windows..." "Info"
            Update-Progress 52 "Suppression composants Windows..."
            & $refreshUI 100
            
            $compRemoved = 0
            foreach ($component in $componentsToRemove) {
                try {
                    $removed = $false
                    # Tentative 1 : Feature Windows
                    $feature = Get-WindowsOptionalFeature -Path $mountDir -FeatureName $component -ErrorAction SilentlyContinue
                    if ($feature -and $feature.State -eq "Enabled") {
                        Disable-WindowsOptionalFeature -Path $mountDir -FeatureName $component -Remove -NoRestart -ErrorAction Stop | Out-Null
                        $compRemoved++
                        $removed = $true
                    }
                    # Tentative 2 : Package AppX
                    if (-not $removed) {
                        $appxPkgs = $provisionedApps | Where-Object { $_.DisplayName -like "*$component*" }
                        if ($appxPkgs) {
                            foreach ($pkg in $appxPkgs) {
                                Remove-AppxProvisionedPackage -Path $mountDir -PackageName $pkg.PackageName -ErrorAction Stop | Out-Null
                            }
                            $compRemoved++
                            $removed = $true
                        }
                    }
                    # Tentative 3 : Windows Package
                    if (-not $removed) {
                        $winPkgs = Get-WindowsPackage -Path $mountDir -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$component*" }
                        if ($winPkgs) {
                            foreach ($pkg in $winPkgs) {
                                Remove-WindowsPackage -Path $mountDir -PackageName $pkg.PackageName -NoRestart -ErrorAction Stop | Out-Null
                            }
                            $compRemoved++
                        }
                    }
                } catch {
                    Write-Log "  Composant $component : non trouve ou deja supprime" "Warning"
                }
            }
            Write-Log "$compRemoved composant(s) Windows supprime(s)" "Success"
        }
        
        Update-Progress 55 "Composants supprimes"
        & $refreshUI 300
        
        # ETAPE 5 : Optimisations registre (basees sur les checkboxes)
        Write-Log "Application des optimisations registre..." "Info"
        Update-Progress 58 "Optimisations registre..."
        & $refreshUI 100
        
        $regSoftware = "$mountDir\Windows\System32\config\SOFTWARE"
        $regNtuser = "$mountDir\Users\Default\NTUSER.DAT"
        
        & reg load "HKLM\WIM_SOFTWARE" $regSoftware 2>&1 | Out-Null
        & reg load "HKLM\WIM_NTUSER" $regNtuser 2>&1 | Out-Null
        
        $regCount = 0
        
        if ($chkTelemetry.IsChecked) {
            & reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f 2>&1 | Out-Null
            Write-Log "  Telemetrie desactivee" "Info"
            $regCount++
        }
        
        if ($chkCortana.IsChecked) {
            & reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f 2>&1 | Out-Null
            Write-Log "  Cortana desactive" "Info"
            $regCount++
        }
        
        Update-Progress 62 "Configuration ContentDeliveryManager..."
        & $refreshUI 200
        
        if ($chkContentDelivery.IsChecked) {
            $cdmKeys = @(
                "SubscribedContent-338388Enabled",
                "SilentInstalledAppsEnabled",
                "ContentDeliveryAllowed",
                "OemPreInstalledAppsEnabled",
                "PreInstalledAppsEnabled",
                "PreInstalledAppsEverEnabled",
                "SystemPaneSuggestionsEnabled",
                "SubscribedContent-310093Enabled",
                "SubscribedContent-338389Enabled",
                "SubscribedContent-353694Enabled",
                "SubscribedContent-353696Enabled"
            )
            foreach ($key in $cdmKeys) {
                & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v $key /t REG_DWORD /d 0 /f 2>&1 | Out-Null
            }
            Write-Log "  ContentDeliveryManager bloque (11 cles)" "Info"
            $regCount++
        }
        
        Update-Progress 65 "Configuration explorateur..."
        & $refreshUI 200
        
        if ($chkExplorer.IsChecked) {
            & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f 2>&1 | Out-Null
            Write-Log "  Extensions fichiers affichees" "Info"
            $regCount++
        }
        
        if ($chkShowHidden.IsChecked) {
            & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f 2>&1 | Out-Null
            Write-Log "  Fichiers caches affiches" "Info"
            $regCount++
        }
        
        if ($chkSyncNotif.IsChecked) {
            & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSyncProviderNotifications /t REG_DWORD /d 0 /f 2>&1 | Out-Null
            Write-Log "  Notifications OneDrive Explorer masquees" "Info"
            $regCount++
        }
        
        Update-Progress 68 "Configuration widgets et Copilot..."
        & $refreshUI 200
        
        if ($chkWidgets.IsChecked) {
            & reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f 2>&1 | Out-Null
            Write-Log "  Widgets desactives" "Info"
            $regCount++
        }
        
        if ($chkCopilot.IsChecked) {
            & reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f 2>&1 | Out-Null
            & reg add "HKLM\WIM_NTUSER\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f 2>&1 | Out-Null
            Write-Log "  Copilot desactive" "Info"
            $regCount++
        }
        
        if ($chkRecall.IsChecked) {
            & reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v DisableAIDataAnalysis /t REG_DWORD /d 1 /f 2>&1 | Out-Null
            & reg add "HKLM\WIM_NTUSER\Software\Policies\Microsoft\Windows\WindowsAI" /v DisableAIDataAnalysis /t REG_DWORD /d 1 /f 2>&1 | Out-Null
            Write-Log "  Recall desactive" "Info"
            $regCount++
        }
        
        if ($chkPerformance.IsChecked) {
            & reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f 2>&1 | Out-Null
            Write-Log "  Effets visuels optimises (performance)" "Info"
            $regCount++
        }
        
        & reg unload "HKLM\WIM_SOFTWARE" 2>&1 | Out-Null
        & reg unload "HKLM\WIM_NTUSER" 2>&1 | Out-Null
        
        Write-Log "$regCount optimisation(s) registre appliquee(s)" "Success"
        Update-Progress 72 "Optimisations terminees"
        & $refreshUI 300
        
        # ETAPE 5b : Copie fichiers de personnalisation Xpolaris
        Write-Log "Copie des fichiers de personnalisation Xpolaris..." "Info"
        Update-Progress 73 "Fichiers Xpolaris..."
        & $refreshUI 100
        
        $scriptDir = $Global:ISOPath
        $oemScriptsDir = "$customISODir\sources\`$OEM`$\`$`$\Setup\Scripts"
        
        if ($chkAutoUnattend.IsChecked) {
            if (Test-Path "$scriptDir\autounattend.xml") {
                Copy-Item "$scriptDir\autounattend.xml" "$customISODir\autounattend.xml" -Force
                Write-Log "  autounattend.xml copie (install auto)" "Info"
            }
        }
        
        # Creer dossier OEM si necessaire pour post-install
        $needOEM = ($chkWallpaper.IsChecked -or $chkRemoveBloatPost.IsChecked -or $chkAppsManager.IsChecked -or $chkSetupComplete.IsChecked)
        if ($needOEM) {
            if (-not (Test-Path $oemScriptsDir)) {
                New-Item -ItemType Directory -Path $oemScriptsDir -Force | Out-Null
            }
        }
        
        if ($chkWallpaper.IsChecked) {
            if (Test-Path "$scriptDir\XpolarisWallpaper.bmp") {
                Copy-Item "$scriptDir\XpolarisWallpaper.bmp" "$customISODir\sources\XpolarisWallpaper.bmp" -Force
                Copy-Item "$scriptDir\XpolarisWallpaper.bmp" "$oemScriptsDir\XpolarisWallpaper.bmp" -Force
                Write-Log "  Fond d'ecran Xpolaris copie" "Info"
            }
            if (Test-Path "$scriptDir\ApplyWallpaper.ps1") {
                Copy-Item "$scriptDir\ApplyWallpaper.ps1" "$customISODir\sources\ApplyWallpaper.ps1" -Force
                Copy-Item "$scriptDir\ApplyWallpaper.ps1" "$oemScriptsDir\ApplyWallpaper.ps1" -Force
                Write-Log "  ApplyWallpaper.ps1 copie" "Info"
            }
        }
        
        if ($chkRemoveBloatPost.IsChecked) {
            if (Test-Path "$scriptDir\RemoveBloatware.ps1") {
                Copy-Item "$scriptDir\RemoveBloatware.ps1" "$customISODir\sources\RemoveBloatware.ps1" -Force
                Copy-Item "$scriptDir\RemoveBloatware.ps1" "$oemScriptsDir\RemoveBloatware.ps1" -Force
                Write-Log "  RemoveBloatware.ps1 copie" "Info"
            }
        }
        
        if ($chkAppsManager.IsChecked) {
            # Construire la liste des apps selectionnees
            $selectedApps = @()
            $selectedFallback = @()
            if ($chkInstall7Zip.IsChecked) {
                $selectedApps += '            @{ Name = "7-Zip"; Id = "7zip.7zip"; Icon = "[7Z]" }'
                $selectedFallback += '            @{ Name = "7-Zip"; Url = "https://www.7-zip.org/a/7z2408-x64.exe"; FileName = "7z-Setup.exe"; Args = "/S" }'
            }
            if ($chkInstallNotepadPP.IsChecked) {
                $selectedApps += '            @{ Name = "Notepad++"; Id = "Notepad++.Notepad++"; Icon = "[NPP]" }'
                $selectedFallback += '            @{ Name = "Notepad++"; Url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.9/npp.8.6.9.Installer.x64.exe"; FileName = "NotepadPP-Setup.exe"; Args = "/S" }'
            }
            if ($chkInstallChrome.IsChecked) {
                $selectedApps += '            @{ Name = "Google Chrome"; Id = "Google.Chrome"; Icon = "[WEB]" }'
                $selectedFallback += '            @{ Name = "Google Chrome"; Url = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"; FileName = "ChromeSetup.exe"; Args = "/silent /install" }'
            }
            if ($chkInstallCCleaner.IsChecked) {
                $selectedApps += '            @{ Name = "CCleaner"; Id = "Piriform.CCleaner"; Icon = "[CC]" }'
                $selectedFallback += '            @{ Name = "CCleaner"; Url = "https://download.ccleaner.com/ccsetup.exe"; FileName = "CCleaner-Setup.exe"; Args = "/S" }'
            }
            if ($chkInstallVLC.IsChecked) {
                $selectedApps += '            @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC"; Icon = "[VLC]" }'
                $selectedFallback += '            @{ Name = "VLC Media Player"; Url = "https://get.videolan.org/vlc/3.0.20/win64/vlc-3.0.20-win64.exe"; FileName = "VLC-Setup.exe"; Args = "/L=1036 /S" }'
            }
            if ($chkInstallTeamViewer.IsChecked) {
                $selectedApps += '            @{ Name = "TeamViewer"; Id = "TeamViewer.TeamViewer"; Icon = "[TV]" }'
                $selectedFallback += '            @{ Name = "TeamViewer"; Url = "https://download.teamviewer.com/download/TeamViewer_Setup_x64.exe"; FileName = "TeamViewer-Setup.exe"; Args = "/S" }'
            }

            $appCount = $selectedApps.Count
            if ($appCount -gt 0) {
                # Generer le script dynamiquement
                $appsBlock = $selectedApps -join "`r`n"
                $fallbackBlock = $selectedFallback -join "`r`n"
                $appsManagerContent = @"
# Xpolaris Apps Manager - Genere automatiquement par Xpolaris GUI
# Applications selectionnees : $appCount
param([switch]`$AutoMode)
`$ErrorActionPreference = "Continue"
`$IsScheduledTask = `$AutoMode
if (`$IsScheduledTask) {
    `$LogFile = "C:\InstallApps.log"
    `$StartTime = Get-Date
    function Write-Log { param([string]`$Message); `$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; "`$ts - `$Message" | Out-File -FilePath `$LogFile -Append -Encoding UTF8; Write-Host `$Message }
    Write-Log "============================================"
    Write-Log "INSTALLATION AUTOMATIQUE DES APPLICATIONS"
    Write-Log "Xpolaris OS - $appCount applications selectionnees"
    Write-Log "============================================"
    try { `$Task = Get-ScheduledTask -TaskName "XpolarisInstallApps" -ErrorAction SilentlyContinue; if (`$Task) { Unregister-ScheduledTask -TaskName "XpolarisInstallApps" -Confirm:`$false -ErrorAction Stop; Write-Log "[OK] Tache planifiee supprimee" } } catch { Write-Log "[AVERTISSEMENT] `$_" }
    Write-Log "[ATTENTE] 60 secondes pour demarrage complet..."
    Start-Sleep -Seconds 60
    `$MaxWait = 900; `$Wait = 0; `$WingetOK = `$false
    while (-not `$WingetOK -and `$Wait -lt `$MaxWait) {
        try { `$v = winget --version 2>&1; if (`$LASTEXITCODE -eq 0 -and `$v -match "v[\d\.]+") { `$WingetOK = `$true; Write-Log "[OK] winget disponible : `$v" } else { Start-Sleep 20; `$Wait += 20 } } catch { Start-Sleep 20; `$Wait += 20 }
    }
    `$OK = 0; `$KO = 0
    if (-not `$WingetOK) {
        Write-Log "[INFO] Basculement FALLBACK (telechargement direct)..."
        `$FallbackApps = @(
$fallbackBlock
        )
        `$DL = "`$env:TEMP\XpolarisApps"; if (-not (Test-Path `$DL)) { New-Item -ItemType Directory -Path `$DL -Force | Out-Null }
        foreach (`$App in `$FallbackApps) {
            Write-Log "[FALLBACK] `$(`$App.Name)..."
            try { `$Out = Join-Path `$DL `$App.FileName; `$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri `$App.Url -OutFile `$Out -UseBasicParsing -TimeoutSec 300 -ErrorAction Stop; `$P = Start-Process -FilePath `$Out -ArgumentList `$App.Args -Wait -PassThru -NoNewWindow -ErrorAction Stop; if (`$P.ExitCode -eq 0 -or `$P.ExitCode -eq 3010) { Write-Log "  [OK] `$(`$App.Name) installe"; `$OK++ } else { Write-Log "  [ERREUR] Code: `$(`$P.ExitCode)"; `$KO++ }; Remove-Item `$Out -Force -ErrorAction SilentlyContinue } catch { Write-Log "  [ERREUR] `$_"; `$KO++ }
            Start-Sleep 3
        }
    } else {
        Start-Sleep 30
        `$Apps = @(
$appsBlock
        )
        Write-Log "[INFO] Installation de `$(`$Apps.Count) applications..."
        foreach (`$App in `$Apps) {
            Write-Log "[`$(`$App.Icon)] `$(`$App.Name)..."
            try { `$R = winget install --id `$App.Id --silent --accept-package-agreements --accept-source-agreements 2>&1; if (`$LASTEXITCODE -eq 0) { Write-Log "    [OK] `$(`$App.Name) installe"; `$OK++ } else { Write-Log "    [ERREUR] Code: `$LASTEXITCODE"; `$KO++ } } catch { Write-Log "    [ERREUR] `$_"; `$KO++ }
            Start-Sleep 5
        }
    }
    `$Duration = ((Get-Date) - `$StartTime).TotalMinutes
    Write-Log "============================================"
    Write-Log "TERMINE - Succes: `$OK | Echecs: `$KO | Duree: `$([math]::Round(`$Duration,2)) min"
    Write-Log "============================================"
    try { Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show("Installation terminee : `$OK apps installees (`$KO echecs)", "Xpolaris Apps", 0, 64) | Out-Null } catch { `$null = `$_ }
    exit 0
}
Write-Host "Xpolaris Apps Manager - Lancez avec -AutoMode pour installer automatiquement"
"@
                if (-not (Test-Path $oemScriptsDir)) { New-Item -ItemType Directory -Path $oemScriptsDir -Force | Out-Null }
                $appsManagerContent | Set-Content "$oemScriptsDir\Xpolaris-Apps-Manager.ps1" -Force -Encoding UTF8
                Copy-Item "$oemScriptsDir\Xpolaris-Apps-Manager.ps1" "$customISODir\sources\Xpolaris-Apps-Manager.ps1" -Force
                # Copier aussi sur le bureau Admin
                $adminDesktop = "$customISODir\sources\`$OEM`$\`$`$\Users\Administrateur\Desktop"
                if (-not (Test-Path $adminDesktop)) { New-Item -ItemType Directory -Path $adminDesktop -Force | Out-Null }
                Copy-Item "$oemScriptsDir\Xpolaris-Apps-Manager.ps1" "$adminDesktop\Xpolaris-Apps-Manager.ps1" -Force
                Write-Log "  Xpolaris-Apps-Manager.ps1 genere ($appCount apps : $(if($chkInstall7Zip.IsChecked){'7-Zip '})$(if($chkInstallNotepadPP.IsChecked){'Notepad++ '})$(if($chkInstallChrome.IsChecked){'Chrome '})$(if($chkInstallCCleaner.IsChecked){'CCleaner '})$(if($chkInstallVLC.IsChecked){'VLC '})$(if($chkInstallTeamViewer.IsChecked){'TeamViewer'}))" "Success"
            } else {
                Write-Log "  Aucune application selectionnee pour l'installation" "Warning"
            }
            if (Test-Path "$scriptDir\Xpolaris-Apps-Manager.cmd") {
                Copy-Item "$scriptDir\Xpolaris-Apps-Manager.cmd" "$oemScriptsDir\Xpolaris-Apps-Manager.cmd" -Force
                Write-Log "  Xpolaris-Apps-Manager.cmd copie" "Info"
            }
        }
        
        Update-Progress 74 "Fichiers Xpolaris copies"
        & $refreshUI 200
        
        # ETAPE 5c : Creation SetupComplete.cmd
        if ($chkSetupComplete.IsChecked) {
            Write-Log "Creation du script SetupComplete.cmd..." "Info"
            Update-Progress 75 "SetupComplete.cmd..."
            & $refreshUI 100
            
            $setupLines = @()
            $setupLines += '@echo off'
            $setupLines += 'REM ============================================================'
            $setupLines += 'REM Xpolaris OS - Configuration Post-Installation'
            $setupLines += 'REM Log complet: C:\SetupComplete.log'
            $setupLines += 'REM ============================================================'
            $setupLines += ''
            $setupLines += 'set LOGFILE=C:\SetupComplete.log'
            $setupLines += 'echo ============================================ > %LOGFILE%'
            $setupLines += 'echo Xpolaris OS - Configuration Post-Installation >> %LOGFILE%'
            $setupLines += 'echo Date: %date% %time% >> %LOGFILE%'
            $setupLines += 'echo ============================================ >> %LOGFILE%'
            $setupLines += ''
            
            $stepNum = 1
            $totalSteps = 0
            if ($chkWallpaper.IsChecked) { $totalSteps++ }
            if ($chkOEMBranding.IsChecked) { $totalSteps++ }
            if ($chkActivateAdmin.IsChecked) { $totalSteps++ }
            if ($chkRemoveBloatPost.IsChecked) { $totalSteps++ }
            if ($chkAppsManager.IsChecked) { $totalSteps += 2 }
            if ($chkWallpaper.IsChecked -and (Test-Path "$scriptDir\ApplyWallpaper.ps1")) { $totalSteps++ }
            
            if ($chkWallpaper.IsChecked) {
                $setupLines += "echo [$stepNum/$totalSteps] Configuration fond d'ecran Xpolaris... >> %LOGFILE%"
                $setupLines += 'if exist "%~dp0XpolarisWallpaper.bmp" ('
                $setupLines += '    copy /Y "%~dp0XpolarisWallpaper.bmp" "C:\Windows\Web\Wallpaper\XpolarisWallpaper.bmp" >> %LOGFILE% 2>&1'
                $setupLines += '    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v Wallpaper /t REG_SZ /d "C:\Windows\Web\Wallpaper\XpolarisWallpaper.bmp" /f >> %LOGFILE% 2>&1'
                $setupLines += '    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v WallpaperStyle /t REG_SZ /d "10" /f >> %LOGFILE% 2>&1'
                $setupLines += '    echo [OK] Fond ecran configure >> %LOGFILE%'
                $setupLines += ') else ('
                $setupLines += '    echo [ERREUR] XpolarisWallpaper.bmp introuvable >> %LOGFILE%'
                $setupLines += ')'
                $setupLines += ''
                $stepNum++
            }
            
            if ($chkOEMBranding.IsChecked) {
                $setupLines += "echo [$stepNum/$totalSteps] Configuration OEM Xpolaris... >> %LOGFILE%"
                $setupLines += 'reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Manufacturer /t REG_SZ /d "Xpolaris" /f >> %LOGFILE% 2>&1'
                $setupLines += 'reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Model /t REG_SZ /d "Xpolaris OS - Edition Personnalisee" /f >> %LOGFILE% 2>&1'
                $setupLines += 'reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportHours /t REG_SZ /d "24/7 - Xpolaris Support" /f >> %LOGFILE% 2>&1'
                $setupLines += 'reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportPhone /t REG_SZ /d "+33 X-POLARIS" /f >> %LOGFILE% 2>&1'
                $setupLines += 'reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportURL /t REG_SZ /d "https://xpolaris.local" /f >> %LOGFILE% 2>&1'
                $setupLines += 'echo [OK] OEM Info configuree >> %LOGFILE%'
                $setupLines += ''
                $stepNum++
            }
            
            if ($chkActivateAdmin.IsChecked) {
                $setupLines += "echo [$stepNum/$totalSteps] Activation compte Administrateur... >> %LOGFILE%"
                $setupLines += 'net user Administrateur /active:yes >> %LOGFILE% 2>&1'
                $setupLines += 'echo [OK] Compte Administrateur active >> %LOGFILE%'
                $setupLines += ''
                $stepNum++
            }
            
            if ($chkRemoveBloatPost.IsChecked) {
                $setupLines += "echo [$stepNum/$totalSteps] Suppression bloatware post-install... >> %LOGFILE%"
                $setupLines += 'if exist "%~dp0RemoveBloatware.ps1" ('
                $setupLines += '    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0RemoveBloatware.ps1" >> C:\RemoveBloatware.log 2>&1'
                $setupLines += '    echo [OK] Bloatware supprime >> %LOGFILE%'
                $setupLines += ') else ('
                $setupLines += '    echo [ERREUR] RemoveBloatware.ps1 introuvable >> %LOGFILE%'
                $setupLines += ')'
                $setupLines += ''
                $stepNum++
            }
            
            if ($chkAppsManager.IsChecked) {
                $setupLines += "echo [$stepNum/$totalSteps] Creation tache XpolarisInstallApps... >> %LOGFILE%"
                $setupLines += 'if exist "%~dp0Xpolaris-Apps-Manager.ps1" ('
                $setupLines += '    schtasks /Create /TN "XpolarisInstallApps" /TR "powershell.exe -ExecutionPolicy Bypass -NoProfile -File \"%~dp0Xpolaris-Apps-Manager.ps1\" -AutoMode" /SC ONLOGON /DELAY 0001:00 /RL HIGHEST /RU "Administrateur" /F >> %LOGFILE% 2>&1'
                $setupLines += '    echo [OK] Tache XpolarisInstallApps creee >> %LOGFILE%'
                $setupLines += ') else ('
                $setupLines += '    echo [ERREUR] Xpolaris-Apps-Manager.ps1 introuvable >> %LOGFILE%'
                $setupLines += ')'
                $setupLines += ''
                $stepNum++
            }
            
            if ($chkWallpaper.IsChecked -and (Test-Path "$scriptDir\ApplyWallpaper.ps1")) {
                $setupLines += "echo [$stepNum/$totalSteps] Creation tache ApplyWallpaper... >> %LOGFILE%"
                $setupLines += 'if exist "%~dp0ApplyWallpaper.ps1" ('
                $setupLines += '    schtasks /Create /TN "XpolarisApplyWallpaper" /TR "powershell.exe -ExecutionPolicy Bypass -NoProfile -File \"%~dp0ApplyWallpaper.ps1\"" /SC ONLOGON /DELAY 0000:30 /RL HIGHEST /RU "Administrateur" /F >> %LOGFILE% 2>&1'
                $setupLines += '    echo [OK] Tache ApplyWallpaper creee >> %LOGFILE%'
                $setupLines += ') else ('
                $setupLines += '    echo [ERREUR] ApplyWallpaper.ps1 introuvable >> %LOGFILE%'
                $setupLines += ')'
                $setupLines += ''
                $stepNum++
            }
            
            $setupLines += 'echo ============================================ >> %LOGFILE%'
            $setupLines += 'echo Configuration terminee >> %LOGFILE%'
            $setupLines += 'echo ============================================ >> %LOGFILE%'
            $setupLines += 'type %LOGFILE%'
            $setupLines += 'timeout /t 5'
            
            if (-not (Test-Path $oemScriptsDir)) {
                New-Item -ItemType Directory -Path $oemScriptsDir -Force | Out-Null
            }
            $setupLines -join "`r`n" | Set-Content "$oemScriptsDir\SetupComplete.cmd" -Force -Encoding ASCII
            Write-Log "  SetupComplete.cmd cree ($totalSteps etapes)" "Success"
        }
        
        Update-Progress 76 "Fichiers post-install prets"
        & $refreshUI 300
        
        # ETAPE 6 : Demontage
        Write-Log "Nettoyage de l'image et demontage..." "Info"
        Update-Progress 77 "Nettoyage composants..."
        & $refreshUI 100
        
        if ($chkCleanup.IsChecked) {
            & dism /Image:"$mountDir" /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1 | Out-Null
            Write-Log "  Nettoyage composants effectue" "Info"
        }
        
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
        } catch { $null = $_ }
        
        try {
            $mountedImages = Get-WindowsImage -Mounted -ErrorAction SilentlyContinue
            foreach ($img in $mountedImages) {
                if ($img.Path -like "*CustomizeWork*") {
                    Dismount-WindowsImage -Path $img.Path -Discard -ErrorAction SilentlyContinue | Out-Null
                }
            }
        } catch { $null = $_ }
        
        try {
            if ($mountDir -and (Test-Path $mountDir)) {
                & dism /Unmount-Wim /MountDir:"$mountDir" /Discard 2>&1 | Out-Null
            }
        } catch { $null = $_ }
        
        try {
            if ($Global:SelectedISOPath -and (Test-Path $Global:SelectedISOPath)) {
                Dismount-DiskImage -ImagePath $Global:SelectedISOPath -ErrorAction SilentlyContinue | Out-Null
            }
        } catch { $null = $_ }
    }
    finally {
        $btnStartComplete.IsEnabled = $true
        $btnStop.IsEnabled = $false
    }
}

function Switch-Theme {
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
$btnLoadEditions.Add_Click({ Import-Editions })
$btnExtractEdition.Add_Click({ Export-SelectedEdition })
$btnBrowseFolder.Add_Click({ Select-OutputFolder })
$btnStartComplete.Add_Click({ Start-CompleteProcess })
$btnCleanup.Add_Click({ Start-Cleanup })
$btnTheme.Add_Click({ Switch-Theme })
$btnClearLogs.Add_Click({ if ($txtLogs) { $txtLogs.Clear() } })
$btnAbout.Add_Click({
    [System.Windows.MessageBox]::Show(
        "Xpolaris Windows Customizer Pro`nVersion 4.3.0`n`n(c) 2026 Xpolaris`n`nInterface graphique moderne pour personnaliser Windows`n`nNouveau : Suppression composants Windows, Post-Install Xpolaris, Branding OEM",
        "A propos",
        "OK",
        "Information"
    )
})

# Boutons de selection rapide
$btnSelectAll.Add_Click({
    $allCheckboxes = @(
        $chkCortana, $chkXbox, $chkOneDrive, $chkTeams, $chkSkype, $chkNews, $chkMaps,
        $chkFeedback, $chkTips, $chkSolitaire, $chkClipchamp, $chkTodos, $chkPowerAutomate,
        $chkPeople, $chkOfficeHub, $chkZuneMusic, $chkZuneVideo,
        $chkRemoveIE, $chkRemoveWMP, $chkRemovePaint3D, $chkRemoveFax, $chkRemoveHelloFace,
        $chkRemoveWordPad, $chkRemoveXboxSvc, $chkRemovePhoneLink, $chkRemoveLangPacks,
        $chkRemoveMixedReality, $chkRemoveWallet,
        $chkTelemetry, $chkDefender, $chkUpdates, $chkStartMenu, $chkTaskbar, $chkExplorer,
        $chkShowHidden, $chkSyncNotif, $chkWidgets, $chkCopilot, $chkRecall, $chkPerformance,
        $chkContentDelivery,
        $chkDiagTrack, $chkWSearch, $chkSuperFetch, $chkPrint,
        $chkOEMBranding, $chkActivateAdmin, $chkWallpaper, $chkRemoveBloatPost,
        $chkAppsManager, $chkSetupComplete, $chkAutoUnattend,
        $chkInstall7Zip, $chkInstallNotepadPP, $chkInstallChrome, $chkInstallCCleaner, $chkInstallVLC, $chkInstallTeamViewer,
        $chkCompact, $chkCleanup, $chkOptimizeWim
    )
    foreach ($cb in $allCheckboxes) { if ($cb) { $cb.IsChecked = $true } }
    Write-Log "Toutes les options cochees" "Info"
})

$btnDeselectAll.Add_Click({
    $allCheckboxes = @(
        $chkCortana, $chkXbox, $chkOneDrive, $chkTeams, $chkSkype, $chkNews, $chkMaps,
        $chkFeedback, $chkTips, $chkSolitaire, $chkClipchamp, $chkTodos, $chkPowerAutomate,
        $chkPeople, $chkOfficeHub, $chkZuneMusic, $chkZuneVideo,
        $chkRemoveIE, $chkRemoveWMP, $chkRemovePaint3D, $chkRemoveFax, $chkRemoveHelloFace,
        $chkRemoveWordPad, $chkRemoveXboxSvc, $chkRemovePhoneLink, $chkRemoveLangPacks,
        $chkRemoveMixedReality, $chkRemoveWallet,
        $chkTelemetry, $chkDefender, $chkUpdates, $chkStartMenu, $chkTaskbar, $chkExplorer,
        $chkShowHidden, $chkSyncNotif, $chkWidgets, $chkCopilot, $chkRecall, $chkPerformance,
        $chkContentDelivery,
        $chkDiagTrack, $chkWSearch, $chkSuperFetch, $chkPrint,
        $chkOEMBranding, $chkActivateAdmin, $chkWallpaper, $chkRemoveBloatPost,
        $chkAppsManager, $chkSetupComplete, $chkAutoUnattend,
        $chkInstall7Zip, $chkInstallNotepadPP, $chkInstallChrome, $chkInstallCCleaner, $chkInstallVLC, $chkInstallTeamViewer,
        $chkCompact, $chkCleanup, $chkOptimizeWim
    )
    foreach ($cb in $allCheckboxes) { if ($cb) { $cb.IsChecked = $false } }
    Write-Log "Toutes les options decochees" "Info"
})

$btnRecommended.Add_Click({
    # D'abord tout decocher
    $allCheckboxes = @(
        $chkCortana, $chkXbox, $chkOneDrive, $chkTeams, $chkSkype, $chkNews, $chkMaps,
        $chkFeedback, $chkTips, $chkSolitaire, $chkClipchamp, $chkTodos, $chkPowerAutomate,
        $chkPeople, $chkOfficeHub, $chkZuneMusic, $chkZuneVideo,
        $chkRemoveIE, $chkRemoveWMP, $chkRemovePaint3D, $chkRemoveFax, $chkRemoveHelloFace,
        $chkRemoveWordPad, $chkRemoveXboxSvc, $chkRemovePhoneLink, $chkRemoveLangPacks,
        $chkRemoveMixedReality, $chkRemoveWallet,
        $chkTelemetry, $chkDefender, $chkUpdates, $chkStartMenu, $chkTaskbar, $chkExplorer,
        $chkShowHidden, $chkSyncNotif, $chkWidgets, $chkCopilot, $chkRecall, $chkPerformance,
        $chkContentDelivery,
        $chkDiagTrack, $chkWSearch, $chkSuperFetch, $chkPrint,
        $chkOEMBranding, $chkActivateAdmin, $chkWallpaper, $chkRemoveBloatPost,
        $chkAppsManager, $chkSetupComplete, $chkAutoUnattend,
        $chkInstall7Zip, $chkInstallNotepadPP, $chkInstallChrome, $chkInstallCCleaner, $chkInstallVLC, $chkInstallTeamViewer,
        $chkCompact, $chkCleanup, $chkOptimizeWim
    )
    foreach ($cb in $allCheckboxes) { if ($cb) { $cb.IsChecked = $false } }
    # Puis cocher les recommandes
    $recommended = @(
        $chkCortana, $chkXbox, $chkOneDrive, $chkTeams, $chkSkype, $chkNews, $chkMaps,
        $chkFeedback, $chkTips, $chkSolitaire, $chkClipchamp, $chkTodos, $chkPowerAutomate,
        $chkPeople, $chkOfficeHub, $chkZuneMusic, $chkZuneVideo,
        $chkRemoveIE, $chkRemoveWMP, $chkRemovePaint3D, $chkRemoveFax,
        $chkRemoveWordPad, $chkRemoveXboxSvc, $chkRemovePhoneLink,
        $chkRemoveMixedReality, $chkRemoveWallet,
        $chkTelemetry, $chkStartMenu, $chkTaskbar, $chkExplorer, $chkShowHidden,
        $chkSyncNotif, $chkWidgets, $chkCopilot, $chkRecall, $chkPerformance, $chkContentDelivery,
        $chkDiagTrack,
        $chkOEMBranding, $chkActivateAdmin, $chkWallpaper, $chkRemoveBloatPost,
        $chkAppsManager, $chkSetupComplete, $chkAutoUnattend,
        $chkInstall7Zip, $chkInstallNotepadPP, $chkInstallChrome, $chkInstallCCleaner, $chkInstallVLC,
        $chkCleanup, $chkOptimizeWim
    )
    foreach ($cb in $recommended) { if ($cb) { $cb.IsChecked = $true } }
    Write-Log "Configuration recommandee appliquee" "Success"
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
Write-Log "Version 4.3.0 - Interface Complete" "Info"
Write-Log "========================================" "Info"
Write-Log "1. Selectionnez un fichier ISO Windows 11" "Info"
Write-Log "2. Chargez et selectionnez une edition" "Info"
Write-Log "3. Configurez les options dans l'onglet Personnalisation" "Info"
Write-Log "4. Lancez le processus complet" "Info"
Write-Log "========================================" "Info"

# Afficher la fenetre
$window.ShowDialog() | Out-Null
