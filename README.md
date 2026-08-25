
Welcome to my Terraform Learning Project on GitHub. 
As usual, anything you use from my repositories is at your discretion and I'm not liable. 
All of this is for learning purposes only.



################# Preparing your Linux box to issue commands to google cloud ################
1. To install Terraform CLI, just extract the zip file to /usr/local and set the PATH variable.
       a) unzip -d /usr/local/terraform terraform_*.zip
       b) export PATH=$PATH:/usr/local/terraform/bin

2. Also need to install GOOGLE CLOUD CLI -aka- "gcloud"
       a) Download it -->  curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
       b) extract it to /usr/local --> sudo tar -C /usr/local -xzvf google-cloud-cli-linux-x86_64.tar.gz
       c) set your PATH (again) variable --> export PATH=$PATH:/usr/local/google-cloud-*/

*Paths of directories created/extracted are not exact... I can't do everything for you. Well, I could actually but c'mon.



############### GOOGLE CLOUD Credentials #############

1. Login to https://console.cloud.google.com 
       a) Make note of your "Project ID" at the top of the screen. There should be a "copy icon" next to it. You're gonna wanna save that somewhere in a file for reference later.
       b) There should be a "hamburger icon" on the top-left corner of the page. Click there to Navigate to the "IAM and ADMIN" option. There is a sub-option that says "Service Accounts". Click it.
       c) Click the "Create Service Account" button. Make a service account - I can't explain the details on this just yet.
       d) Once the Service account is created, the browser should automatically attempt to download a JSON file that contains your Google Cloud credentials(the entire file IS the credential).

2. Save that JSON downloaded file to your Linux box somewhere under your dev environment (creds.json or whatever) but NOT in a git repo that could accidentally get pushed up. To be safe echo the filename into a .gitignore file in the repo top-level clone directory.

3. To start using the Google Cloud credential, set the environment variable like this:  export GOOGLE_CREDENTIALS=./creds.json
       a) Of course to set it persistently, paste that command into your ~/.bashrc file. It workes until that token expires...



================= Using Terraform basicss ===========

Terraform uses the HCL markup language to interpret the instructions.
The file extension nomenclature is something.tf
"Projects" should not co-mingle directories just for good practice and easy housekeeping
So make a terraform-webserver "project" directory and a "terraform-dbserver" project directory if that makes sense. Don't put code for multiple unrelated things in the same directory.
Following these naming rules will make it easier to manage when using a revision-control system.

Examples:

# Initialize the Google Cloud "provider" framework.
# All providers whether it be google,azure,aws,oracle all have their own "providers".
# Providers basically just middleware that terraform uses to translate it's HCL language to API calls for the specific provider you choose.
terraform init


======= Sample Terraform HCL file =============
# ** This snippet will get your started and should serve as a base template to creating your HCL(*.tf) files for deploying.

terraform { 
  required_providers {
    google = {  # Define Google as our expected API that we're going to be interacting with.
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }


# 1. Configure the Google Cloud Provider
# Replace the project and region with your specific project id and resource locations
provider "google" { # Determine where to allocate the resources we need.
  project = "<YOUR-GOOGLE-CLOUD-PROJECTID>"
  region  = "us-central1" # Where to build our resources.
  zone    = "us-central1-a" 
}

###################################################
