---
layout: default
title: flAWS Cloud 1
meta: flAWS Cloud  CTF highlighting common mistakes and gotchas using AWS
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

```
dig A +noall flaws.cloud +answer
flaws.cloud.		5	IN	A	52.218.220.18
```

Checking for CNAME records did not reveal anything interesting, but the IP address appears to belong to an S3 bucket. Trying to directly visit this IP address in the browser redirects us to the <a href="https://aws.amazon.com/s3/">Amazon S3</a> site.
Based on the hint about buckets, we we can start exploring the idea that the site may be hosted as a static site within an AWS Bucket. If this is the case, reviewing the <a href="https://docs.aws.amazon.com/AmazonS3/latest/userguide/website-hosting-custom-domain-walkthrough.html#root-domain-walkthrough-create-buckets">Configuring a static website using a custom domain</a> documentation comes to hand. **Step 2** indicates the following: **These bucket names must match your domain name exactly**.
Searching around for the domain structure of static sites hosted on AWS S3 buckets, I found <a href="https://www.cdputnam.com/blog/s3-custom-domain/">this article on hosting a site on an S3 bucket</a> which lead me to thefollowing syntax:

```
AWS auto-populated: example.com.s3.amazonaws.com
Direct, Region spcific S3 URL to use: example.com.s3-website-us-east-1.amazonaws.com
```

We already know that when hosting a static site, the bucket name will need to match the custom domain. Using the above formula, therefore we can try out the domain <a href="http://flaws.cloud.s3.amazonaws.com">flaws.cloud.s3.amazonaws.com</a>. In my experience, Amazon bucket information is displayed as an XML file. Going to the above site, that is exactly that we end up with. Scrolling down, we find the following:

```xml
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
```

Towards the bottom, we can see a file called **secret-dd02c7c.html**. When we visit the page we are greeted with the following message:

```
_____  _       ____  __    __  _____
|     || |     /    ||  |__|  |/ ___/
|   __|| |    |  o  ||  |  |  (   \_
|  |_  | |___ |     ||  |  |  |\__  |
|   _] |     ||  _  ||  `  '  |/  \ |
|  |   |     ||  |  | \      / \    |
|__|   |_____||__|__|  \_/\_/   \___|

Congrats! You found the secret file!
Level 2 is at http://level2-c8b217a33fcf1f839f6f1f73a00a9ae7.flaws.cloud
```

Following the above link leads us to Level 2. The above link provides some additional information on how to avoid exposing AWS bucket based sites in a similar manner.

## Level 2
### Challenge Notes

{:.blockquote-style}
The next level is fairly similar, with a slight twist. You're going to need your own AWS account for this. You just need the free tier.

This challenge starts off much like the **first challenge**, however on this occasion we are making use of an AWS account. I suspected this may be to use <a href="https://aws.amazon.com/cli/">AWS CLI</a>. This is not something I used a lot, so it was back to digging around documentation.
I started to look at the <a href="https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds">Amazon configuration basics documentation for AWS CLI</a> for an idea. This is where it became apparent why I needed an AWS account in the first place.
According to the document using **aws configure**, we can configure our **AWS Access Key ID** and **AWS Secret Access Key** along with a region. This can then be used to connect to buckets.
After setting up my own configuration based on the documentation and using my account I tried the syntax suggested:

```shell
aws s3 --profile myprofile ls s3://level2-c8b217a33fcf1f839f6f1f73a00a9ae7.flaws.cloud
2017-02-26 20:02:15      80751 everyone.png
2017-03-02 21:47:17       1433 hint1.html
2017-02-26 20:04:39       1035 hint2.html
2017-02-26 20:02:14       2786 index.html
2017-02-26 20:02:14         26 robots.txt
2017-02-26 20:02:15       1051 secret-e4443fc.html
```

We can see the **secret-e4443fc.html** towards the bottom. Visiting that page we get the following message:

```
_____  _       ____  __    __  _____
|     || |     /    ||  |__|  |/ ___/
|   __|| |    |  o  ||  |  |  (   \_
|  |_  | |___ |     ||  |  |  |\__  |
|   _] |     ||  _  ||  `  '  |/  \ |
|  |   |     ||  |  | \      / \    |
|__|   |_____||__|__|  \_/\_/   \___|

Congrats! You found the secret file!
Level 3 is at http://level3-9afd3927f195e10225021a578e6f78df.flaws.cloud
```

Much like the previous level, navigating to the third level gives us insight as to what caused us the ability to list out the content.
