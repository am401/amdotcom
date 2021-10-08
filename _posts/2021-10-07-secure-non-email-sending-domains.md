---
title: Secure Non-Email Sending Domains
layout: default
description: Use SPF, DMARC and DKIM records to protect domains from email spoofing
---

Written: 2021/10/07

Not all sites and domains will be utilized to send emails, yet the possibility to use the domain to send emails is left open when the necessary DNS records are not set, which would help prevent spoofing. These records can help close the door on a malicious actor from being able to use your domain to carry out phishing and spam attacks.

The headers in question are:

* [**S**ender **P**olicy **F**ramework](https://en.wikipedia.org/wiki/Sender_Policy_Framework) - This header helps set the IP addresses or mail servers emails coming from the domain should be originating from. This in combination with the next header can prevent these emails from being accepted by receiving mail servers

* [**D**omain-based **M**essage **A**uthentication, **R**eporting and **C**onformance](https://en.wikipedia.org/wiki/DMARC) - An authentication protocol, which adds a policy telling mail servers how to handle mail that fail SPF and DKIM records

* [**D**omain**K**eys **I**dentified **M**ail](https://en.wikipedia.org/wiki/DomainKeys_Identified_Mail) - An email authentication method to help detect forged mail headers and email spoofing. The DNS record itself holds a cryptographic [public key](https://en.wikipedia.org/wiki/Public-key_cryptography) and when configured on the origin server, a key is added to the outgoing email. The receiving mail server can then use this key in combination with the DKIM record to authenticate the email

This article only covers configuring these records to prevent spoofing on non-email sending domains as opposed to drilling down on how to set up these records to work with and help protect domains, which are utilized for email delivery.

### Scenario: No records
For this example, I am going to use the domain **andrasmarton.xyz**. It currently does not have any of the above mentioned records, which we can verify with a quick `dig` query:

{% highlight shell %} 
DOMAIN=andrasmarton.xyz; echo -e "\n==Checking andrasmarton.xyz for email related DNS records=="; echo -e "SPF Record:"; dig  TXT +short andrasmarton.xyz; echo -e "\nDKIM Record:"; dig TXT +short test._domainkey.andrasmarton.xyz; echo "\nDMARC Record:"; dig TXT +short _dmarc.andrasmarton.xyz

==Checking andrasmarton.xyz for email related DNS records==
SPF Record:

DKIM Record:

DMARC Record:
{% endhighlight %}

_To note_: With DKIM records, a unique **selector** is used, which will serve as the DNS record as well. In the above example, the selector is called **test**.

To demonstrate sending an email from a third party source and spoofing **andrasmarton.xyz**, I have created a simple **PHP** script to use the `mail()` function:

{% highlight php %}
<?php
$to = 'me@example.com';
$subject = 'This is a test';
$message = 'There are no SPF, DKIM or DMARC records and this email will be delivered.';
$headers = 'From: noreply@andrasmarton.xyz' . "\r\n" .
	'Reply-To: noreply@andrasmarton.xyz' . "\r\n" .
	'X-Mailer: PHP/' . phpversion();

mail($to, $subject, $message, $headers);
?>
{% endhighlight %}

I tested this with both [ProtonMail](https://protonmail.com) and [GMail](https://mail.google.com):

**GMail** did not flag this as spam, however did flag that it was sent via a different mail server. However this may not necessarily be something thatthe recipient would either check or even realize when opening a possible phishing email.

<img src="/assets/images/scenario_one_gmail.png">

**ProtonMail** on the other hand did not even flag that there was a different mail server in the middle and no indication that this may be a malicious email.

<img src="/assets/images/scenario_one_protonmail.png">

Hitting **Reply** on both of the above providers would accurately fill out the return address of `noreply@andrasmarton.xyz`. As we can see in this scenario, a malicious actor could very easily spoof emails from your site and carry out phishing attacks.

### Scenario Two
In this scenario, we are going to create the three records, **SPF**, **DKIM** and **DMARC** on the DNS level. You will need access to the DNS records of your domain in order to accomplish this.

**SPF**
The hostname will vary between DNS provider. Some will accept `@` to signify the root domain or you will need to enter the domain itself. Since we are not spacifying any IPs or domains for our mail servers between the two values below, the emails will fail the SPF record.

```
Type: TXT
Hostname: @ or andrasmarton.xyz
Value: v=spf1 -all
```

**DKIM**
We will be using a wildcard for DKIM records to capture any record a receiving mail server may check.

```
Type: TXT
Hostname: *._domainkey
Value: v=DKIM1; p=
```

**DMARC**
A simple policy is used to check all emails (`pct=100`), and we will be rejecting all emails which fail either SPF or DKIM (`p=reject`).

```
Type: TXT
Hostname: _dmarc
Value: "v=DMARC1; p=reject; pct=100; sp=reject; adkim=s; aspf=s;"
```

Once setup, we can use the same script we did earlier to check that they are coming through on the DNS level:

{% highlight shell %}
DOMAIN=andrasmarton.xyz; echo -e "\n==Checking andrasmarton.xyz for email related DNS records=="; echo -e "SPF Record:"; dig  @8.8.8.8 TXT +short andrasmarton.xyz; echo -e "\nDKIM Record:"; dig TXT +short test._domainkey.andrasmarton.xyz; echo "\nDMARC Record:"; dig @8.8.8.8 TXT +short _dmarc.andrasmarton.xyz

==Checking andrasmarton.xyz for email related DNS records==
SPF Record:
"v=spf1 -all"

DKIM Record:
"v=DKIM1; p="

DMARC Record:
"v=DMARC1; p=reject; pct=100; sp=reject; adkim=s; aspf=s;"
{% endhighlight %}

Re-sending the test emails yield us with a slightly different result. GMail has outright blocked the email due to the DMARC policy in place and checking the mail server logs, we can confirm this:

<img src="/assets/images/scenario_two_gmail.png">

On the other hand, ProtonMail allowed the email through and delivered it, however adding a noticable banner, flagging the email as possible spam due to an authentication requirement. They provide additional information on [this page](https://protonmail.com/support/knowledge-base/email-has-failed-its-domains-authentication-requirements-warning/):

<img src="/assets/images/scenario_two_protonmail.png">

### Conclusion

As seen with ProtonMail, while a banner is added and the email is flagged as spam, it still gets through. This is because while the SPF, DKIM records and DMARC policy tell a receiving web server what to do and help authenticate the email, it is still down to the mail server to act on the information it receives.

However as seen, these steps can help either block or flag emails coming from your domain, when there should be no emails being sent out.

### References

* Protect domains that do not send email - https://www.gov.uk/guidance/protect-domains-that-dont-send-email

* Tackling Email Spoofing and Phishing - https://blog.cloudflare.com/tackling-email-spoofing/
