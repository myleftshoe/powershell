function Global:prompt {
     $oc = $host.ui.RawUI.ForegroundColor
     $host.UI.RawUI.ForegroundColor = "DarkCyan"
     $Host.UI.Write([System.Net.Dns]::GetHostName() + ": ")
     $host.UI.RawUI.ForegroundColor = "Yellow"
     $Host.UI.Write(([string]$pwd).Replace("C:\Users\user", "~"))
     $message = "This text is right aligned"
     $startposx = $Host.UI.RawUI.windowsize.width - $message.length
     $startposy = $Host.UI.RawUI.CursorPosition.Y
     $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $startposx,$startposy
     $host.UI.RawUI.ForegroundColor = "DarkGreen"
     $Host.UI.Write($message)
     $host.UI.RawUI.ForegroundColor = $oc
     $Host.UI.Write($([char]0x2192))
     return " "
 }