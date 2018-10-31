data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}


#define the minimum config for the Virtual Cloud Network
resource "oci_core_virtual_network" "PROD" {
  cidr_block = "${var.vcn_cidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "PROD"
}

#define the internet gateway for the VCN
resource "oci_core_internet_gateway" "IG1" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "IG1"
    vcn_id = "${oci_core_virtual_network.PROD.id}"
}

#define the route table 
resource "oci_core_route_table" "RouteForPROD" {
    compartment_id = "${var.compartment_ocid}"
    vcn_id = "${oci_core_virtual_network.PROD.id}"
    display_name = "RouteForPROD"
    route_rules {
        cidr_block = "0.0.0.0/0"
        network_entity_id = "${oci_core_internet_gateway.IG1.id}"
    }
}


#define a security list for a WebServer Subnet.  It allows ingress for port 80 from the Load Balancer Subnets and for port 22 from the outside, modify according to necesities
#Use IANA protocol numbers to describe protocols. Options are supported only for ICMP ("1"), TCP ("6"), and UDP ("17")
resource "oci_core_security_list" "WEB_SecList" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "WEB_Seclist"
    vcn_id = "${oci_core_virtual_network.PROD.id}"
    egress_security_rules = [{
        destination = "0.0.0.0/0"
        protocol = "6"
    }]
    ingress_security_rules = [{
        tcp_options {
            "max" = 22
            "min" = 22
        }
        protocol = "6"
        source = "0.0.0.0/0"
    },
    {
        tcp_options {
            "max" = 80
            "min" = 80
        }
        protocol = "6"
        source = "10.0.0.0/23" 
    },
	{
	protocol = "6"
	source = "${var.vcn_cidr}"
    }]
}

#define a security list for a Load Balancer Subnet. It allows ingress from the internet through port 80 and egress to the WebServer Subnets through port 80
#Use IANA protocol numbers to describe protocols. Options are supported only for ICMP ("1"), TCP ("6"), and UDP ("17")
resource "oci_core_security_list" "LB_SecList" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "LB_Seclist"
    vcn_id = "${oci_core_virtual_network.PROD.id}"
    egress_security_rules = [{
        tcp_options {
            "max" = 80
            "min" = 80
        }
        protocol = "6"
        destination = "10.0.2.0/23"
    }]
    ingress_security_rules = [{
        tcp_options {
            "max" = 80
            "min" = 80
        }
        protocol = "6"
        source = "0.0.0.0/0"
    },
    	{
        protocol = "all"
        source = "${var.vcn_cidr}"
    }
    ]
}

#define a security list for Database subnets (later)
#Use IANA protocol numbers to describe protocols. Options are supported only for ICMP ("1"), TCP ("6"), and UDP ("17")

#define Web Server subnets. Select one of three availability domains by using [0, 1, 2] in the "availabity_domain" line
resource "oci_core_subnet" "WBA" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}" 
  cidr_block = "${var.WBA_subnet_cidr}"
  display_name = "WBA"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.PROD.id}"
  route_table_id = "${oci_core_route_table.RouteForPROD.id}"
  security_list_ids = ["${oci_core_security_list.WEB_SecList.id}"]
  dhcp_options_id = "${oci_core_virtual_network.PROD.default_dhcp_options_id}"
}

resource "oci_core_subnet" "WBB" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}" 
  cidr_block = "${var.WBB_subnet_cidr}"
  display_name = "WBB"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.PROD.id}"
  route_table_id = "${oci_core_route_table.RouteForPROD.id}"
  security_list_ids = ["${oci_core_security_list.WEB_SecList.id}"]
  dhcp_options_id = "${oci_core_virtual_network.PROD.default_dhcp_options_id}"
}

#define Load Balancer subnets. Select one of three availability domains by using [0, 1, 2] in the "availabity_domain" line
resource "oci_core_subnet" "LBA" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}" 
  cidr_block = "${var.LBA_subnet_cidr}"
  display_name = "LBA"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.PROD.id}"
  route_table_id = "${oci_core_route_table.RouteForPROD.id}"
  security_list_ids = ["${oci_core_security_list.LB_SecList.id}"]
  dhcp_options_id = "${oci_core_virtual_network.PROD.default_dhcp_options_id}"
}

resource "oci_core_subnet" "LBB" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}" 
  cidr_block = "${var.LBB_subnet_cidr}"
  display_name = "LBB"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.PROD.id}"
  route_table_id = "${oci_core_route_table.RouteForPROD.id}"
  security_list_ids = ["${oci_core_security_list.LB_SecList.id}"]
  dhcp_options_id = "${oci_core_virtual_network.PROD.default_dhcp_options_id}"
}

#define database subnets (later). Select one of three availability domains by using [0, 1, 2] in the "availabity_domain" line
