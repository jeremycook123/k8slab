echo installing grafana...
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

sed -i "s/PROMETHEUS_PUBLIC_IP/$K8S_CLUSTER_PUBLICIP/g" /home/project/code/grafana/values.yml
helm install grafana --namespace monitoring --values /home/project/code/grafana/values.yml grafana/grafana --version 6.1.14

echo waiting for grafana deployment to complete...
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

#reset default admin password to: grafana
kubectl get secret --namespace monitoring grafana -o json | jq '.data["admin-password"]="Z3JhZmFuYQ=="' | kubectl apply -f -
kubectl rollout restart deployment grafana -n monitoring

echo exposing admin ui...
kubectl expose deployment grafana --type=NodePort --name=grafana-main --port=30300 --target-port=3000 -n monitoring
kubectl patch service grafana-main -n monitoring -p '{"spec":{"ports":[{"nodePort": 30300, "port": 30300, "protocol": "TCP", "targetPort": 3000}]}}'

echo grafana install finished!