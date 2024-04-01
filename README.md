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
1.Grafana
2.loki
3.promtail
4.tempo
5.mimir
6.cluster-autoscalar
7.prometheus_node_exporter
8.aws-load-balancer-controller
9.kube_state_metrics


