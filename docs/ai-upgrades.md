# Upgrade Issues (AI Runbook)

How to perform the "check every application for upstream upgrades and file an
issue" sweep. Written so a repeat run (any agent) skips discovery and goes
straight to research. First run: 35 issues created, 2026-10-26.

## Scope and ground rules

- Applications live at `kubernetes/by-cluster/<cluster>/<tenant|system|workloads>/applications/by-namespace/<namespace>/<application>/`.
- One open issue per application (cluster + application pair). Never combine
  applications into one issue. Never look at closed issues.
- Issue title: `Upgrade <cluster>/<application-name> to <latest version>`.
- Issue body: current -> latest version with release date, a **What's new**
  summary, and a **Breaking changes / config** section with per-major
  breakdown when the path crosses multiple majors. Cite primary sources.

## Process

### 1. Baseline issue state

```sh
fj issue search -l upgrade
```

Open issues only (closed by default). Results paginate at 25 per page; use
`--page N` for the rest. A matching open issue for an application means: skip
that application unless a newer upstream release has appeared since the issue
was filed. The label is `upgrade`; issues are created on the `origin` remote
repo (`wtaylor/homelab`).

### 2. Inventory and current versions

```sh
find kubernetes/by-cluster -maxdepth 6 -type d -path '*/applications/by-namespace/*/*'
```

Every directory is one application. Version pins come in three styles:

1. Kustomize remote bases / Helm charts in `kustomization.yaml`
   (`ref=vX.Y.Z` on a github URL, or `helmCharts: ... version:`).
2. Container image tags in manifests (`image: repo/name:tag`), usually
   `resources/deployment.yaml` or `resources/statefulset.yaml`.
3. Raw manifest directories with **no** `kustomization.yaml` (tk831:
   bitwarden, homeassistant, joplin, linkwarden, postgres-default,
   zigbee2mqtt) - pins are image tags in the manifests.

Collect all pins in one pass:

```sh
grep -rE 'ref=|version:|tag:|newTag|helmCharts|repo:|image:' kubernetes/by-cluster --include='kustomization.yaml' -h
grep -rE 'image:.*:|imageName:' kubernetes/by-cluster --include='*.yaml'
```

The pin map appendix below lists every application, its pin location and its
upstream source, so this pass only needs re-running when the tree changes.

### 3. Research latest versions

Delegate. Four parallel research agents, sliced by area (cluster infra /
observability + secrets / tk831 apps / single-spicy workloads), each getting:
currently pinned version(s), a list of projects, and a fixed report shape
(current, latest, release date, source URL, what's-new bullets, breaking
changes across the **full** path, config notes).

Requirements per agent:

- Primary sources only: upstream GitHub releases pages, official chart
  indexes (`charts.jetstack.io/index.yaml`, `backube.github.io/helm-charts/`,
  `nats-io.github.io/k8s/helm/charts/`), official upgrade guides, project blogs.
  Cite the URL for every version claim. State `UNKNOWN` rather than guessing.
- Chart version vs app version is not always 1:1 - verify against
  `Chart.yaml` at the release tag (see pitfalls).
- Break out breaking changes per intermediate major/minor, e.g.
  `v1.17 -> v1.18: ...`, `v1.18 -> v1.19: ...` for the whole path.

The four reports are the sole source for issue bodies - no re-research per issue.

### 4. Create the issues

```sh
fj issue create --body '<body>' '<title>'
```

For multi-line markdown bodies use `--body-file` instead of `--body` (same
command, avoids shell quoting bugs):

```sh
cat > /tmp/upgrade-issues/<app>.md <<'BODY'
...
BODY
fj issue create --body-file /tmp/upgrade-issues/<app>.md 'Upgrade <cluster>/<app> to <version>'
```

`fj issue create` has **no label flag** - add the label afterwards:

```sh
fj issue edit <issue_number> labels -a upgrade
```

Capture the issue number from the `created issue #N: <title>` output, then
label immediately in the same loop.

### 5. Verify

```sh
fj issue search -l upgrade
```

Expect one issue per application (check both pages). Count must match the
inventory minus skips.

## When to skip (no issue)

- Config-only projects with no upstream software: no image/version pin
  anywhere (default-cluster-gateway, paseo-proxy, bootstrap-external-secrets).
- In-house images with no release channel (e.g. blungebot - built from a repo
  with zero releases; a newer commit-hash tag may exist but has no notes to
  diff).
- Helm charts already at the latest version.
- Cluster glue crds/instances that just consume an operator (postgres-default
  is an exception: its image tag is worth tracking).

## Pitfalls

- **Chart version != app version.** Examples found: forgejo chart 17.x ships
  Forgejo app 15.0.x; vm-operator chart 0.68.x embeds operator 0.75.x;
  nats chart adopted server-version numbering in 2025-10; sparky-fitness chart
  mirrors the app version; external-secrets chart == app version. Check the
  chart's `appVersion`/values at the tag.
- Some tk831 app dirs are raw manifests (no kustomization.yaml) - don't
  conclude they aren't applications.
- `fj issue create` lacks a label option; forgetting `labels -a upgrade` makes
  the issue invisible to `fj issue search -l upgrade`.
- Unpinned software: a Grafana CR without `spec.version` follows the operator
  default. Report the operator default as "current" and note the un-pinned
  status (grafana now pins `spec.version`).
- fj warns `mise WARN ... uv is not installed` on every invocation - harmless,
  filter with `grep -v 'mise WARN'`.

## Pin map (as of 2026-10-28)

### red-squadron-talos

| Application | Pin location | Upstream |
| --- | --- | --- |
| argocd | `system/argocd/argocd/kustomization.yaml` (remote base `?ref=v3.5.6`) | github.com/argoproj/argo-cd |
| cert-manager | `system/cert-manager/cert-manager/kustomization.yaml` (chart v1.17.2) | charts.jetstack.io |
| cloudnativepg-operator | `system/cnpg-system/cloudnativepg-operator/kustomization.yaml` (remote `cnpg-1.27.0.yaml`) | github.com/cloudnative-pg/cloudnative-pg |
| csi-proxmox | `system/csi-proxmox/csi-proxmox/kustomization.yaml` (remote `?ref=v0.17.1`) | github.com/sergelogvinov/proxmox-csi-plugin |
| envoy-gateway | `system/envoy-gateway-system/envoy-gateway/kustomization.yaml` (remote `v1.7.2/install.yaml`) | github.com/envoyproxy/gateway |
| external-secrets | `system/external-secrets/external-secrets/kustomization.yaml` (chart 2.10.0) | charts.external-secrets.io |
| cilium | `system/kube-system/cilium/kustomization.yaml` (chart 1.17.4) | helm.cilium.io |
| vector-agent | `system/vector/vector-agent/kustomization.yaml` (chart v0.59.0) | helm.vector.dev |
| volsync | `system/volsync-system/volsync/kustomization.yaml` (chart v0.17.0) | backube.github.io/helm-charts |
| blungebot | `blunge/blungebot/resources/deployment.yaml` (image tag) | in-house, no releases |
| bitwarden (vaultwarden) | `tk831/.../bitwarden/deployment.yaml` (image `vaultwarden/server:1.37.1`) | github.com/dani-garcia/vaultwarden |
| frigate | `tk831/.../frigate/resources/deployment.yaml` (image) | github.com/blakeblackshear/frigate |
| homeassistant | `tk831/.../homeassistant/deployment.yaml` (image) | home-assistant releases |
| immich | `tk831/.../immich/kustomization.yaml` (chart 0.10.3 + image tag) | immich-app/immich-charts + immich |
| joplin | `tk831/.../joplin/deployment.yaml` (image `joplin/server:3.5.2`) | github.com/laurent22/joplin (server) |
| linkwarden | `tk831/.../linkwarden/deployment.yaml` (image) | github.com/linkwarden/linkwarden |
| nats | `tk831/.../nats/kustomization.yaml` (chart 1.1.12) | nats-io.github.io/k8s/helm/charts |
| nodered | `tk831/.../nodered/resources/deployment.yaml` (image) | github.com/node-red/node-red |
| postgres-default | `tk831/.../postgres-default/cluster.yaml` (`imageName: ...postgresql:15.1`) | ghcr.io/cloudnative-pg/postgresql |
| sparky-fitness | `tk831/.../sparky-fitness/kustomization.yaml` (chart, OCI) | ghcr.io/codewithcj/charts |
| vector-nats-home-wiretap | `tk831/.../vector-nats-home-wiretap/kustomization.yaml` (chart v0.59.0) | helm.vector.dev |
| zigbee2mqtt | `tk831/.../zigbee2mqtt/deployment.yaml` (image) | github.com/Koenkk/zigbee2mqtt |
| bootstrap-external-secrets | namespace + secret only | - (skip) |
| default-cluster-gateway | Gateway/Certificates/EnvoyProxy CRs | - (skip) |

### single-spicy

| Application | Pin location | Upstream |
| --- | --- | --- |
| cert-manager | `system/cert-manager/cert-manager/kustomization.yaml` (chart v1.20.2) | charts.jetstack.io |
| csi-proxmox | `system/csi-proxmox/csi-proxmox/kustomization.yaml` (remote `?ref=v0.18.1`) | github.com/sergelogvinov/proxmox-csi-plugin |
| envoy-gateway | `system/envoy-gateway-system/envoy-gateway/kustomization.yaml` (remote `v1.8.0/install.yaml`) | github.com/envoyproxy/gateway |
| external-secrets | `system/external-secrets/external-secrets/kustomization.yaml` (chart 2.9.0) | charts.external-secrets.io |
| grafana-operator | `system/grafana/grafana-operator/kustomization.yaml` (chart 5.25.0, OCI) | ghcr.io/grafana/helm-charts |
| cilium | `system/kube-system/cilium/kustomization.yaml` (chart 1.19.4) | helm.cilium.io |
| vm-operator | `system/victoria-metrics/vm-operator/kustomization.yaml` (chart 0.68.1) | victoriametrics.github.io/helm-charts |
| volsync | `system/volsync-system/volsync/kustomization.yaml` (chart v0.15.0) | backube.github.io/helm-charts |
| op-connect | `bootstrap/external-secrets/op-connect/kustomization.yaml` (chart 2.4.1) | github.com/1Password/connect-helm-charts |
| forgejo | `workloads/development/forgejo/kustomization.yaml` (chart 17.1.1, OCI) | code.forgejo.org/forgejo-helm |
| grafana | `workloads/grafana/grafana/resources/grafana.yaml` (Grafana CR `spec.version` 13.2.4) | grafana releases |
| kanidm | `workloads/kanidm/kanidm/resources/statefulset.yaml` (image `kanidm/server:1.10.3`) | github.com/kanidm/kanidm |
| vector-agent | `workloads/vector/vector-agent/kustomization.yaml` (chart v0.59.0) | helm.vector.dev |
| vector-aggregator | `workloads/vector/vector-aggregator/kustomization.yaml` (chart v0.59.0) | helm.vector.dev |
| vm-k8s-stack | `workloads/victoria-metrics/vm-k8s-stack/kustomization.yaml` (chart 0.97.0) | victoriametrics.github.io/helm-charts |
| vm-storage | `workloads/victoria-metrics/vm-storage/kustomization.yaml` (chart 2.8.1, OCI) | ghcr.io/reliablyobserve/charts (loki-vl-proxy) |
| paseo-proxy | Service/HTTPRoute only | - (skip) |
| default-cluster-gateway | Gateway/Certificates/EnvoyProxy CRs | - (skip) |