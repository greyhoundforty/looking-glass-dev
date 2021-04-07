
data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_is_zones" "mzr" {
  region = var.region
}

data "ibm_is_ssh_key" "hyperion_regional_ssh_key" {
  name = "hyperion-${var.region}"
}

data "ibm_is_ssh_key" "tycho_regional_ssh_key" {
  name = "tycho-${var.region}"
}

data "ibm_tg_gateway" "all_mzr" {
  name = "all-mzr"
}

