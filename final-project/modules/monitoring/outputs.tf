output "grafana_admin_password" {
  description = "The admin password for Grafana"
  value       = "Use kubectl get secret -n monitoring prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
}

output "prometheus_url" {
  description = "The URL for Prometheus"
  value       = "http://prometheus-stack-kube-prom-prometheus.monitoring.svc.cluster.local:9090"
}
