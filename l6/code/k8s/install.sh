echo installing k8s sample api...
kubectl apply -f /home/project/code/k8s/api.yml

echo installing k8s generator (api client) pod...
kubectl run generator --env="API_URL=http://api-service:5000" --image=cloudacademydevops/api-generator --image-pull-policy IfNotPresent

echo k8s api and generator install finished!