---
layout: default
title: 0xfat
---

{:.warning-header}
## These CTF write-ups contain spoilers

### Written: 2021/10/10

---

[0xf.at](http://0xf.at) is a hackit style password-riddle site. The [GitHub Project](https://github.com/HaschekSolutions/0xf.at) has setup instructions to configure it locally using Docker. The framework also allows a user to create their own levels and add them to the overall project.

The challenges primarily take up a similar format, some challenge notes along with an input box to provide the answer in. At the time of writing all the solitions have been in the page's source code.

## Level 1
### Challenge notes

{:.blockquote-style}
Easy beginnings

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 1</h1>
    <div>Easy beginnings</div>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">
        function checkPW()
        {
            var el = document.getElementById('pw');
            if(el.value=="tooeasy")
                document.location.href="?pw="+el.value;
            else alert("Wrong password!");
        }
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

The above is pretty straight forward. The `if` statement checks whether the value of the `el` variable is a certain string and verifies whether it's the password.

<details>
<summary>Flag</summary>
<div>
<pre><code>tooeasy</code></pre>
</div>
</details>

## Level 2
### Challenge notes

{:.blockquote-style}
Not that hard either..

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 2</h1>
                <div>Not that hard either..</div>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">
        function checkPW()
        {
            var pw = "%39%32%31%61%61";
            var el = document.getElementById('pw');
            if(el.value==unescape(pw))
                window.location.href="?pw="+el.value;
            else alert("Wrong password");
        }
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

In this scenario it looks like we are given the password as a variable (`pw`) and checking the `if` statement, we are having to unescape it. A method to do this would be to fire up the browser's Console window and go through the steps:

{% highlight javascript %}
var pw = "%39%32%31%61%61";
unescape(pw)
{% endhighlight %}

<details>
<summary>Flag</summary>
<div>
<pre><code>921aa</code></pre>
</div>
</details>

## Level 3
### Challenge notes

{:.blockquote-style}
How about: No sourcecode?

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 3</h1>

    <!--
Source code disabled

....4000 lines later....

Did I fool you?
-->
<div>How about: No sourcecode?</div>
<input id="pw" type="password" />
<br/><input type="button" value="OK" onClick="checkPW()"/>
<script type="text/javascript">
    function checkPW()
    {
        var el = document.getElementById("pw");
        if(el.value==unescape("r%20i%20g%20h%20t%20")+""+"p"+"w"+""+"6943ad11f")
            window.location.href="?pw="+el.value;
        else alert("Wrong password");
    }
</script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

This challenge tried to trick us as if there was no source code. Instead we had to scroll down around 4400 lines to the bottom. The challenge itself is similar as before. We are this time putting together the password from a few different elements:

{% highlight javascript %}
if(el.value==unescape("r%20i%20g%20h%20t%20")+""+"p"+"w"+""+"6943ad11f")
{% endhighlight %}

We first want to figure out the value of the `unescape("r%20i%20g%20h%20t%20")` element:

After that there was a bit of a trick by adding two empty strings to the pattern: `+""+` adds nothing and can in a sense be ingored.
<details>
<summary>Flag</summary>
<div>
<pre><code>r i g h t pw6943ad11f</code></pre>
</div>
</details>

## Level 4
### Challenge notes

{:.blockquote-style}
What does .length mean?

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 4</h1>
    <div>What does .length mean?</div>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
     <script type="text/javascript">
        function checkPW()
        {
            var el = document.getElementById("pw");
            var pwinfo = "3523 f1b04eb e2ddc14 f50 fe 1135d3a55400c503ae  1120c 51404eba50a5b45ea3d";
            if(el.value==pwinfo.length)
                window.location.href="?pw="+el.value;
            else alert("Wrong password");
        }
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

Analyzing the code, we are presented with a variable, `var pwinfo = "3523 f1b04eb e2ddc14 f50 fe 1135d3a55400c503ae  1120c 51404eba50a5b45ea3d";`. Looking at `if` statement that checks the input validity, the password matches the length of this variable. We can again solve this using the Browser Console.

<details>
<summary>Flag</summary>
<div>
<pre><code>var pwinfo = "3523 f1b04eb e2ddc14 f50 fe 1135d3a55400c503ae  1120c 51404eba50a5b45ea3d";
pwinfo.length;
73</code></pre>
</div>
</details>

## Level 5
### Challenge notes

{:.blockquote-style}
Have you heard of ASCII?

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 5</h1>
    <div>Have you heard of ASCII?</div>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">
        function checkPW()
        {
            var el = document.getElementById("pw");
            if(el.value==(atoi("o")+73))
                window.location.href="?pw="+el.value;
            else alert("Falsches Passwort");
        }

        // converts a character to its ASCII number
        function atoi(a)
        {
           return a.charCodeAt();
        }
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

We can see that the input value is compared to the following: `(atoi("o")+73)`. Further along in the code, we see a function called `atoi` which takes the argument `a`. The function returns the `charCodeAt()` JavaScript method, which in a nutshell gives us the unicode value of a string. Additional information and context can be found on the [w3schools.com](https://www.w3schools.com/jsref/jsref_charcodeat.asp) website.

We can rely on our trusty Console to solve this challenge again, pasting in the `atoi()` function and calling it to find the value of the letter **o**.

<details>
<summary>Flag</summary>
<div>
<pre><code>atoi("o") + 73;
184</code></pre>
</div>
</details>

## Level 6
### Challenge notes

<img src="/assets/images/0xfat_level_6.png">

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 6</h1>
    <div><span id="nice" style="color:#cc3333">Nice</span> <span id="though" style="color:#99ff33">colors</span> <span id="colors" style="color:#33ffff">though</span></div>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">
        function checkPW()
        {
            var el = document.getElementById("pw");
            if(el.value==rgb2hex(document.getElementById("though").style.color))
                window.location.href="?pw="+escape(el.value);
            else window.location.href="?pw="+escape(el.value);
        }

        function rgb2hex(rgb) {
            rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
            function hex(x) {
                return ("0" + parseInt(x).toString(16)).slice(-2);
            }
            return "#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
        }

    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

For this challenge I included a screenshot of the challenge notes as this will be key. The source code has two functions in there. `checkPW()`, which will verify our input is correct as well as `rgb2hex()` which takes the argument `rgb`. This function essentially returns a hex string generated from the RGB colors of our input.

Looking at the `checkPW()` function, the `if` statement is gathering the word from the page "though", which on our screenshot is green (`rgb(153, 255, 51)`). The check also gathers the color style that the word is using. Our trusty Console helps us out to get the answer.

<details>
<summary>Flag</summary>
<div>
<pre><code>rgb2hex(document.getElementById("though").style.color)
"#99ff33"</code></pre>
</div>
</details>

## Level 7
### Challenge notes

{:.blockquote-style}
Jerry fcked up, he forgot the password for this level but he mumbled something about a robots.txt file and something about a hint..

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 7</h1>
    <p>Jerry f*cked up, he forgot the password for this level but he mumbled something about a robots.txt file and something about a hint..</p>
<input id="pw" type="password" />
<br/><input type="button" value="OK" onClick="checkPW()"/>
<script type="text/javascript">
    function checkPW()
    {
        var el = document.getElementById("pw");
        window.location.href="?pw="+el.value;
    }
</script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

The challenge notes indicate that we should be looking in a file called `robots.txt` for a hint to our next level. Checking the file, we find the following information:

{% highlight html %}
User-agent: *
Allow: /

Disallow: /play/solutionforlevel7 #don't allow google to find the solution for level 7
{% endhighlight %}

The key here is the `Disallow` line, whereby it asks crawlers not to index the page which is the solution to our current level. Visiting the page yields us the flag.

<details>
<summary>Flag</summary>
<div>
<pre><code>I don't know how you found it but you've found it! The password for level 7 is:
jerryIsDaBoss5c</code></pre>
</div>
</details>

## Level 8
### Challenge notes

{:.blockquote-style}
Nice, someone already entered the password but they made a small mistake.
The FIRST occurring 0 (zero) should actually be a small "o". Can you fix it?

{% highlight html%}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 8</h1>
    <p>Nice, someone already entered the password but they made a small mistake.<br/>The FIRST occurring 0 (zero) should actually be a small "o". Can you fix it?</p>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">
        function checkPW()
        {
            var el = document.getElementById("pw");
            window.location.href="?pw="+el.value;
        }
    </script>
<script type="text/javascript">
var _0x6a7e=["\x2F\x62\x61\x63\x6B\x65\x6E\x64\x2E\x70\x68\x70\x3F\x61\x3D\x73\x26\x6C\x3D\x38","\x70\x61\x72\x73\x65","\x72\x65\x73\x75\x6C\x74","\x76\x61\x6C","\x23\x70\x77","\x67\x65\x74","\x72\x65\x61\x64\x79"];$(document)[_0x6a7e[6]](function(){$[_0x6a7e[5]](_0x6a7e[0],function(_0xa388x1){var _0xa388x2=JSON[_0x6a7e[1]](_0xa388x1);$(_0x6a7e[4])[_0x6a7e[3]](_0xa388x2[_0x6a7e[2]]);})});
</script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

On this challenge, the password is already given to us within the input box, however it's obfuscated. Selecting to **Inspect** the page, we can modify the behavior of the input box from type `password` to `text`:

<img src="/assets/images/0xfat_level_8.png">

The instructions tell us to grab the already existing password and convert the first occurring zero (0) to a lowercase "o".

<details>
<summary>Flag</summary>
<div>
<pre><code>635egxjz4v26ghxtzb4ouwh52pbpness</code></pre>
</div>
</details>

## Level 9
### Challenge notes

{:.blockquote-style}
Let's think this through

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 9</h1>
    <p>Let's think this through</p>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">
        function checkPW()
        {
            var foo = 5 + 6 * 7;
            var bar = foo % 8; //modulo.. look it up if you don't know what it does
            var moo = bar + 1;
            var rar = moo / 3;
            var el = document.getElementById("pw");
            if(el.value.length == moo)
                window.location.href="?pw="+el.value;
            else alert("Wrong password");
        }
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

This is a pretty straight forward challenge, however as the notes suggest we just need to think it through. The first part is solving the equations. There is a little trick in there, since we have four variables: `foo`, `bar`, `moo` and `rar`, however as we can see within the challenge password verifying `if` statement, we actually need the value of `moo`.

We can step through these easily using the console:

{% highlight javascript %}
var foo = 5 + 6 * 7;
var bar = foo % 8;
var moo = bar + 1;
moo;
8
{% endhighlight %}

We now know that the value of the `moo` variable is **8**. The verification step checks whether our input's lenght is equal to the value of the `moo` variable: ` if(el.value.length == moo)`. Since it's checking the length of the input, we can use any string that matches the length criteria.

<details>
<summary>Flag</summary>
<div>
<pre><code>password</code></pre>
</div>
</details>

## Level 10
### Challenge notes

{:.blockquote-style}
Try not to be fooled

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 10</h1>
    <p>Try not to be fooled</p>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">var CodeCode = "moo451";

        function checkPW()
        {
            "+CodeCode+" == "0xf.at_hackit";
            var el = document.getElementById("pw");
            if(el.value == ""+CodeCode+"")
                document.location.href="?pw="+el.value;
            else alert("Wrong password");
        }
        
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

This one is more of a tricky one than a complicated challenge. Within the `checkPW()` function we are given a variable `"+CodeCode+"` and further along in the code, when checking if the input value matches our password, we can see the comparison: `if(el.value == ""+CodeCode+"")`.

One might be fooled into thinking we are trying to compare to the value of the `"+CodeCode+"` variable, however if we take a look at the behavior, we are actually searching for the variable `CodeCode`. The `""` add an empty string and the `+` in this case works to concatenate the empty strings with the word `CodeCode`. Searching the code, outside of the `checkPW()` function we can find this variable.

<details>
<summary>Flag</summary>
<div>
<pre<code>var CodeCode = "moo451";</code></pre>
</div>
</details>

## Level 11
Challenge notes

{:.blockquote-style}
The password of this level is calculated by the following function

{% highlight php %}
function pwCheck($password)
{
    if($password==date("d.m.Y")) //GMT +1
        return true;
    else return false;
}
{% endhighlight %}

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 11</h1>
    <p>The password of this level is calculated by the following function</p>
    <pre><code class="language-php">function pwCheck($password)
{
if($password==date("d.m.Y")) //GMT +1
return true;
else return false;
}</code></pre><br/>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">

        function checkPW()
        {
            var el = document.getElementById("pw");
            document.location.href="?pw="+el.value;
        }
        
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

This one gives us a simple PHP script that checks whether the password provided is equal to `date("d.m.Y")`. Since PHP is installed by default on OSX, I was able to fire it up and run that method to get the flag.

{% highlight php %}
php -a
echo date("d.m.Y");
{% endhighlight %}

<details>
<summary>Flag</summary>
<div>
<pre><code>10.10.2021</code></pre>
</div>
</details>

## Level 12
### Challenge notes

{:.blockquote-style}
The password is the sum of all numbers from 1 to 477

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 12</h1>
    <p>The password is the sum of all numbers from 1 to 477</p>
    <br/>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">

        function checkPW()
        {
            var el = document.getElementById("pw");
            document.location.href="?pw="+el.value;
        }
        
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

For this challenge we are asked to calculate the sum of all numbers between **1** and **477**. A friend of mine and I came up with a solution each when solving this challenge.

### Solution 1
I went down the route of a loop to calculate the sum, whereby `i` is our sum and `x` is our iterator, which tracks where in the loop we are as well as adding the value of that number to `i`:

{% highlight python %}
>>> i = 0
>>> x = 1
>>> while x < 478:
...     i += x
...     x += 1
{% endhighlight %}

To get the flag, we just need to print the value of `i`.
### Solution 2
On a similar note, my friend used Python along with the mathematical formula for the [sum of the first n natural numbers](https://cseweb.ucsd.edu/groups/tatami/kumo/exs/sum/):

{% highlight python %}
{% raw %}
python -c "n=477; print((n*(n+1))/2)"
{% endraw %}
{% endhighlight %}

<details>
<summary>Flag</summary>
<div>
<pre><code>114003</code></pre>
</div>
</details>

## Level 13
### Challenge notes

{:.blockquote-style}
The password of this level is calculated by the following function

{% highlight php %}
function pwCheck($username,$password)
{
    if(!$username || !$password) return false;
    if(strlen($username)==$password)
        return true;
    else return false;
}
{% endhighlight %}

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 13</h1>
    <p>The password of this level is calculated by the following function</p>
    <pre><code class="language-php">function pwCheck($username,$password)
{
if(!$username || !$password) return false;
if(strlen($username)==$password)
return true;
else return false;
}</code></pre><br/>
    Username
    <input id="user" name="user" type="text" />
    <br/>
    Password
    <input id ="pw" name="pw" type="password" /><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">

        function checkPW()
        {
            var pw = document.getElementById("pw");
            var user = document.getElementById("user");
            document.location.href="?pw="+pw.value+"&name="+user.value;
        }
        
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

This is another challenge where it's more about being able to read the code and think logically. The PHP function we are given essentially checks that the length of the `$username` is equal to the variable `$password`. From this, we know that the function will take a username, calculate its length and check if the entered password is equal to that length.

<details>
<summary>Flag</summary>
<div>
<pre><code>Username: admin
Password: 5</code></pre>
</div>
</details>

## Level 14
### Challenge notes

{:.blockquote-style}
The following function defines the login process

{% highlight php %}
function pwCheck($guid,$password)
{
	if(!$guid || !$password) return false;
    $users = implode(file('/data/login_info.json'));
	$json = json_decode($users,true);

	foreach($json['result'] as $data)
		if($data['guid']==$guid && $data['password'] == $password && $data['account_status']=='active')
			return true;
	return false;
}
{% endhighlight %}

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 14</h1>
    <p>The following function defines the login process</p>
    
    <div></div>
    <pre><code class="language-php">function pwCheck($guid,$password)
{
if(!$guid || !$password) return false;
$users = implode(file('/data/login_info.json'));
$json = json_decode($users,true);

foreach($json['result'] as $data)
if($data['guid']==$guid &amp;&amp; $data['password'] == $password &amp;&amp; $data['account_status']=='active')
    return true;
return false;
}
</code></pre>
    GUID<br/>
    <input id="guid" type="text" />
    <br/>
    Password<br/>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">
        function checkPW()
        {
            var el = document.getElementById("guid");
            var pw = document.getElementById("pw");
            window.location.href="?pw="+pw.value+"&guid="+el.value;
        }
    </script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

For this challenge we are given another snippet of PHP. We can see from the `$users` variable, that the information is gathered from a file found at `/data/login_info.json`. The [implode()](https://www.php.net/manual/en/function.implode.php) function is a bit of a red-herring here as it's not exactly joining array elements beyond printing out the file.

From the rest of the code, we can see that it's looking for the `account_status` to be `active`. When we look at the file, only one user is active and the user data holds the necessary pieces to the flag.

<details>
<summary>Flag</summary>
<div>
<pre><code>        {
            "id": 4,
            "guid": "bc3c1364-4b24-4f60-8fe4-7628e72391ed",
            "password": "Vencom",
            "age": 40,
            "account_status": "active",
            "name": "Paige Youmans",
            "gender": "female",
            "phone": "857-579-3847",
            "email": "paige@vencom.com",
            "address": "14622, Flint, Harrison Street",
            "registered": "2007-07-15T09:55:40 -02:00"
        },

GUID: bc3c1364-4b24-4f60-8fe4-7628e72391ed
Password: Vencom</code></pre>
</div>
</details>

## Level 15
### Challenge notes

{:.blockquote-style}
You have to decode the following encrypted password.
We don't know how to decrypt it but you can play around with the algorithm that was used to encode it. Maybe you'll figure it out

{% highlight html %}
npveei
{% endhighlight %}

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 15</h1>
    <p>You have to decode the following encrypted password.<br/>We don't know how to decrypt it but you can play around with the algorithm that was used to encode it. Maybe you'll figure it out</p>

<pre><code class="">npveei
</code></pre>

<form method="GET">
    Testing input: 
    <input name="text" type="text" /> <input type="submit" name="submit" value="Test algorithm"/>
    <br/><br/>
    Decoded password:<br/>
    <input name="pw" type="text" />
    <br/><input type="submit" name="submit" value="OK"/>
</form>

<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

On this challenge we are given a string, which is meant to be encoded - `npveei`. We are then provided with two input boxes, one to provide arbitary data to encrypt using the same method `npveei` was generated with and the other to submit our password.

Testing the encryption with `abcdef` we can start to observe a behavior. The encrypted version of the string is `acegik`. From this it looks like each character is shifted by its position:

{% highlight html %}
Position 1 - a => a
Position 2 - b => c
Position 3 - c => e
Position 4 - d => g
Position 5 - e => i
Position 6 - f => k
{% endhighlight %}

We can use this knowledge to reverse engineer our encrypted string. While this can be done programmatically, I found it quicker to solve it by pulling up the [English alphabet](http://civilfastforward.com/wp-content/uploads/2011/11/1.-Letters-table.png) in a numbered chart and calculated it.

<details>
<summary>Flag</summary>
<div>
<pre><code>notbad</code></pre>
</div>
</details>

## Level 16
### Challenge notes

{:.blockquote-style}
The password of this level is calculated by the following function

{% highlight php %}
function pwCheck($password)
{
    if(base64_encode($password)=="ODNhMjNmYjU4MmUxMDU5ODhkMjI2YmVjMw==")
        return true;
    else return false;
}
{% endhighlight %}

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 16</h1>
    <p>The password of this level is calculated by the following function</p>
    <pre><code class="language-php">function pwCheck($password)
{
if(base64_encode($password)=="ODNhMjNmYjU4MmUxMDU5ODhkMjI2YmVjMw==")
return true;
else return false;
}</code></pre>
    <input id="pw" type="password" />
    <br/><input type="button" value="OK" onClick="checkPW()"/>
    <script type="text/javascript">

        function checkPW()
        {
            var el = document.getElementById("pw");
            document.location.href="?pw="+el.value;
        }
        
    </script>

<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

This was an overall very straight forward challenge. The password we enter into the input box gets Base64 encoded (`base64_encode($password)`)and is matched against a fixed value (`ODNhMjNmYjU4MmUxMDU5ODhkMjI2YmVjMw==`). To complete this challenge, we can decode this value.

<details>
<summary>Flag</summary>
<div>
<pre><code>83a23fb582e105988d226bec3</code></pre>
</div>
</details>

## Level 17
### Challenge notes

{:.blockquote-style}
Now let's play: regEx
Find out what password will make the preg_match function return 1

{% highlight php %}
function pwCheck($password)
{
    return preg_match('/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,})$/i', $password, $found);
}
{% endhighlight %}

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 17</h1>
    <p>Now let's play: regEx<br/>Find out what password will make the preg_match function return 1</p>
<pre><code class="language-php">function pwCheck($password)
{
return preg_match('/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,})$/i', $password, $found);
}</code></pre>
<input id="pw" type="password" />
<br/><input type="button" value="OK" onClick="checkPW()"/>
<script type="text/javascript">
    function checkPW()
    {
        var pw = document.getElementById("pw");
        window.location.href="?pw="+pw.value;
    }
</script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

The key here is to understand what the regex is doing. Having used regex in the past, it appears to primarily be a validation for an email address. I tested the following string to complete the level:

<details>
<summary>Flag</summary>
<div>
<pre><code>a@a.com</code></pre>
</div>
</details>

## Level 18
### Challenge notes

{:.blockquote-style}
The following password is encoded in morse code. Each character is seperated by a blank.
After 60 seconds this page will submit/refresh automatically. So.. be faster than that.

{% highlight html %}
−−... .−−−− ...−− −.. ....− −.. −.−. −... 
{% endhighlight %}

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 18</h1>
    <p>The following password is encoded in morse code. Each character is seperated by a blank.<br/>After 60 seconds this page will submit/refresh automatically. So.. be faster than that.</p>
<pre><code class="language-php">..... −.. ..−−− −.. −−−.. ....− −.. −−−−. </code></pre>
<input id="pw" type="password" />
<br/><input type="button" value="OK" onClick="checkPW()"/>
<script type="text/javascript">
    function checkPW()
    {
        var pw = document.getElementById("pw");
        window.location.href="?pw="+pw.value;
    }
    setTimeout(function(){checkPW();}, 60000);
</script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

On this challenge we are presented with a string, which appears to be morse code. I tried a variety of morsecode converters, however for whatever reason they did not work on this string. Much like **Level 15**, I opted to manually convert the values using this [International Morse Code sheet](https://www.boxentriq.com/img/morse-code/morse-code-overview.png).

I was able to manually convert the values within the provided *60 seconds*. For the above example the flag was:

<details>
<summary>Flag</summary>
<div>
<pre><code>..... => 5
-.. => D
..--- => 2
-.. => D
---.. => 8
....- => 4
-.. => D
----. => 9

Flag: 5D2D84D9</code></pre>
</div>
</details>

## Level 20
### Challenge notes

<img src="/assets/images/0xfat_level_19.png">

{% highlight html %}
<!-- :::::::::::::::::==== GAME STARTS HERE ====::::::::::::::::: -->
    <h1>Level 19</h1>
    <p>Remember them old phone pads?</p>
<div>
        <img src="/data/imgs/keypad.png" /><br/><br/>
    The following password has been encrypted by the telephone alphabet pattern. The solution for this level is the <strong>digit sum</strong> of the number code<br/><br/>
    <strong>Example:</strong><br/>
    A =&gt; <span class="blue">22</span><br/>
    B =&gt; <span class="blue">222</span><br/>
    C =&gt; <span class="blue">2222</span><br/>
    1 =&gt; <span class="blue">1</span><br/>
    2 =&gt; <span class="blue">2</span><br/>
    5 =&gt; <span class="blue">5</span><br/>
    I =&gt; <span class="blue">4444</span><br/>
    W =&gt; <span class="blue">99</span><br/>
    Z =&gt; <span class="blue">99999</span><br/><br/>
    
    <p>"HEY" =&gt; <span class="blue">444 333 9999</span> =&gt; <span class="blue">4+4+4+3+3+3+9+9+9+9</span> = <u>57</u></p>
    
    <p>You have <strong>15 seconds</strong> to submit the right solution. Each time you reload this page the password changes.</p>
</div>
<pre><code class="">f77738e4bbcb039b5b04c7c15f60cb98</code></pre>
<input id="pw" type="password" />
<br/><input type="button" value="OK" onClick="checkPW()"/>
<script type="text/javascript">
    function checkPW()
    {
        var pw = document.getElementById("pw");
        window.location.href="?pw="+pw.value;
    }
    setTimeout(function(){checkPW();}, 15000);
</script>
<!-- ::::::::::::::::::==== GAME ENDS HERE ====:::::::::::::::::: -->
{% endhighlight %}

This was a bit more challenging. We are given a keypad and instructions to convert the characters on the keypad to numbers. We are only given 15 seconds to solve this and the string given is 32 characters long, therefore we have to look at this programmatically. I used Python to build out a dictionary where I calculated the sum of each character. The script than takes the string we are given to calculate the sum of and creates a list of its characters.

We can then iteratre through the list of characters and match them against the dictionary keys to get the sum (value) of it. If the character is not in our dictionary, we can assume it's a number and we can use the number to add to the sum.

{% highlight python %}
import sys

char_sums = {'a': '4', 'b': '6', 'c': '8', 'd': '6', 'e': '9', 'f': '12', 'g': '8', 'h': '12', 'i': '16', 'j': '10', 'k': '15', 'l': '20', 'm': '12', 'n': '18', 'o': '24', 'p': '14', 'q': '21', 'r': '28', 's': '35', 't': '16', 'u': '24', 'v': '32', 'w': '18', 'x': '27', 'y': '36', 'z': '45'}

input = sys.argv[1]
char = list(input)
sum = 0
for c in char:
    if c in char_sums.keys():
        sum += int(char_sums.get(c))
    else:
        sum += int(c)
print(sum)
{% endhighlight %}

Running the above script and supplying the string provided by the challenge gets us the flag.

<details>
<summary>Flag</summary>
<div>
<pre><code>python level20.py 53bc79918220509808a10046f70c67e4
158</code></pre>
</div>
</details>
