echo installing k8s dashboard...
helm repo add k8s-dashboard https://kubernetes.github.io/dashboard
helm repo update
helm install k8s-dashboard --namespace monitoring k8s-dashboard/kubernetes-dashboard --set=protocolHttp=true --set=serviceAccount.create=true --set=serviceAccount.name=k8sdash-serviceaccount --version 3.0.2

echo apply k8s dashboard permissions...
#very permissive, do not use in production
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=monitoring:k8sdash-serviceaccount

echo exposing dashboard ui...
kubectl expose deployment k8s-dashboard-kubernetes-dashboard --type=NodePort --name=k8s-dashboard --port=30990 --target-port=9090 -n monitoring
kubectl patch service k8s-dashboard -n monitoring -p '{"spec":{"ports":[{"nodePort": 30990, "port": 30990, "protocol": "TCP", "targetPort": 9090}]}}'

echo k8s dashboard install finished!