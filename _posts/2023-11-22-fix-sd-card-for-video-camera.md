---
title: Fixing SD Card For A Video Camera
layout: default
description: Fixing video camera not recording as expected due to zero byte INDEX.DAT file on the SD card
---

Written: 11/22/2023

Earlier today my son mentioned that his video camera was not working as expected. When selecting video record mode, an error prevented video recording or playback: `THIS CARD CANNOT RECORD IN VIDEO MODE.`

Researching the error for the video camera, which is a Panasonic HC-V180 I came up with various suggestions indicating that the issue could be caused by insufficient space on the card, incorrect card type being added and similar issues causing the problem.

Some of the pages I read through:

* [Fixya.com - Camera shows this card cannot record in video mode. How do i fix it?](https://www.fixya.com/support/t12495268-camera_shows_card_cannot_record_in_video)
* [Manualslib.com - Panasonic SDR-S26 Operating Instructions Manual](https://www.manualslib.com/manual/652659/Panasonic-Sdr-S26.html?page=86)
* [Justanswer.com - I have a new Pan. SDR-H85 camcorder. I use SDHC 32gb memory…](https://www.justanswer.com/video-camera-repair/65fgk-new-pan-sdr-h85-camcorder-use-sdhc-32gb-memory.html)

_Note_: While the Manuals Lib link is not for the exact camera model, the error is identical as to what the cam corder was showing.

In a lot of cases the suggestion was to reformat the card. What was odd about this issue is that the camera worked as expected the previous day and even now while the video recording feature was not available, photos could still be taken and taking the SD card and viewing the content via the computer, the videos were present and working.

I decided to poke around and see if we could figure out the issue without needing to format the card. Checking the SD card's top level file structure listed the following:

{% highlight shell %}
drwxrwxrwx  1 me  me  256K Jul 18 09:41 .Spotlight-V100
drwxrwxrwx  1 me  me  256K Jul 18 12:31 .Trashes
drwxrwxrwx  1 me  me  256K Nov 22 16:27 .fseventsd
drwxrwxrwx  1 me  me  256K Jul 18 10:40 DCIM
drwxrwxrwx  1 me  me  256K Jul 18 10:40 PRIVATE
drwxrwxrwx  1 me  me  256K Jul 18 09:43 System Volume Information
{% endhighlight %}

There was nothing exciting in `PRIVATE`, `System Volume Information` and the other hihidden  directories. Most of the data was also showing that there have been no recent updates to the files.

While reviewing the `DCIM` directory, what I did notice was that there were two identical files called `INDEX.DAT`:

{% highlight shell %}
-rwxrwxrwx  1  me  me  7.0K Nov 22 16:32 BACKUP.HST
-rwxrwxrwx  1  me  me  1.0M Nov 22 16:43 BACKUP.TMP
-rwxrwxrwx  1  me  me    2B Jul 18 10:40 BACKUPAM.HST
-rwxrwxrwx  1  me  me    0B Nov 21 12:53 INDEX.DAT
-rwxrwxrwx  1  me  me  102B Jun 16 16:43 INDEX.DAT
{% endhighlight %}

A few observations:

* Two files with the same name are in the same directory
* One of the duplicate files is zero bytes
* The zero byte file was created around the date and time when the camera last worked as expected

So this is definitely something to go on. [FileInfo.com](https://fileinfo.com/extension/dat) has the following to say about the filetype:

{:.blockquote-style}
A DAT file is a generic data file created by a specific application. It may contain data in binary or text format. DAT files are typically accessed only by the application that created them.

To troubleshoot the issue I initially tried to see if the file name was identical but in all honesty I did not run it through something like the following command which would have given a better idea in case there was an explanation such as a character that was not visible to `ls`:

{% highlight shell %}
ls | LC_ALL=C sed -n l
{% endhighlight %}

Checking the zero byte file with a few tools available on OSX noted that indeed we were looking at an empty file with no additional data to glean from it:

{% highlight shell %}
file INDEX.DAT
INDEX.DAT: empty
{% endhighlight %}

Checking the other `INDEX.DAT` file in the directory that we can see is `102B` in size:

{% highlight shell %}
file INDEX.DAT
INDEX2.DAT: data
{% endhighlight %}

We can take a look at the file using the tool [xxd](https://linux.die.net/man/1/xxd):

{% highlight shell %}
 xxd INDEX.DAT
00000000: 4d49 4458 0000 0066 10ff ffff 0001 0010  MIDX...f........
00000010: 0353 4453 4432 3536 8544 6180 8901 7200  .SDSD256.Da...r.
00000020: 0002 0042 0000 0000 0000 0000 0000 0000  ...B............
00000030: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000040: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000050: 0000 0000 0000 3135 3559 4150 4848 5331  ......155YAPHHS1
00000060: 3535 3030 3032                           550002
{% endhighlight %}

I moved the broken file from the SD card to a local directory on my computer and also copied the file that I suspected was the _working_ file in this case. After doing this, the card started to work as expected in the video camera again.

To test my theory that the issue was being caused by the zero byte `INDEX.DAT` file, I deleted the working one and replaced it with the broken file. Testing in the video camera confirmed this to be the case.

In summary, the issue was identified to be a zero byte `INDEX.DAT` file on the SD card's `DCIM` directory. To fix it we can either:

* Delete the file and on the next time the card is re-inserted into the video camera, a new one will be written
* In my case there was a broken and a working version. Removing the broken version fixed the problem
