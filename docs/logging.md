# Logging

Logs may come from a variety of sources, most commonly:

- Kubernetes containers and node logs
- JournalD exports
- Kernel dmesg

Best endeavours are taken to ingest all these logs and categorise them efficiently.

## Log Fields and Destructuring

### Base Field Set

All logs should be structured where possible prior to ingestion. The following
is the set of labels that should be attached to all workloads at a minimum where
applicable.

| Label | Required | Is Stream Field? | Example | Meaning |
| ----- | -------- | ---------------- | ------- | -------- |
| part_of | no | yes | homelab | The name of the suite of applications and the common purpose they contribute to |
| application_name | no | yes | argocd | The name of the group of services providing a complete function |
| service_name | yes | yes | argocd-repo-server | An identifier for the service, usually corresponds to the name of a binary |
| log_origin_type | yes | no | journald/kubernetes_pod/dmesg | The service that this log was collected from |
| log_origin_collector | yes | no | vector/vlagent | The name of the application that collected this log |
| host | yes | yes | tardis-vm-100 | The immediate host that the service is running on. Likely a VM |
| host_physical | no | yes | tardis | The physical host that the host is running on if applicable and discoverable. |
| instance | no | yes | prod/vm-k8s-stack-single-spicy | An identifier that represents an instance of a specific application. |

## Kubernetes

### Additional Field Set

| Label | Required | Is Stream Field? | Example | Meaning |
| ----- | -------- | ---------------- | ------- | -------- |
| kubernetes_cluster_name | yes | yes | single-spicy | The canonical name of the cluster the log originated from |
| kubernetes_node_hostname | yes | no | single-spicy-1 | The node in the cluster that the workload is running on |
| kubernetes_node_region | no | no | tardis | The region the node is in, in this homelab, it corresponds to the physical host |
| kubernetes_node_zone | no | no | tardis | The region the node is in, in this homelab, it corresponds to the physical host |
| kubernetes_pod_namespace | yes | no | kube-system | The namespace of the pod the log was produced from |
| kubernetes_pod_name | yes | yes | argocd-repo-server | The name of the pod that produced the log |
| kubernetes_pod_ip | no | no | 10.1.2.3 | The ip address of the pod that produced the log |
| kubernetes_pod_owner | no | yes | ReplicaSet/123 | A shortform ownership reference to the resource that owns the pod |
| kubernetes_container_image | yes | no | ghcr.io/argo/argocd-repo-server:latest | The image of the running container that produced the log |
| kubernetes_container_name | yes | yes | repo-server | The name of the container that produced the log |

### Mapping

| Label | Derived From |
| ----- | ------------- |
| part_of | pod_annotations."app.w7x6t.dev/part-of" |
| application_name | pod_annotations."app.w7x6t.dev/application" |
| instance | pod_annotations."app.w7x6t.dev/instance" |
| service_name | pod_annotations."app.w7x6t.dev/service" |
| log_origin_type | kubernetes_logs |
| log_origin_collector | vector |
| host | pod_node_name |
| host_physical | node_labels."topology.kubernetes.io/zone" |
| kubernetes_cluster_name | static |
| kubernetes_node_hostname | pod_node_name |
| kubernetes_node_region | node_labels."topology.kubernetes.io/region" |
| kubernetes_node_zone | node_labels."topology.kubernetes.io/zone" |
| kubernetes_pod_namespace | pod_namespace |
| kubernetes_pod_name | pod_name |
| kubernetes_pod_ip | pod_ip_address |
| kubernetes_pod_owner | pod_owner |
| kubernetes_container_image | container_image |
| kubernetes_container_name | container_name |
