module "vpc" {
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Module.git"
  name           = "${var.name}-${var.region}-vpc"
  resource_group = data.ibm_resource_group.group.id
  tags           = concat(var.tags, ["region:${var.region}"])
}

# resource "ibm_dns_permitted_network" "vpc" {
#   depends_on  = [module.vpc]
#   instance_id = var.pdns_instance
#   zone_id     = var.zone_id
#   vpc_crn     = module.vpc.crn
#   type        = "vpc"
# }

resource "ibm_tg_connection" "vpc" {
  depends_on   = [module.vpc]
  gateway      = data.ibm_tg_gateway.all_mzr.id
  network_type = "vpc"
  name         = "${var.name}-${var.region}-connection"
  network_id   = module.vpc.crn
}

module "public_gateway" {
  count          = length(data.ibm_is_zones.mzr.zones)
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Public-Gateway-Module.git"
  name           = "${var.name}-${element(data.ibm_is_zones.mzr.zones, count.index)}-pubgw"
  zone           = element(data.ibm_is_zones.mzr.zones, count.index)
  vpc            = module.vpc.id
  resource_group = data.ibm_resource_group.group.id
  tags           = concat(var.tags, ["resource:ibm_is_public_gateway", "region:${var.region}", "zone:${element(data.ibm_is_zones.mzr.zones, count.index)}"])
}

module "subnet" {
  depends_on     = [module.public_gateway]
  count          = length(data.ibm_is_zones.mzr.zones)
  source         = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Subnet-Module.git"
  name           = "${var.name}-${element(data.ibm_is_zones.mzr.zones, count.index)}-subnet"
  resource_group = data.ibm_resource_group.group.id
  network_acl    = module.vpc.default_network_acl
  address_count  = "32"
  vpc            = module.vpc.id
  zone           = element(data.ibm_is_zones.mzr.zones, count.index)
  public_gateway = module.public_gateway[count.index].id
}

module "instance" {
  count             = length(data.ibm_is_zones.mzr.zones)
  source            = "git::https://github.com/cloud-design-dev/IBM-Cloud-VPC-Instance-Module.git"
  vpc_id            = module.vpc.id
  subnet_id         = module.subnet[count.index].id
  ssh_keys          = [data.ibm_is_ssh_key.hyperion_regional_ssh_key.id, data.ibm_is_ssh_key.tycho_regional_ssh_key.id]
  resource_group    = data.ibm_resource_group.group.id
  name              = "${var.name}-${element(data.ibm_is_zones.mzr.zones, count.index)}-instance"
  zone              = data.ibm_is_zones.mzr.zones[count.index]
  security_group_id = module.vpc.default_security_group
  tags              = concat(var.tags, ["zone:${element(data.ibm_is_zones.mzr.zones, count.index)}"])
  user_data         = file("${path.module}/install.yml")
  profile_name      = "bx2-4x16"
}

resource "ibm_dns_resource_record" "instance" {
  count       = length(data.ibm_is_zones.mzr.zones)
  instance_id = var.pdns_instance
  zone_id     = var.zone_id
  type        = "A"
  name        = "${var.name}-${element(data.ibm_is_zones.mzr.zones, count.index)}-instance"
  rdata       = element(module.instance[*].instance.primary_network_interface[0].primary_ipv4_address, count.index)
  ttl         = 3600
}

# module "ansible" {
#   source    = "./ansible"
#   workspace = terraform.workspace
#   instances = module.instance[*].instance
# }
