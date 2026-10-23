# Logging

Logs may come from a variety of sources, most commonly:

- Kubernetes containers and node logs
- JournalD exports
- Kernel dmesg

Best endeavours are taken to ingest all these logs and categorise them efficiently.

## Log Fields and Destructuring

### Base Field Set

All logs should be structured where possible prior to ingestion. The following
is the set of fields that should be attached to all workloads at a minimum. The
`part_of`, `application_name` and `service_name` fields are derived from pod
annotations (see [Mapping](#mapping)) and are required for every workload.

| Label | Required | Is Stream Field? | Example | Meaning |
| ----- | -------- | ---------------- | ------- | -------- |
| part_of | yes | yes | homelab | The name of the suite of applications and the common purpose they contribute to |
| application_name | yes | yes | argocd | The name of the group of services providing a complete function |
| service_name | yes | yes | argocd-repo-server | An identifier for the service, usually the name of the workload (Deployment, StatefulSet, DaemonSet) that produced the log, or the binary name where they differ |
| origin_type | yes | no | journald/kubernetes_pod/dmesg | The service that this log was collected from |
| origin_collector | yes | no | vector/vlagent | The name of the application that collected this log |
| host | yes | yes | tardis-vm-100 | The immediate host that the service is running on. Likely a VM |
| host_physical | no | yes | tardis | The physical host that the host is running on if applicable and discoverable. |
| env | no | yes | prod | Not set by convention. Never add it to a workload. |
| instance | no | yes | prod/vm-k8s-stack-single-spicy | Not set by convention. Never add it to a workload. |

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
| kubernetes_pod_app_label_part_of | no | no | homelab | The pod's `app.kubernetes.io/part-of` label, kept for reference |
| kubernetes_pod_app_label_name | no | no | argocd-repo-server | The pod's `app.kubernetes.io/name` label, kept for reference |
| kubernetes_pod_app_label_instance | no | no | argocd | The pod's `app.kubernetes.io/instance` label, kept for reference |
| kubernetes_pod_app_label_component | no | no | repo-server | The pod's `app.kubernetes.io/component` label, kept for reference |

### Mapping

| Label | Derived From | Fallback |
| ----- | ------------ | -------- |
| part_of | pod_annotations."app.w7x6t.dev/part-of" | unset |
| application_name | pod_annotations."app.w7x6t.dev/application" | unset |
| service_name | pod_annotations."app.w7x6t.dev/service" | unset |
| env | pod_annotations."app.w7x6t.dev/env" | unset |
| instance | pod_annotations."app.w7x6t.dev/instance" | unset |
| origin_type | static."kubernetes_logs" | n/a |
| origin_collector | static."vector" | n/a |
| host | pod_node_name | n/a |
| host_physical | node_labels."topology.kubernetes.io/zone" | unset |
| kubernetes_cluster_name | static."{cluster-name}" | n/a |
| kubernetes_node_hostname | pod_node_name | n/a |
| kubernetes_node_region | node_labels."topology.kubernetes.io/region" | unset |
| kubernetes_node_zone | node_labels."topology.kubernetes.io/zone" | unset |
| kubernetes_pod_namespace | pod_namespace | n/a |
| kubernetes_pod_name | pod_name | n/a |
| kubernetes_pod_ip | pod_ip_address | unset |
| kubernetes_pod_owner | pod_owner | unset |
| kubernetes_container_image | container_image | n/a |
| kubernetes_container_name | container_name | n/a |
| kubernetes_pod_app_label_part_of | pod_labels."app.kubernetes.io/part-of" | unset |
| kubernetes_pod_app_label_name | pod_labels."app.kubernetes.io/name" | unset |
| kubernetes_pod_app_label_instance | pod_labels."app.kubernetes.io/instance" | unset |
| kubernetes_pod_app_label_component | pod_labels."app.kubernetes.io/component" | unset |

## Annotating Workloads

Every workload should carry the following annotations:

```yaml
app.w7x6t.dev/part-of: "homelab" # or "k8s-cluster-system"
app.w7x6t.dev/application: "<project directory name>"
app.w7x6t.dev/service: "<workload name>"
```

Rules:

- `part-of`: `k8s-cluster-system` for everything under `system/`, and for the
  single-spicy vector agent. `homelab` for other workloads.
- `application`: the name of the kustomize project directory, unless the
  directory name is shorthand for something else.
- `service`: the name of the workload. If a project has only one resource that
  creates pods, `service` and `application` are identical.

Known gap: volsync mover pods cannot be annotated, because `ReplicationSource`
only exposes `moverPodLabels`.
