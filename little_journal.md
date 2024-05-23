Muzei Shell - The Desktop version of *Muzei*

This is a sort of little journal, log for this project.

This was actually written last year, and i only wrote this document now.

Basically, Muzei is an Android App that lets you discover art by getting your lockscreen and wallpaper replaced by a random artwork everyday. The project is hosted here (https://muzei.co/). Seemingly funded by a google employee, i do not know how it is or isn't curated.

Last year i think, i set out to create a windows version of it, by seeing the API endpoint the app was getting the artwork from, and then writing a PS script that would be called everyday and replace the background. Finding the corresponding command was easy enough (since it's some windows-specific thing, i wrote the thing in PS) but calling it reliably everyday turned out more complicated. Sometimes it won't update, even though it should. But i still consider this project as done, since it delivers what's promised.

**GOING FURTHER:**

Here are some ideas for improvements, in no particular order, along with their status and explaination if relevant.

~~1 - Save the artworks in a folder, with their name~~ Done!

2 - Upscale the artwork if it is blury

3 - Show a little museum-style card in the bottom-right corner, with a link to the wikiart entry

4 - Update the archive files' metadata WITH NO external dependencies
