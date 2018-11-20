# output the private and public IPs of the instances
output "InstancePrivateIPs" {
  value = ["${oci_core_instance.WebServerA.*.private_ip}"]
  value = ["${oci_core_instance.WebServerB.*.private_ip}"]
}

output "InstancePublicIPs" {
  value = ["${oci_core_instance.WebServerA.*.public_ip}"]
  value = ["${oci_core_instance.WebServerB.*.public_ip}"]
}

# output the public IP of the load balancer
output "lb_public_ip" {
  value = ["${oci_load_balancer.lb1.ip_addresses}"]
}