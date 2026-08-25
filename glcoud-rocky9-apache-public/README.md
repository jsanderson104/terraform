

In the main.tf file you'll need to replace a few items/values that are specific to you.

Line: 13 <YOUR PROJECT ID>

Line(s) 46-58 The bash script sets up a user account called "automation" with sudo rights and ssh pub key inserte
	Line 49: Set your automation user pw hash on creation when the VM is being created.  I used the automation user's pwhash on my dev workstation at home by doing the following:
			sudo grep automation /etc/shadow |cut -d: -f2   
                 Take that value "$6$somethingblahahalhlah" and paste it into Line 49 in between the single quotes after the -p option.

       Line 53:  Paste the contents of your local user's ssh public key on this line. If you don't already have one (usually ~/.ssh/id_rsa.pub) do the following:
                        ssh-keygen -t rsa <press enter about 4 or 4 times, to bypass setting a passwd on the key>
                 Now "cat ~/.ssh/id_rsa.pub". Copy and Paste that value into Line 53 in the echo statement.


Special Note: 
* In this TF file we're issuing a "dnf install" command in the script setup portion. This command takes longer than you would think depending on the image used and how recent it is.
* What I've experienced is for the VM to be up and running and me be logged into it. It would still be running yum in the background. You can tell be running "ps -ef |grep -i python" and/or "sudo tail -f /var/log/messages"
* Either way it takes a few minutes for the script to complete in the background but once it does complete the website should be accessible from the internet.


