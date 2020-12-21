echo installing prometheus...
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install prometheus --namespace monitoring --values /home/project/code/prometheus/values.yml prometheus-community/prometheus --version 13.0.0

echo waiting for prometheus deployment to complete...
kubectl wait --for=condition=available --timeout=300s deployment/prometheus-alertmanager -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/prometheus-kube-state-metrics -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/prometheus-pushgateway -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/prometheus-server -n monitoring

echo patching node exporter...
kubectl patch daemonset prometheus-node-exporter -n monitoring -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape": "true"}}}}}'

echo exposing admin ui...
kubectl expose deployment prometheus-server --type=NodePort --name=prometheus-main --port=30900 --target-port=9090 -n monitoring
kubectl patch service prometheus-main -n monitoring -p '{"spec":{"ports":[{"nodePort": 30900, "port": 30900, "protocol": "TCP", "targetPort": 9090}]}}'

echo prometheus install finished!