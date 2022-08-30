#The API call
$response = Invoke-RestMethod "https://muzei.co/featured" -Method GET

#creates the archive folder if it doesn't already exists
if (!(Test-Path $scriptLocation\archive)) {
    New-Item -ItemType Directory -Path $scriptLocation\Archive
}

#The image fetched, that we save as featured.jpg. The file is saved inside the script folder
$scriptLocation = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\')
Invoke-RestMethod $response.imageUri -Method GET -OutFile $scriptLocation\featured.jpg
#we prepare the correct filename
$artworkName = $response.title
$author = $response.byline
$fullName = ($artworkName + ", by " + $author + ".jpg")
#we copy what we just downloaded to the archive folder.
Copy-Item $scriptLocation\featured.jpg -Destination $scriptLocation\Archive\$fullName

#changes the walllpaper. Look it up, i didn't write this
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

[wallpaper]::SetWallpaper( (Join-Path $scriptLocation "featured.jpg") ) 

#creates the little box with the image's info
$Shell = New-Object -ComObject "WScript.Shell"
$Shell.Popup($artworkName + ", by " + $author, 0, "Today's artwork", 0)