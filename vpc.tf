variable "ssh_key" {
  type = string
}

variable "resource_group" {
  type = string
}

provider "ibm" {
  generation = 2
  region = "eu-gb"
}

locals {
  BASENAME = "lastmile-adt" 
  ZONE     = "eu-gb-1"
}

resource ibm_is_vpc "vpc" {
  name = "${local.BASENAME}-vpc"
}

resource ibm_is_security_group "sg1" {
  name = "${local.BASENAME}-sg1"
  vpc  = ibm_is_vpc.vpc.id
}

# allow all incoming network traffic on port 22
resource "ibm_is_security_group_rule" "ingress_ssh_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = "0.0.0.0/0"                       

  tcp {
    port_min = 22
    port_max = 22
  }
}

resource ibm_is_subnet "subnet1" {
  name = "${local.BASENAME}-subnet1"
  vpc  = ibm_is_vpc.vpc.id
  zone = local.ZONE
  total_ipv4_address_count = 256
}

data ibm_is_image "debian" {
  # -1- name = "ubuntu-18.04-amd64"
  name = "ibm-debian-9-9-minimal-amd64-2"
}

data ibm_is_ssh_key "ssh_key_id" {
  name = var.ssh_key
}

data ibm_resource_group "group" {
  name = var.resource_group
}

resource ibm_is_instance "vm1" {
  name    = "${local.BASENAME}-vm1"
  resource_group = data.ibm_resource_group.group.id
  vpc     = ibm_is_vpc.vpc.id
  zone    = local.ZONE
  keys    = [data.ibm_is_ssh_key.ssh_key_id.id]
  image   = data.ibm_is_image.debian.id
  profile = "bx2-2x8"

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet1.id
    security_groups = [ibm_is_security_group.sg1.id]
  }
}

resource ibm_is_instance "vm2" {
  name    = "${local.BASENAME}-vm2"
  resource_group = data.ibm_resource_group.group.id
  vpc     = ibm_is_vpc.vpc.id
  zone    = local.ZONE
  keys    = [data.ibm_is_ssh_key.ssh_key_id.id]
  image   = data.ibm_is_image.debian.id
  profile = "bx2-2x8"

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet1.id
    security_groups = [ibm_is_security_group.sg1.id]
  }
}

resource ibm_is_instance "vm3" {
  name    = "${local.BASENAME}-vm3"
  resource_group = data.ibm_resource_group.group.id
  vpc     = ibm_is_vpc.vpc.id
  zone    = local.ZONE
  keys    = [data.ibm_is_ssh_key.ssh_key_id.id]
  image   = data.ibm_is_image.debian.id
  profile = "bx2-2x8"

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet1.id
    security_groups = [ibm_is_security_group.sg1.id]
  }
}


resource ibm_is_floating_ip "fip1" {
  name   = "${local.BASENAME}-fip1"
  target = ibm_is_instance.vm1.primary_network_interface.0.id
}

resource ibm_is_floating_ip "fip2" {
  name   = "${local.BASENAME}-fip2"
  target = ibm_is_instance.vm2.primary_network_interface.0.id
}


output sshcommand1 {
  value = "ssh root@ibm_is_floating_ip.fip1.address"
}

output sshcommand2 {
  value = "ssh root@ibm_is_floating_ip.fip2.address"
}

output vpc_id {
 value = ibm_is_vpc.vpc.id
}
