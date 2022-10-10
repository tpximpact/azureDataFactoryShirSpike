variable "vm-lg-shirdfspike-filesource-admin-password" {
  description = "VM Admin Password"
  type        = string
  sensitive   = true
}

variable "sftp-password" {
  description = "SFTP Password for container"
  type        = string
  sensitive   = true
}