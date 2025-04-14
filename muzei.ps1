#This script pulls the daily painting from the Muzei front page.
#It is a simple powershell script.
#This version is meant for new users
#The script will create a "MuzeiShell" folder in your documents, move itself there, and create a scheduled task to run itself every day at 9am.
#When it runs itself, the script calls the image, saves it with its name in a "Archive" folder, save the metadata to a db.json file, and sets the wallpaper to the image.

#creates the MuzeiShell folder in your documents, if it doesn't already exists
if (!(Test-Path $env:USERPROFILE\Documents\MuzeiShell)) {
    New-Item -ItemType Directory -Path $env:USERPROFILE\Documents\MuzeiShell
}

#moves the script to the MuzeiShell folder. Otherwise it does everything from where it is standing
if (!(Test-Path $env:USERPROFILE\Documents\MuzeiShell\muzei.ps1)) {
    Move-Item -Path $MyInvocation.MyCommand.Path -Destination $env:USERPROFILE\Documents\MuzeiShell\muzei.ps1
}

#This finds where we are
$scriptLocation = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\')

#The API call. If it fails, we abort.
try {
    $response = Invoke-RestMethod "https://muzei.co/featured" -Method GET
}
catch {
    Write-Host "Failed to fetch the image. Please check your internet connection or the API endpoint."
    exit 1
}

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

#creates the autoupdate task if it doesn't already exists. I wouldn't do this normalyy, this is meant to help new users.
if (!(Get-ScheduledTask -TaskName "Muzei")) {
    $action = New-ScheduledTaskAction -Execute "$scriptLocation\muzei.ps1"
    $trigger = New-ScheduledTaskTrigger -Daily -At '9:00 AM'
    $settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 3) -StartWhenAvailable
    Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -TaskName "Muzei" -Description "Set your Wallpaper to the new Muzei painting."
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