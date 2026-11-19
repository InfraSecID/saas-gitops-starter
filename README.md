# SaaS Multi-Tenant GitOps Starter Kit
<img width="1280" height="710" alt="21658ecb-3eb1-4317-975b-b128aea05a04" src="https://github.com/user-attachments/assets/9d754f5e-02d5-4283-a51b-efff035f1cc7" />

A ready-to-use GitOps template for running a **multi-tenant SaaS platform on Kubernetes**.

It uses:

- **Argo CD** as the deployment control plane
- **ApplicationSet** to create tenant applications automatically from one YAML file
- **Kustomize** to manage the `basic` and `pro` service tiers
- **External Secrets Operator (ESO)** to keep secrets out of Git
- A hardened **Node.js + TypeScript + Express** backend example

## Monorepo layout

This template keeps `infra/`, `platform-configs/`, and `workloads/` in one repository. This makes it easy to fork the whole setup and test it from end to end.

For a large enterprise, you can later split these folders into three separate Git repositories. Update `repoURL` in `platform-configs/applicationsets/tenants-applicationset.yaml`, and update `sourceRepos` in:

- `platform-configs/projects/appproject-basic.yaml`
- `platform-configs/projects/appproject-pro.yaml`

---

## 1. Tools you need

Install these tools on your local machine or CI/CD runner:

- `git` >= 2.40
- `kubectl` >= 1.29, including `kubectl kustomize`
- `terraform` >= 1.6.0, for creating the AWS EKS infrastructure
- `kind` >= 0.22 or `minikube` >= 1.32, for a local Kubernetes cluster
- `node` >= 20.12.2 and `npm` >= 10.x, for developing and testing the backend
- `docker` >= 25.0, for building the backend container image
- `argocd` CLI, optional, for checking sync status in the terminal

---

## 2. Create the infrastructure

### Option A: Deploy with Terraform

1. Open `infra/`.
2. Replace the placeholders in `infra/versions.tf`:
   - `__TF_STATE_BUCKET__`
   - `__TF_LOCK_TABLE__`
3. Replace the placeholders in `infra/variables.tf`:
   - `__CONTROL_PLANE_CLUSTER_NAME__`
   - `__DATA_PLANE_CLUSTER_NAME__`
   - `__ORG_NAME__`
4. Initialize Terraform and create the infrastructure:

   ```bash
   cd infra
   terraform init
   terraform validate
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

Terraform creates:

- An EKS control plane cluster and installs Argo CD.
- An EKS data plane cluster, External Secrets Operator with IRSA, and the kube-prometheus-stack.

### Option B: Run locally with kind or minikube

You can try the setup without a cloud account by using the local manifests.

Using kind:

```bash
kind create cluster --name saas-gitops-local
./bootstrap.sh
kubectl apply -k infra/local
kubectl apply -k platform-configs/observability
kubectl apply -k platform-configs
```

Using minikube, first start a cluster, then run `./bootstrap.sh` and the `kubectl apply` commands above.

---

## 3. Open the Argo CD dashboard

After Argo CD is running in the `argocd` namespace:

```bash
kubectl port-forward svc/argocd-server -n argocd 8443:443
```

Get the default admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

The password is stored in Kubernetes, not in Git.

Open [https://localhost:8443](https://localhost:8443) in your browser.

---

## 4. Add a new tenant

You only need to add one tenant YAML file. You do not need to change the base workload or platform configuration.

1. Create a folder under `workloads/tenants/`, for example `workloads/tenants/tenant-gamma/`.
2. Add a `tenant.yaml` file:

   ```yaml
   apiVersion: saas.platform.io/v1alpha1
   kind: TenantConfig
   metadata:
     name: gamma
     labels:
       saas.platform/tenant: gamma
       saas.platform/tier: basic
   tenant:
     name: gamma
     tier: basic
     domain: gamma.saas.example.com
     imageTag: "1.0.0"
     partitionKey: "tenant_gamma"
     resources:
       requests:
         cpu: "100m"
         memory: "128Mi"
       limits:
         cpu: "250m"
         memory: "256Mi"
   ```

   Use `workloads/tenants/tenant-alpha/tenant.yaml` as a `basic` example or `workloads/tenants/tenant-beta/tenant.yaml` as a `pro` example.

3. Commit and push the file:

   ```bash
   git add workloads/tenants/tenant-gamma/tenant.yaml
   git commit -m "feat(tenants): onboard tenant gamma (basic tier)"
   git push origin main
   ```

Argo CD will read the tenant file and create the tenant application automatically.

### Tenant isolation

The `tenant-gamma` example above is isolated by:

- `platform-configs/applicationsets/tenants-applicationset.yaml`
- `platform-configs/projects/appproject-basic.yaml`
- `platform-configs/projects/appproject-pro.yaml`

The ApplicationSet:

- Sets `.spec.project` to `tenant-tier-<tier>`.
- Creates the tenant namespace as `tenant-<tier>-<name>`.

The AppProjects limit where tenant workloads can run:

- Basic tenants can deploy only to `tenant-basic-*` namespaces.
- Pro tenants can deploy only to `tenant-pro-*` namespaces.

They also limit Kubernetes resources. Tenants cannot create cluster-level resources such as `ClusterRole`, `ClusterRoleBinding`, or `DaemonSet`.

---

## 5. Remove a tenant

To remove a tenant and its resources:

1. Delete the tenant folder:

   ```bash
   git rm -r workloads/tenants/tenant-alpha
   git commit -m "chore(tenants): remove tenant alpha"
   git push origin main
   ```

2. Argo CD will remove the tenant resources. Pruning is enabled by `syncPolicy.automated.prune: true`.

The resources are also protected by the `resources-finalizer.argocd.argoproj.io` finalizer, so Argo CD removes the tenant application and its namespace, deployments, services, ingress, autoscaling settings, network policies, quotas, limits, and external secrets.

---

## 6. Roll back a change

All desired state is stored in Git. If an image upgrade or quota change causes an incident:

```bash
git log --oneline -n 5
git revert <COMMIT_SHA> --no-edit
git push origin main
```

Replace `<COMMIT_SHA>` with the commit that introduced the problem.

Argo CD detects the new Git revision and restores the previous configuration. `selfHeal: true` also repairs any manual changes made directly in the cluster.

---

## 7. Repository structure

### `infra/`

Terraform modules and local Kubernetes manifests:

- `infra/main.tf`
- `infra/variables.tf`
- `infra/outputs.tf`
- `infra/versions.tf`
- `infra/modules/cluster/main.tf`
- `infra/modules/addons/main.tf`
- `infra/local/kustomization.yaml`

### `platform-configs/`

Argo CD control-plane configuration:

- `platform-configs/projects/`: basic and pro `AppProject` isolation
- `platform-configs/rbac/argocd-rbac-cm.yaml`: Argo CD RBAC settings
- `platform-configs/rbac/tenant-roles.yaml`: tenant roles
- `platform-configs/applicationsets/tenants-applicationset.yaml`: creates applications for tenants
- `platform-configs/observability/`: Prometheus, Grafana, and `ServiceMonitor` configuration

### `workloads/`

Application and workload configuration:

- `workloads/base/`: shared Kustomize resources
- `workloads/overlays/basic/`: settings for basic tenants
- `workloads/overlays/pro/`: settings for pro tenants
- `workloads/tenants/`: tenant declarations
- `workloads/backend/`: Node.js + TypeScript application, tests, and Dockerfile

---

## 8. Basic and pro tiers

| Feature | Basic tier | Pro tier |
|---|---|---|
| Argo CD `AppProject` | `tenant-tier-basic`, with `tenant-basic-*` namespaces | `tenant-tier-pro`, with `tenant-pro-*` namespaces |
| Namespace | `tenant-basic-<tenant-name>` | `tenant-pro-<tenant-name>` |
| Database and storage | Shared database and storage prefix, such as `s3://saas-shared-bucket/tenants/<tenant-name>/` | Dedicated database plus a tenant partition prefix |
| Resource quota: CPU requests | `500m` | `2000m` |
| Resource quota: CPU limits | `1000m` | `4000m` |
| Resource quota: memory requests | `512Mi` | `2Gi` |
| Resource quota: memory limits | `1Gi` | `4Gi` |
| Maximum pods | 4 | 15 |
| Maximum container CPU | `500m` | `2000m` |
| Maximum container memory | `512Mi` | `2Gi` |
| HPA replicas | Minimum 1, maximum 3 | Minimum 3, maximum 10 |
| Database network access | Shared PostgreSQL pod on port `5432` | Dedicated pro PostgreSQL pod on port `5432` |
