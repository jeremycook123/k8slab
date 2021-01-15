echo installing spinnaker...
hal -v
hal config version edit --version 1.21.4
hal config security api edit --override-base-url http://gate.cloudacademy.$SPINNAKER_CLUSTER_PUBLICIP.nip.io:30100
hal config security ui edit --override-base-url http://spinnaker.cloudacademy.$SPINNAKER_CLUSTER_PUBLICIP.nip.io:30200
hal config provider kubernetes enable
hal config provider kubernetes account add spinnaker --context spinnaker
hal config provider kubernetes account add staging --context staging
hal config provider kubernetes account add prod --context prod
hal config deploy edit --type distributed --account-name spinnaker 
hal config artifact github enable 
hal config artifact github account add cloudacademy
hal config storage s3 edit \
 --access-key-id $SPINNAKER_S3_ACCESSKEY \
 --secret-access-key $SPINNAKER_S3_SECRETACCESSKEY \
 --bucket $SPINNAKER_S3_BUCKET \
 --region us-west-2
 hal config storage edit --type s3 
 kubectl config use-context spinnaker
 kubectl config get-contexts
 hal deploy apply

echo exposing spinnaker...
kubectl expose deployment spin-gate --name=spin-gate-api -n spinnaker --type=NodePort --port=30100 --target-port=8084
kubectl patch service spin-gate-api -n spinnaker -p '{"spec":{"ports":[{"nodePort": 30100, "port": 30100, "protocol": "TCP", "targetPort": 8084}]}}'
kubectl expose deployment spin-deck --name=spin-deck-ui -n spinnaker --type=NodePort --port=30200 --target-port=9000
kubectl patch service spin-deck-ui -n spinnaker -p '{"spec":{"ports":[{"nodePort": 30200, "port": 30200, "protocol": "TCP", "targetPort": 9000}]}}'

echo finished