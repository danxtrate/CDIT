variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}

#defines the CIDR blocks for the entire VCN and for the subnets
variable "vcn_cidr" {
    default = "10.0.0.0/16"
}
variable "LBA_subnet_cidr" {
    default = "10.0.0.0/24"
}

variable "LBB_subnet_cidr" {
    default = "10.0.1.0/24"
}

variable "WBA_subnet_cidr" {
    default = "10.0.2.0/24"
}

variable "WBB_subnet_cidr" {
    default = "10.0.3.0/24"
}

variable "DBA_subnet_cidr" {
    default = "10.0.4.0/24"
}
#define the shape of the instance to be deployed
variable "InstanceShape" {
    default = "VM.Standard2.1"
}

#define the OCID of the image to be deployed, see https://docs.us-phoenix-1.oraclecloud.com/images/ --- add just for the region used
variable "InstanceImageOCID" {
    default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaitzn6tdyjer7jl34h2ujz74jwy5nkbukbh55ekp6oyzwrtfa4zma"
}


variable "user-data" {
  default = <<EOF
#!/bin/bash -x
echo '################### webserver userdata begins #####################'
touch ~opc/userdata.`date +%s`.start
# echo '########## yum update all ###############'
# yum update -y
echo '########## basic webserver ##############'
yum install -y httpd
systemctl enable  httpd.service
systemctl start  httpd.service
echo '<html><head></head><body><pre><code>' > /var/www/html/index.html
hostname >> /var/www/html/index.html
echo '' >> /var/www/html/index.html
cat /etc/os-release >> /var/www/html/index.html
echo '</code></pre></body></html>' >> /var/www/html/index.html
firewall-offline-cmd --add-service=http
systemctl enable  firewalld
systemctl restart  firewalld
touch ~opc/userdata.`date +%s`.finish
echo '################### webserver userdata ends #######################'
EOF
}