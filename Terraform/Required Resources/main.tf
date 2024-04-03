resource "null_resource" "update" {
provisioner "local-exec" {
command = "aws eks update-kubeconfig --name terraformEKScluster --region us-east-1"
 }
}
provider "helm" {
 kubernetes {
   config_path = "~/.kube/config"

 }
}
resource "helm_release" "prometheus_node_exporter" {
  chart            = "prometheus-node-exporter"
  create_namespace = true
  namespace        = "node-exporter"
  name             = "node-exporter"
  wait             =  true
#  version          = "2.0.3"
  repository       = "https://prometheus-community.github.io/helm-charts"


#  dynamic "set" {
#    for_each = var.settings
#    content {
#      name  = set.key
#      value = set.value
#    }
#  }
   values      = [file("/home/ubuntu/terraform/mimir/node-expoter-values.yaml")] 
}

resource "helm_release" "alb-controller" {
 name       = "aws-load-balancer-controller"
 repository = "https://aws.github.io/eks-charts"
 chart      = "aws-load-balancer-controller"
 namespace  = "kube-system"
# depends_on = [
#     kubernetes_service_account.service-account
# ]

#  set {
#      name  = "region"
#      value = var.main-region
#  }

#  set {
#      name  = "vpcId"
#      value = var.vpc_id
#  }

#  set {
#      name  = "image.repository"
#      value = "602401143452.dkr.ecr.${var.main-region}.amazonaws.com/amazon/aws-load-balancer-controller"
#  }

#  set {
#      name  = "serviceAccount.create"
#      value = "false"
#  }

#  set {
#      name  = "serviceAccount.name"
#      value = "aws-load-balancer-controller"
#  }

  set {
      name  = "clusterName"
      value = "terraformEKScluster"
  }
 values      = [file("/home/ubuntu/terraform/mimir/alb-values.yaml")] 
 }

resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  create_namespace = true
  namespace   = "kube-state-metrics"
  wait        =  true
  #version    = "3.5.0"  # Update to the desired version
  
  values      = [file("/home/ubuntu/terraform/mimir/kube-state-metrics-values.yaml")] 
}
