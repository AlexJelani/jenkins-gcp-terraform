output "jenkins_instance_external_ip" {
  value       = google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip
  description = "The external IP of the Jenkins instance"
}

output "jenkins_service_account_email" {
  value       = google_service_account.jenkins.email
  description = "The email of the service account"
}
