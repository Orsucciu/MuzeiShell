$scriptLocation = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\')

#The API call
$response = Invoke-RestMethod "https://muzei.co/featured" -Method GET

#creates the archive folder if it doesn't already exists
if (!(Test-Path $scriptLocation\Archive)) {
    New-Item -ItemType Directory -Path $scriptLocation\Archive
}

#create the file name db.json if it doesn't already exists
#the created file is empty
if (!(Test-Path $scriptLocation\db.json)) {
    $init = "{}"
    $init > $scriptLocation\db.json
}

#The image fetched, that we save as featured.jpg. The file is saved inside the script folder
Invoke-RestMethod $response.imageUri -Method GET -OutFile $scriptLocation\featured.jpg
#we prepare the correct filename
$artworkName = $response.title
$author = $response.byline
$fullName = ($artworkName + ", by " + $author + ".jpg")
$fullName = $fullName.Split([IO.Path]::GetInvalidFileNameChars()) -join ''
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

#Now we write to the db.json file
#we read the file
$read = Get-Content $scriptLocation\db.json -Raw | ConvertFrom-Json
#we add the new artwork to the db
#but sometimes, the script fails, and tries to insert null. Because we use the date as an id, we can't run the script twice in the same day.
#so instead, running it a second time will just update the artwork of the day.

#test if the date is already in the db
if ($read | Get-Member -Name (Get-Date -Format "dd.MM.yyyy") -MemberType NoteProperty) {
    #if it is, we update the artwork, by deleting the member and adding it again
    $read.PSObject.Properties.Remove((Get-Date -Format "dd.MM.yyyy"))
    $read | Add-Member -NotePropertyName (Get-Date -Format "dd.MM.yyyy") -NotePropertyValue @{
        "title" = $artworkName
        "author" = $author
        "attributions" = $response.attribution
        "imageUri" = $response.imageUri
        "detailsUri" = $response.detailsUri
    }

} else {
    $read | Add-Member -NotePropertyName (Get-Date -Format "dd.MM.yyyy") -NotePropertyValue @{
        "title" = $artworkName
        "author" = $author
        "attributions" = $response.attribution
        "imageUri" = $response.imageUri
        "detailsUri" = $response.detailsUri
    }
}


#we write the new db to the file
$read | ConvertTo-Json | Set-Content $scriptLocation\db.json