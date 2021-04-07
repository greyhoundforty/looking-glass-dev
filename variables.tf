variable "region" {
  type        = string
  description = "The region where the VPC resources will be deployed."
  default     = ""
}

variable "resource_group" {
  type        = string
  description = "Resource group where resources will be deployed."
  default     = ""
}

variable "tags" {
  default = ["owner:ryantiffany", "project:rtlg"]
}

variable "pdns_instance" {}
variable "zone_id" {}
variable "name" {
  default = "lgv1"
}