---
layout: default
title: HTB Cyber Apocalypse 2021
permalink: /ctf/htb-cyber-apocalypse-2021/
---

{:.warning-header}
## These CTF write-ups contain spoilers

### Written 04/20/2021

---

## Crypto Challenge - Nintendo Base64
### Challenge notes

{:.blockquote-style}
Aliens are trying to cause great misery for the human race by using our own cryptographic technology to encryd CryptoHack so they're making several noob mistakes. Therefore they've given us a chance to recover our game N64 but don't seem to understand that encoding and ASCII art are not valid types of encryption!


The following provides us with a ZIP file download called **crypto_nintendo_base64.zip**. Judging by the challenge information, it sounds like we are going to have to use **base64** to decrypt the message contained within the ZIP. Extracting the file we get a file called **output.txt**. I've taken an image to better illustrate the content:

<img src="/assets/images/01_nintendo64_decode_ascii_text.jpg">

The first thing to do is to strip away all the whitespace and new lines to get a string we can decode. I achieved thus by running the following on the **output.txt** file:

```shell
sed 's/ //g' output.txt | tr -d '\n'
Vm0weE5GbFdWWGhTV0d4VVYwZG9XVmxyWkZOV1JteDBaVWRHYWxac1NsWldSM1JQWVd4S2RHVkljRmRpUjJoMlZrZHplRmRHVm5WaVJtUlhUVEZLZVZkV1VrZFpWMUpHVDFaV1ZtSkdXazlXYWtwdlYxWmFjbHBFVWxWTlZXdzBWa2MxVTFSc1duTlhiR2hXWWtaS1dGVXhXbUZTTVdSelYyczFWMkY2VmtwV2JURXdZakZrU0ZOc2JGWmlSa3BYV1d0YVlVMHhjRVpYYlVaVFRWWmFlVmt3VlRGV01ERkhZak5rVjJFeVRYaFdha3BIVmpGU2NtRkdXbWxoTTBKWVYxWlNSMWxXWkVkVmJGWlRZbXMxY2xWc1VsZFRiR1J5VjJ0a1YySkdjRVpWVmxKV1VGRTlQUT09
```

My initial solution of this issue was a bit of a manual task. I grabbed the string above and used **echo** to pipe it to **base64** for decoding. What I got was another **base64** string. This suggested to me, there may be multiple layers of encoding at hand:

```shell
echo "Vm0weE5GbFdWWGhTV0d4VVYwZG9XVmxyWkZOV1JteDBaVWRHYWxac1NsWldSM1JQWVd4S2RHVkljRmRpUjJoMlZrZHplRmRHVm5WaVJtUlhUVEZLZVZkV1VrZFpWMUpHVDFaV1ZtSkdXazlXYWtwdlYxWmFjbHBFVWxWTlZXdzBWa2MxVTFSc1duTlhiR2hXWWtaS1dGVXhXbUZTTVdSelYyczFWMkY2VmtwV2JURXdZakZrU0ZOc2JGWmlSa3BYV1d0YVlVMHhjRVpYYlVaVFRWWmFlVmt3VlRGV01ERkhZak5rVjJFeVRYaFdha3BIVmpGU2NtRkdXbWxoTTBKWVYxWlNSMWxXWkVkVmJGWlRZbXMxY2xWc1VsZFRiR1J5VjJ0a1YySkdjRVpWVmxKV1VGRTlQUT09" | base64 -d

Vm0xNFlWVXhSWGxUV0doWVlrZFNWRmx0ZUdGalZsSlZWR3RPYWxKdGVIcFdiR2h2VkdzeFdGVnViRmRXTTFKeVdWUkdZV1JGT1ZWVmJGWk9WakpvV1ZaclpEUlVNVWw0Vkc1U1RsWnNXbGhWYkZKWFUxWmFSMWRzV2s1V2F6VkpWbTEwYjFkSFNsbFZiRkpXWWtaYU0xcEZXbUZTTVZaeVkwVTFWMDFHYjNkV2EyTXhWakpHVjFScmFGWmlhM0JYV1ZSR1lWZEdVbFZTYms1clVsUldTbGRyV2tkV2JGcEZVVlJWUFE9PQ==
```

Since this became rather repetitive, I devised a quick Python script to do the job for me:

```python
import base64
import sys

base64_msg = "Vm0weE5GbFdWWGhTV0d4VVYwZG9XVmxyWkZOV1JteDBaVWRHYWxac1NsWldSM1JQWVd4S2RHVkljRmRpUjJoMlZrZHplRmRHVm5WaVJtUlhUVEZLZVZkV1VrZFpWMUpHVDFaV1ZtSkdXazlXYWtwdlYxWmFjbHBFVWxWTlZXdzBWa2MxVTFSc1duTlhiR2hXWWtaS1dGVXhXbUZTTVdSelYyczFWMkY2VmtwV2JURXdZakZrU0ZOc2JGWmlSa3BYV1d0YVlVMHhjRVpYYlVaVFRWWmFlVmt3VlRGV01ERkhZak5rVjJFeVRYaFdha3BIVmpGU2NtRkdXbWxoTTBKWVYxWlNSMWxXWkVkVmJGWlRZbXMxY2xWc1VsZFRiR1J5VjJ0a1YySkdjRVpWVmxKV1VGRTlQUT09%"

while True:
    base64_bytes = base64_msg.encode('ascii')
    message_bytes = base64.b64decode(base64_bytes)
    message = message_bytes.decode('ascii')
    if not message.startswith('CHTB'):
        print("Current decoded message is: " + message)
        base64_msg = message
        continue
    else:
        print("The flag is: " + message)
        sys.exit()
```

The above starts off by taking the initial **base64** encoded message. It then used the **base64 module** to decode that string. The while loop then allows us to go through each decoded message until we get to the flag, which is a result that starts with **CHTB**. Running the script looks like this:

```shell
python3 crypto_decode64.py

Current decoded message is: Vm0xNFlWVXhSWGxUV0doWVlrZFNWRmx0ZUdGalZsSlZWR3RPYWxKdGVIcFdiR2h2VkdzeFdGVnViRmRXTTFKeVdWUkdZV1JGT1ZWVmJGWk9WakpvV1ZaclpEUlVNVWw0Vkc1U1RsWnNXbGhWYkZKWFUxWmFSMWRzV2s1V2F6VkpWbTEwYjFkSFNsbFZiRkpXWWtaYU0xcEZXbUZTTVZaeVkwVTFWMDFHYjNkV2EyTXhWakpHVjFScmFGWmlhM0JYV1ZSR1lWZEdVbFZTYms1clVsUldTbGRyV2tkV2JGcEZVVlJWUFE9PQ==

Current decoded message is: Vm14YVUxRXlTWGhYYkdSVFlteGFjVlJVVGtOalJteHpWbGhvVGsxWFVubFdWM1JyWVRGYWRFOVVVbFZOVjJoWVZrZDRUMUl4VG5STlZsWlhVbFJXU1ZaR1dsWk5WazVJVm10b1dHSllVbFJWYkZaM1pFWmFSMVZyY0U1V01Gb3dWa2MxVjJGV1RraFZia3BXWVRGYVdGUlVSbk5rUlRWSldrWkdWbFpFUVRVPQ==

Current decoded message is: VmxaU1EySXhXbGRTYmxacVRUTkNjRmxzVlhoTk1XUnlWV3RrYTFadE9UUlVNV2hYVkd4T1IxTnRNVlZXUlRWSVZGWlZNVk5IVmtoWGJYUlRVbFZ3ZEZaR1VrcE5WMFowVkc1V2FWTkhVbkpWYTFaWFRURnNkRTVJWkZGVlZEQTU=

Current decoded message is: VlZSQ2IxWldSblZqTTNCcFlsVXhNMWRyVWtka1ZtOTRUMWhXVGxOR1NtMVVWRTVIVFZVMVNHVkhXbXRTUlVwdFZGUkpNV0Z0VG5WaVNHUnJVa1ZXTTFsdE5IZFFVVDA5

Current decoded message is: VVRCb1ZWRnVjM3BpYlUxM1drUkdkVm94T1hWTlNGSm1UVE5HTVU1SGVHWmtSRUptVFRJMWFtTnViSGRrUkVWM1ltNHdQUT09

Current decoded message is: UTBoVVFuc3pibU13WkRGdVoxOXVNSFJmTTNGMU5HeGZkREJmTTI1amNubHdkREV3Ym4wPQ==

Current decoded message is: Q0hUQnszbmMwZDFuZ19uMHRfM3F1NGxfdDBfM25jcnlwdDEwbn0=

The flag is: SEE BELOW 
```

<details>
<summary>Flag</summary>
<div><pre><code>CHTB{3nc0d1ng_n0t_3qu4l_t0_3ncrypt10n}</code></pre>
</div>
</details>

## Web Challenge - Inspector Gadget

{:.blockquote-style}
Inspector Gadget was known for having a multitude of tools available for every occasion. Can you find them all?


This challenge required a **Docker** container to be started which lead me to this page:

<img src="/assets/images/01_inspector_gadget_home_page.jpg">

The page is a fairly simple **HTML** page from what I can tell. Based on the challenge, it feels like we are trying to find clue's to the key, which has its start printed on the homepage as **CHTB{**. Looking at the source code, I immediately noticed this comment towards the bottom of the page:

```html
<!--1nsp3ction_-->
</html>
```

I suspected the **1nsp3ction_** comment was part of the key and  was guiding me to the **Inspect** window, which I triggered by right clicking on the page and hitting **Inspect**. This pops open the development console window:

<img src="/assets/images/02_inspector_gadget_console_window.jpg">

**us3full_Inf0rm4tion}** looks to be another clue, and the closed curly bracket makes me think this is the end of our key. The key still seemed to be missing something. I started to go through all the links to the files I found on the homepage to see if they would yield any further clues, after all, we were piecing the key together.

During this review, within the **/static/js/main.js** file, I found the message to our console window that we found earlier:

```html
/* c4n_r3ve4l_ */
```
Using the four different pieces I found, we can now build out our flag, suggesting that digging around and inspecting all the files lead us to the key.
<details>
<summary>Flag</summary>
<div><pre><code>CHTB{1nsp3ction_c4n_r3ve4l_us3full_Inf0rm4tion}</code></pre>
</div>
</details>
