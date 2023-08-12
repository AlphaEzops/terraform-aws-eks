output "ingress_nginx_hostname" {
  description = "The hostname of the ingress-nginx service"
  value = data.kubernetes_service_v1.ingress_nginx_service.status.0.load_balancer.0.ingress.0.hostname
}

output "ingress_nginx_ip" {
  description = "The IP address of the ingress-nginx service"
  value = data.kubernetes_service_v1.ingress_nginx_service.status.0.load_balancer.0.ingress.0.ip
}

output "ingress_nginx_zone_id" {
  description = "The zone ID of the ingress-nginx service"
  value = data.aws_elb_hosted_zone_id.ingress_nginx_zone_id.id
}
