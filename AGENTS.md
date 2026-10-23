# AGENTS.md

Guidance for AI agents working in this repository.

## Layout

- `kubernetes/by-cluster/<cluster>/` holds one directory per cluster
  (`single-spicy`, `red-squadron-talos`).
- Cluster directories split into `system/` (cluster infrastructure), `workloads/`
  or tenant directories (`blunge/`, `tk831/`), and ArgoCD glue (`app-of-apps/`,
  `root/`, `bootstrap/`).
- Kustomize projects sit at `.../applications/by-namespace/<namespace>/<project>/`.
  ArgoCD ApplicationSets point at these paths and take the destination namespace from them.
- `charts/` directories inside projects are Helm pulls made during builds. They are
  gitignored, so never edit them.

## Tooling

- Build a project with `mise run kustomize:build <path>`. Use this rather than
  calling kustomize directly, since it enables Helm and decrypts `*.env.tmpl` files.
- Never run `kubectl`, including the `mise` kubectl tasks. Changes reach clusters
  through git and ArgoCD.
- `yq`, `helm` and `kustomize` are installed through mise.
- `format:fix` (`mise run hk:fix`) is run by a hook whenever an agent writes a file, and does not need to be run directly by the agent.

## Working Rules

- Run `git status` before editing. The owner often has uncommitted work in progress.
  Don't modify, revert or stage files you didn't change.
- Don't commit unless asked.
- Keep changes small and follow the pattern of neighbouring projects.
- Ask before changing naming conventions or `part-of` values.
- Don't overwrite personal values the owner has set (for example service names) when
  editing around them.

## Annotations

Every workload carries `app.w7x6t.dev/part-of`, `application` and `service`.
Never set `env` or `instance`. See `docs/logging.md` for the rules and where each
annotation goes.

## Kustomize and Helm Patterns

- Helm charts: set pod annotations in `valuesInline`. Check the chart templates first,
  since some keys are commented out but still read.
- Remote bases and charts without an annotation value: use strategic-merge patches on the pod template.
- Own manifests: edit the pod template directly.
- Operator-managed pods (VictoriaMetrics, Grafana, CloudNativePG, Envoy Gateway):
  set the pod metadata on the custom resource.
- Kustomize's top-level `namespace:` does not reach Helm output unless the chart sets
  `metadata.namespace` itself. Check the build for namespace-less objects. ArgoCD fills
  them in, but `kubectl apply` would not.
- When a patch targets an object that has no namespace in the build, omit `namespace`
  from the patch.

## Gateway Routes

- HTTPRoutes attach to the `default` Gateway in `kube-system` using `sectionName: https`.
- Hostnames are `<name>.w7x6t.dev`. The gateway's wildcard certificate covers them.
- If a backend serves TLS, add a `BackendTLSPolicy` (see kanidm).

## Verification

- Build every project you change, and make sure it succeeds.
- Compare the output against a baseline build from before your change. Only the
  intended lines should differ.
- Check that namespaced objects have a namespace, and that pods carry all three annotations.
- Validate new custom resources against their CRD schema, where the CRD is in the
  build output.
- Harmless noise: `null` fields are dropped on re-serialisation, and Cilium regenerates
  its webhook certificates on every build.
