resource "oci_core_instance" "WebServerA" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "WebServerA"
  shape               = "${var.InstanceShape}"
  subnet_id           = "${oci_core_subnet.WBA.id}"
  hostname_label      = "WebServerA"

#use this to install httpd role
#  metadata {
#    user_data = "${base64encode(var.user-data)}"
#  }

  source_details {
    source_type = "image"
    source_id   = "${var.InstanceImageOCID}"
  }
}