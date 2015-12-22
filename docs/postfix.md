#Postfix

[Postfix](http://www.postfix.org/) mail server is installed to enable PHP mail and SMTP mail functionality within the VM. There is a local mail catcher configured to catch any outbound mail and keep it from leaving the VM. This allows for testing of contact forms, site notifications, and other mail related features.

##Sending Mail
Setup your webform or other contact for that you are trying to test and send a mail. The mail should get caught by the mail catcher settings and not be sent to the actual address being sent to.

##Accessing Mail
To access the mail that you sent for testing you can run the following command at the command prompt:

    mail

This will open the mailbox for the vagrant user and you will see all outbound mail that was caught by the mail catcher. You should see the following output if you have tested a single email message.

    "/var/mail/vagrant": 1 message 1 new
    >N   1 root@localhost     Tue Dec 22 12:14  15/428   Testing Postfix on localhost
    ?

At the ?, you should enter the number of the email you are trying to view. You will notice it has an N at the beginning of the line, which means it is Not Read. After reading a message it will be cleaned up and removed from the mailbox.

After viewing the email by selecting the number you want to view, you can type `quit` to exit the mailbox and get back to your regular command prompt.

##Manually Testing Postfix
Sometimes you may need to test Postfix outside of your website or web application to ensure it is working properly. Use the following steps to send a manual email through Postfix.

1. Login to the VM and su to root.

    vagrant ssh
    sudo su

2. Ensure Postfix is installed and running.

    postfix status

3. Telnet into the Postfix mail server.

    telnet localhost 25

4. Enter each of the following lines individually, pressing enter after each line.

    - Replace YOUR_EMAIL with your email ID.
    - Replace SERVERNAME with the server you are testing from.
    - Replace YOURNAME with your name.

    mail from: root@localhost
    rcpt to: YOUR_EMAIL@zivtech.com
    data
    Subject: Testing Postfix on SERVERNAME.
    Hi,
    This is a test of the Postfix mail server on SERVERNAME.
    regards,
    YOURNAME
    .

You should now see a new email in your vagrant user's mailbox when typing `mail`.

_*Note:*_ The final `.` is what finishes the mail, so don't forget it!