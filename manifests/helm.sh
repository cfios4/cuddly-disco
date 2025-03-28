helm install longhorn nginx-ingress cert-manager fleet kubevip

helm repo add longhorn https://charts.longhorn.io
k create namespace longhorn-system
k label ns/longhorn-system pod-security.kubernetes.io/enforce=privileged
helm install longhorn longhorn/longhorn --namespace longhorn-system

helm repo add nginx https://helm.nginx.com/stable
helm install nginx-ingress nginx/nginx-ingress --create-namespace

helm repo add jetstack https://charts.jetstack.io --force-update
helm install cert-manager --namespace cert-manager --version v1.17.1 jetstack/cert-manager

helm repo add fleet https://rancher.github.io/fleet-helm-charts/
helm -n cattle-fleet-system install --create-namespace --wait fleet-crd fleet/fleet-crd
helm -n cattle-fleet-system install --create-namespace --wait fleet fleet/fleet

helm repo update