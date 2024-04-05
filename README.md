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

Step 1:
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

Step 2:
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

Step 3:
Mimir installation:
---
-->helm repo add grafana https://grafana.github.io/helm-charts

-->kubectl create ns mimir

-->helm install mimir grafana/mimir-distributed -n mimir

NOTE:

-->add http://mimir-nginx.jagadeesh.svc:80/prometheus in otel collector

step 4:
Tempo installation:
---
-->helm repo update

-->helm repo add grafana https://grafana.github.io/helm-charts

-->kubectl create ns tempo

-->helm install my-tempo grafana/tempo -n tempo         ##static tempo

-->helm -n tempo install tempo grafana/tempo-distributed     ##distributed tempo

<img width="795" alt="Screenshot 2024-04-05 105451" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/3f55b5f5-f847-42d8-ba43-a4faa4bae0c1">


Step 5:
Traces we need application, deploy an application :
---
link for Reference: https://medium.com/opentelemetry/deploying-the-opentelemetry-collector-on-kubernetes-2256eca569c9

deploy app.yaml 

-->kubectl port-forward deployment/myapp 8080 -n app &

hitting the application

-->curl localhost:8080/order

kubectl port-forward deployment/myapp 8081:8080 -n tempo  &

Step 6: 
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

<img width="784" alt="Screenshot 2024-04-05 105245" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/ec3acda6-1d0c-4b78-97bb-26aea79ac034">


Step 7:
OnlineBoutique application:
---
clone https://github.com/jagadeeshreddy280/microservice-app.git in ec2.

Go to /helm-chat directory

helm install app . -n app

kubectl get all -n app

copy service url in google u can access it. check logs in Grafana dashbord in namespace app.

![image](https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/457685e9-b172-4806-8f8e-aa79fb785c01)


Step 8:
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

Upto Step 8 we are done with setup, we integrate with Grafana.

<img width="343" alt="image" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/68224960-085e-4dba-9eaa-7e5ae2160620">


Step 9:
Integration with Grafana via Email or MsTeams:
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

<img width="646" alt="Screenshot 2023-09-14 141226" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/29489395-95df-4157-a210-6e8ca9cdf4a9">



Using personal Gmail:
---

1.open Gmail settings --> go to security 

2.Enable 2-step verification --> Inside we can see app passwords.

3.click on App password --> selete other --> Type Name --> create .

4.WE can see 16 letter Password save it.

9.Save the Alert       

Ms Teams Authentication:
---

1.open grafana alert --> contact points -->type alert name

2.In integration select required option(example:ms teams)

3. Go to Teams --> create a channel for alerts --> click on 3 dots

4.Go to connectors --> click on incoming webhook configure --> Type name

5.click on create --> copy link --> paste in grafana alert url --> test

6.We will get default test notification


Step 10:
Creating a Dashboard:
---

1.Go to Dashboard --> click on New --> Create a Folder 

2.Again click on New --> new Dashboard --> Dashboard setting 

3.Type Name --> select folder --> save Dashboard


<img width="847" alt="Screenshot 2023-09-14 145625" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/77c41877-1735-4afe-9850-287cb2672732">


Step 11:
Creating a panel for Dashboard:
---

1.Inside Dashboard --> click on Add --> visualization

<img width="601" alt="Screenshot 2023-09-14 145840" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/bf56e7b4-782d-4a17-b55e-a1b6d773da49">


2.we can see all details .

<img width="905" alt="Screenshot 2023-09-14 145949" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/f5ed8381-7e84-4d65-9cda-febdc9734b77">


3.select correct Datasource for panal creation in Datasource section.

<img width="271" alt="Screenshot 2023-09-14 150029" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/500ddbb6-db29-42ce-a1ea-4860c16ba599">


4.We have Two options to write query 1.Builder 2.code

<img width="609" alt="Screenshot 2023-09-14 150123" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/b802a648-0cd4-4e9e-b16b-710cecbbc1da">


5.In builder we need to select label and Value for filter data.

6.In code we use Promql query.

Example : {namespace="app"} | logfmt

<img width="606" alt="Screenshot 2023-09-14 150216" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/a476c5b3-e8fc-49d8-ad5d-8ddeedcb720d">


7.Right side we can select differt graphs and options.

<img width="294" alt="Screenshot 2023-09-15 111151" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/896a9f86-c3ed-4bc6-9d5c-9c1df4599491">


8.click on save --> apply

9.Now Go to Dashboard we can see a panel with data representation. 

logs:
---

<img width="909" alt="Screenshot 2023-09-14 150340" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/50fab4c0-539b-446b-b231-62a684483700">

metrics:
---

<img width="412" alt="Screenshot 2024-04-05 105738" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/e9910476-8b71-4aa0-9ff3-e58f3afb31c0">

Traces:
---

<img width="821" alt="Screenshot 2024-04-05 105650" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/cd65aebb-302d-4051-8173-4f787966973e">

some Dashboards for Referrence:
---

<img width="763" alt="Screenshot 2023-09-14 152040" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/790fb494-5c1f-4cbe-9302-630a6b683961">

Step 12:
Creation of Alerts using logs and Metrics:
---

1.Go To dashboard --> select panel for alert 

2.Above datasource we have 3 options like 1.query 2.transform 3.Alert

<img width="607" alt="Screenshot 2023-09-14 143004" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/474ae933-b8f7-4e50-95e1-c3da064bd500">


3.click on Alert --> click on create alert rule from this panel

4.Type Rule Name --> select duration -->click on  run queries --> check Threshold Normal or firing

<img width="685" alt="Screenshot 2023-09-14 143114" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/c166ad28-7c86-42bb-a6cc-3c0d488eb2b3">


5.Go to Set alert evaluation behavior --> select folder --> select Evaluation group

6.If folder or evaluation group not present, create new 

7.In pending period select time
Note: Time should be same in pending period and Evalution group

<img width="683" alt="Screenshot 2023-09-14 143252" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/710c1d62-c2ae-4ed1-98c8-caae203fdf17">


8.In Add annotations we can add summary and description of Alert

Email Alert:
---

<img width="416" alt="Screenshot 2023-09-14 143540" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/6c100b02-f5c0-45e9-b0d9-7031c84dfc4d">


Alert look like this 
---

<img width="683" alt="Screenshot 2024-04-05 110031" src="https://github.com/jagadeeshreddy280/Observability-setup/assets/116871383/ce15008a-b041-4d61-997b-28415b0fa706">







