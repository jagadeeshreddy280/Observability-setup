##Obeservability platform Used to Track the Logs, Metrics, Traces Of the Application.

1.cloud platform         :   AWS

2.logs                   :   Loki

3.Metrics                : Prometheus,Mimir

4.Traces                 : Tempo

5.Opentelemetry is used to connect loki,mimir,Tempo as expoter to grafana

6.Alerts                 : MS Teams,Pager Duty, Email

7.Automation       -     : Terraform

8.Storing data           : Amazon S3

------------------------------------------------------------------------------
Order for setting up the platform for monitoring

>>Need to insatll eks cluster,enable cluster-autoscalar,loadbalancer

>>Install Kubectl,helm,Terraform

1.Grafana
2.loki
3.promtail
4.tempo
5.mimir
6.cluster-autoscalar
7.prometheus_node_exporter
8.aws-load-balancer-controller
9.kube_state_metrics
------------
Grafana & Prometheus Installation:
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm search repo prometheus-community
kubectl create namespace jagadeesh
helm install stable prometheus-community/kube-prometheus-stack -n jagadeesh
o/p: 
NAME: stable
LAST DEPLOYED: Tue Aug  8 04:31:08 2023
NAMESPACE: jagadeesh
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace jagadeesh get pods -l "release=stable"

kubectl get pods -n jagadeesh
kubectl get svc -n jagadeesh

##In order to make prometheus and grafana available outside the cluster, use 
  LoadBalancer or NodePort instead of ClusterIP.
kubectl edit svc stable-kube-prometheus-sta-prometheus -n jagadeesh
kubectl edit svc stable-grafana -n jagadeesh

>>open loadbalancer url in google
checking password:
-->kubectl get secret --namespace jagadeesh stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

admin
prom-operator
type password and login u can see dashboard

-----------------------------------------------
Loki installation:
-->helm repo add grafana https://grafana.github.io/helm-charts
-->kubectl create ns loki
-->helm install loki grafana/loki-distributed -n loki
-->kubectl get all -n loki

NOTE:
create ingress for service/loki-distributed-query-frontend
replace ingress url in otel.yaml
example:
loki:
  endpoint: http://k8s-loki-loki-17c4ba30dc-1324281432.us-east-1.elb.amazonaws.com/loki/api/v1/push

Mimir installation:
-->helm repo add grafana https://grafana.github.io/helm-charts
-->kubectl create ns mimir
-->helm install mimir grafana/mimir-distributed -n mimir
NOTE:
-->add http://mimir-nginx.jagadeesh.svc:80/prometheus in otel collector

Tempo installation:
-->helm repo update
-->helm repo add grafana https://grafana.github.io/helm-charts
-->kubectl create ns tempo
-->helm install my-tempo grafana/tempo -n tempo
-->helm -n tempo install tempo grafana/tempo-distributed 

Traces we need application:
link for Reference: https://medium.com/opentelemetry/deploying-the-opentelemetry-collector-on-kubernetes-2256eca569c9
deploy app.yaml 
-->kubectl port-forward deployment/myapp 8080 -n app &
hitting the application
-->curl localhost:8080/order
kubectl port-forward deployment/myapp 8081:8080 -n tempo  &

Otel installation & integration with Loki,prometheus,mimir,tempo:

##this operator need to deploy first
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml

OTEL Deployment:
otel.yaml   rbac.yaml   service.yaml

kubectl apply -f rbac.yaml -n otel
***check otelcontribcol is deployed on service account
kubectl get sa -n otel
kubectl apply -f otel.yaml
kubectl get all -n otel

Replace loki,mimir,otel url in otel.yaml 
kubectl replace otel.yaml -n otel

add http://my-tempo.tempo.svc.cluster.local:4317 in otlp.yaml




