# setup-ess-kind-cluster-action

This actions setups a kind cluster in the docker daemon. It is a prerequisite for the [`setup-ess-action`](https://github.com/element-hq/setup-ess-action).

## Inputs

By default, the chart is configured to work with public runners, and uses the latest of the dependencies (cert-manager, ingress-nginx, metrics-server, prometheus-operator).

You can customize this behaviour usiging the following inputs.

| Name | Description | Required | Default |
| --- | --- | --- | --- |
| `containerd-mirrors-path` | Containerd mirrors path. | No |  |
| `kind-shared-mount-path` | Kind shared mount path. | No | `.` |
| `cert-manager-version` | Cert-manager version. | No |  |
| `ingress-nginx-version` | Ingress-nginx version. | No | |
| `metrics-server-version` | Metrics-server version. | No | |
| `prometheus-operator-version` | Prometheus-operator version. | No | |
