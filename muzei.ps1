$response = Invoke-RestMethod "https://muzei.co/featured" -Method GET

Invoke-RestMethod $response.imageUri -Method GET -OutFile featured.jpg

$setwallpapersrc = @"
using System.Runtime.InteropServices;
public class wallpaper
{
public const int SetDesktopWallpaper = 20;
public const int UpdateIniFile = 0x01;
public const int SendWinIniChange = 0x02;
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
public static void SetWallpaper ( string path )
{
SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
}
}
"@

Add-Type -TypeDefinition $setwallpapersrc

$localPath = Get-Location

[wallpaper]::SetWallpaper( (Join-Path $localPath "featured.jpg") ) 

$Shell = New-Object -ComObject "WScript.Shell"
$Button = $Shell.Popup($response.title + ", by " + $response.byline, 0, "Today's artwork", 0)