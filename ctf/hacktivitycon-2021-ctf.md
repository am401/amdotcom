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

wombo pulled the text up in VSCode and started to zoom out until the text became clearer:

<img src="/assets/images/bass64_challenge_text.png">

As the challenge name indicated, I suspected this was encoded in **base64** therefore I attempted to decode it:

```shell
echo "IGZsYWd7MzVhNWQxM2RhNmEyYWZhMGM2MmJmY2JkZDYzMDFhMGF9" | base64 -d
 flag{35a5d13da6a2afa0c62bfcbdd6301a0a}
```

With that we got our flag!

## Swaggy
### Challenge notes

{:.blockquote-style}
This API documentation has all the swag

With this challenge we were presented with a simple front end API documentation:

<img src="/assets/images/swaggy_challenge_front_end.png">

