
output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "service_public_ip" {
  value       = kubernetes_service.app_svc.status[0].load_balancer[0].ingress[0].ip
  description = "Public IP of the LoadBalancer service (puede tardar unos minutos en aparecer)."
}
