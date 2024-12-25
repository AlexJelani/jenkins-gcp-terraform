provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.credentials_file)
}

resource "google_service_account" "jenkins" {
  account_id   = "jenkins-sa"
  display_name = "Jenkins Service Account"
  description  = "Service account for Jenkins deployment"
}

resource "google_project_iam_member" "jenkins_roles" {
  for_each = toset([
    "roles/compute.admin",
    "roles/iam.serviceAccountUser",
    "roles/config.agent"
  ])
  role    = each.key
  member  = "serviceAccount:${google_service_account.jenkins.email}"
  project = var.project_id
}

resource "google_compute_instance" "jenkins" {
  name         = "jenkins-server"
  machine_type = "e2-small"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.jenkins.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y openjdk-11-jdk
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
    sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    apt-get update
    apt-get install -y jenkins
  EOF

  tags = ["jenkins-server", "http-server", "https-server"]
}

resource "google_compute_firewall" "jenkins" {
  name    = "allow-jenkins"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins-server"]
}
