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

variable "pdns_instance" {
    type        = string
  description = "Private DNS Instance ID."
  default     = ""
}

variable "zone_id" {
    type        = string
  description = "Private DNS Zone ID."
  default     = ""
}

variable "name" {
    type        = string
  description = "Name to append to resources."
  default = "lgv1"
}