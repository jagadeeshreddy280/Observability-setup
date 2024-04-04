Any Queries related connect 
---
Gmail : jagadeeshbhavanam@gmail.com
---
linkedin : https://www.linkedin.com/in/bhavanam-jagadeeswara-reddy-1b85801b6
---

>>Opentelemetry?

open-source observability framework.
OpenTelemetry is a set of APIs, SDKs and other components (like the OpenTelemetry Collector or Operator) designed for the 
generation of high-quality telemetry data (traces, metrics, and logs) from cloud-native software.

Easy to collect telemetry data from your applications and infrastructure. 
This data can then be used to monitor your systems, troubleshoot problems, and improve performance.

otel collector consists of
1.receivers
2.processers
3.exporters

OpenTelemetry vs. OpenTracing 

OpenTelemetry and OpenTracing are both open-source projects that provide tools and APIs for instrumentation data management.

i)OpenTracing is an API for generating trace data. It supports several popular tracing backends, including Jaeger and Zipkin.

ii)OpenTelemetry, on the other hand, is a merger of OpenTracing and another project – OpenCensus. Unlike OpenTracing, 
OpenTelemetry supports multiple telemetry data types: traces, metrics, and logs.

##Obeservability platform Used to Track the Logs, Metrics, Traces Of the Application.
---
1.cloud platform         :   AWS

2.logs                   :   Loki

3.Metrics                : Prometheus,Mimir

4.Traces                 : Tempo

5.Opentelemetry is used to connect loki,mimir,Tempo as expoter to grafana

6.Alerts                 : MS Teams,Pager Duty, Email

7.Storing data           : Amazon S3

8.Monitoring             : Grafana

------------------------------------------------------------------------------
Order for setting up the platform for monitoring

>>Need to insatll eks cluster,enable cluster-autoscalar,loadbalancer

>>Install Kubectl,helm,git

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
-----------------------------------------------
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

##In order to make prometheus and grafana available outside the cluster, use LoadBalancer or NodePort instead of ClusterIP.

kubectl edit svc stable-kube-prometheus-sta-prometheus -n jagadeesh

kubectl edit svc stable-grafana -n jagadeesh

>>open loadbalancer url in google
>>
checking password:
-->kubectl get secret --namespace jagadeesh stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

username: admin
password: prom-operator

type password and login u can see dashboard

Loki installation:
-----------------------------------------------
-->helm repo add grafana https://grafana.github.io/helm-charts

-->kubectl create ns loki

-->helm install loki grafana/loki-distributed -n loki

-->kubectl get all -n loki

NOTE:
create ingress for service/loki-distributed-query-frontend

replace ingress url in otel.yaml

example:

loki:
  endpoint: http://k8s-loki-loki-17c4ba30dc-13242.us-east-1.elb.amazonaws.com/loki/api/v1/push

Mimir installation:
---
-->helm repo add grafana https://grafana.github.io/helm-charts

-->kubectl create ns mimir

-->helm install mimir grafana/mimir-distributed -n mimir

NOTE:

-->add http://mimir-nginx.jagadeesh.svc:80/prometheus in otel collector

Tempo installation:
---
-->helm repo update

-->helm repo add grafana https://grafana.github.io/helm-charts

-->kubectl create ns tempo

-->helm install my-tempo grafana/tempo -n tempo         ##static tempo

-->helm -n tempo install tempo grafana/tempo-distributed     ##distributed tempo

Traces we need application:
---
link for Reference: https://medium.com/opentelemetry/deploying-the-opentelemetry-collector-on-kubernetes-2256eca569c9

deploy app.yaml 

-->kubectl port-forward deployment/myapp 8080 -n app &

hitting the application

-->curl localhost:8080/order

kubectl port-forward deployment/myapp 8081:8080 -n tempo  &

Otel installation & integration with Loki,prometheus,mimir,tempo:
---

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

OnlineBoutique application:
---
clone https://github.com/jagadeeshreddy280/microservice-app.git in ec2.

Go to /helm-chat directory

helm install app . -n app

kubectl get all -n app

copy service url in google u can access it. check logs in Grafana dashbord in namespace app.

Adding Endpoint to Grafana for logs,metrics & Traces:
---
-->Sign in using the default username admin and password prom-operator.

-->On the left-hand side, go to Configuration > Data sources.

-->add new data source (prometheus) and rename to mimir

-->add url of mimir like(http://mimir-nginx.jagadeesh.svc:80/prometheus)
   it will be available at creation of mimir 
   
-->save and test 

o/p:

-->Successfully queried the Prometheus API.

   Next, you can start to visualize data by building a dashboard, or by querying data
   in the Explore view.

NOTE: similarly add LOKI and TEMPO enpoints to Grafana



Integration with Grafana:
---

1. open grafana --> Go to config file

2.In grafana.ini --> we can see smtp: --> we need to add data like this
AWS cred:

  smtp:
  
    enabled: true
    
    host: email-smtp.us-west-2.amazonaws.com:587
    
    startTLS_policy: MandatoryStartTLS
    
    skip_verify: true
    
    user: AKIAVU2RHDV            ## we need to replace username
    
    password: BMULk1hQU4VdEWR    ## we need to replace password
    
    from_address: ses-smtp-user.2023090      
    
    from_name: Grafana
    
personal Gmail:

  smtp:
  
    enabled: true
    
    host: smtp.gmail.com:465
    
    startTLS_policy: MandatoryStartTLS
    
    skip_verify: true
    
    user: jagadeesh@gmail.com
    
    password: 16 letter password
    
    from_address: jagadeesh@gmail.com
    
    from_name: Grafana

3.save and exit the grafana.yaml

4.helm upgrade --install grafana grafana/grafana -f grafana.yaml -n grafana

5.open grafana alert --> contact points -->type alert name

6.In integration select required option(example:Email)

7.Type required emails to send alerts --> test

8.We will get default test notification

Creating a Dashboard:
---

1.Go to Dashboard --> click on New --> Create a Folder 

2.Again click on New --> new Dashboard --> Dashboard setting 

3.Type Name --> select folder --> save Dashboard

Creating a panel for Dashboard:
---

1.Inside Dashboard --> click on Add --> visualization

2.we can see all details .

3.select correct Datasource for panal creation in Datasource section.

4.We have Two options to write query 1.Builder 2.code

5.In builder we need to select label and Value for filter data.

6.In code we use Promql query.

Example : {namespace="app"} | logfmt

7.Right side we can select differt graphs and options.

8.click on save --> apply

9.Now Go to Dashboard we can see a panel with data representation. 


Creation of Alerts using logs and Metrics:
---

1.Go To dashboard --> select panel for alert 

2.Above datasource we have 3 options like 1.query 2.transform 3.Alert

3.click on Alert --> click on create alert rule from this panel

4.Type Rule Name --> select duration -->click on  run queries --> check Threshold Normal or firing

5.Go to Set alert evaluation behavior --> select folder --> select Evaluation group

6.If folder or evaluation group not present, create new 

7.In pending period select time
Note: Time should be same in pending period and Evalution group

8.In Add annotations we can add summary and description of Alert

Ms Teams Authentication:
---

1.open grafana alert --> contact points -->type alert name

2.In integration select required option(example:ms teams)

3. Go to Teams --> create a channel for alerts --> click on 3 dots

4.Go to connectors --> click on incoming webhook configure --> Type name

5.click on create --> copy link --> paste in grafana alert url --> test

6.We will get default test notification

SMTP email connection:
--

Using AWS SES:
--

1.open AWS SES --> Go to Verified Identities --> create a new identitie with mail

2.Identity type 1.domain 2.email prefer what you need for task --> click on create identitie.

3.we can see mail address is in pending, we need to approve our req which we will receive in register mail --> click on accept link --> show verified

4.We can send Test alert using send test email option.

Creation on SMTP user and Password:
--

1. click on SMTP settings --> create new SMTP credentials
   
2.set custom user name or default -->create user --> download file.csv

3.In smtp setting we can see endpoint and ports.


Using personal Gmail:
---

1.open Gmail settings --> go to security 

2.Enable 2-step verification --> Inside we can see app passwords.

3.click on App password --> selete other --> Type Name --> create .

4.WE can see 16 letter Password save it.

9.Save the Alert               





