# tf-gcp-gke
Terraform Example for building a Multi-AZ GKE Cluster on GCP  
Pre-requisite: GCloud SDK, Kubectl & Check NTP sync status!  
Ensure GKE API is enabled via GCP console!  


# RUN Gcloud Init 
gcloud init  
gcloud config set accessibility/screen_reader true  
gcloud auth application-default login  
gcloud config get-value project  


# Deploy GKE Cluster  
Update GCP project id in the terraform.tfvars file !!!  
terraform init && terraform apply  
gcloud container clusters get-credentials node-pool-cluster-demo --region australia-southeast1  


# Deploy K8s Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml  
kubectl apply -f ./kube-dashboard/  


# Retrieve Dashboard Token
SA_NAME=admin-user  
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep ${SA_NAME} | awk '{print $1}')  


# Deploy K8s Metrics-Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml  
kubectl get deployment metrics-server -n kube-system  


# Deploy Storage Classes 
kubectl apply -f ./storage/storageclass/  


# Deploy NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml  


# Demo-App: GCP HipsterShop
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml  


# Demo-App: Guestbook (verify Storage Classes)
kubectl create ns guestbook-app  
kubectl apply -f ./demo-apps/guestbook/  


# Demo-App: Yelb
kubectl create ns yelb  
kubectl apply -f ./demo-apps/yelb/  
