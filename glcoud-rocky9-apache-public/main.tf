terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

# 1. Configure the Google Cloud Provider
# Replace the project and region with your specific GCP details
provider "google" {
  project = "<YOUR-PROJECT-ID>"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# 2. Create a Custom VPC Network for isolation
resource "google_compute_network" "vpc_network" {
  name                    = "rocky-web-network"
  auto_create_subnetworks = true
}

# 3. Create a Firewall Rule to allow inbound traffic that we wwant
# This rule targets any instances with the network tag "base-server"
resource "google_compute_firewall" "allow_web_traffic" {
  name    = "allow-base-traffic"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22" , "9090"]
  }

  allow {
    protocol = "udp"
    ports    = ["80", "443", "22" , "9090"]
  }

  source_ranges = ["0.0.0.0/0"] # Allows traffic from anywhere on the internet
  target_tags   = ["base-server"]
}

# 4. Define the Bash Startup Script
# This runs as the root user automatically on the very first boot
locals {
  startup_script = <<-EOF
    #!/bin/bash
    useradd automation -g 10 -G wheel -s /bin/bash -c "automation account" -p '<ENTRY OF PWHASH FROM /etc/shadow HERE>'
    echo 'automation  ALL=(ALL)  NOPASSWD:ALL '   > /etc/sudoers.d/automation
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd
    mkdir /home/automation/.ssh 
    echo '<PASTE CONTENTS OF YOUR ~/.ssh/id_rsa.pub FILE HERE>
    chown -Rf automation /home/automation ; chmod 700 /home/automation/.ssh; chmod 600 /home/automation/.ssh/authorized_leys
    dnf install -y httpd freeipa-client php-common
    systemctl enable --now httpd && firewall-cmd --add-service={http,https,freeipa-ldap,ssh} && firewall-cmd --runtime-to-permanent
    echo "Justin's Terraform Web Server project" > /var/www/html/index.html && chown apache:apache /var/www/html/index.html && chmod 640 /var/www/html/index.html && restorecon -RFv /var/www/html
  EOF
}

# 5. Provision 2 Rocky Linux 9 e2-micro Virtual Machines
resource "google_compute_instance" "my_vms" {
  count        = 1
  name         = "rocky9-base-vm-${count.index + 1}"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  # Apply the network tag matching the firewall rule above
  tags = ["base-server"]

  boot_disk {
    initialize_params {
      # Leverages the official Rocky Linux 9 GCP optimized image family
      image = "rocky-linux-cloud/rocky-linux-9-optimized-gcp"
      size  = 20 # Minimum standard size for modern cloud distributions
      type  = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    
    # Including the access_config block assigns a public ephemeral IP address
    # Required so you can reach the web server over the internet
    access_config {}
  }

  # Injects the startup script via instance metadata
  metadata_startup_script = local.startup_script


}


output public_ip {
    value = google_compute_instance.my_vms[0].network_interface[0].access_config[0].nat_ip
}
