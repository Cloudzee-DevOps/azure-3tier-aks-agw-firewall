# CLOUDZEE — Azure 3‑Tier Reference (Terraform + Ansible)

**Edge Firewall → WAF App Gateway → AKS (AGIC)**

A portfolio‑ready, end‑to‑end project that provisions a production‑style 3‑tier web path on Azure and deploys a demo app via Ansible.

* **Ingress path:** Internet → **Azure Firewall (DNAT 80/443)** → **Application Gateway (WAF\_v2, private)** → **AKS** Services via **AGIC addon** (Ingress)
* **Networking:** Hub VNet (Firewall) + Spoke VNet (AppGW+AKS) with VNet peering. UDR forces inbound via Firewall and restricts direct internet.
* **IaC:** Terraform (azurerm) orchestrates everything.
* **Config Mgmt:** Ansible deploys Kubernetes manifests and verifies reachability.
* **CI/CD:** GitHub Actions workflow for `terraform plan/apply` and Ansible deploy.

---

## Repo Structure

```
azure-3tier-aks-agw-firewall/
├─ README.md
├─ .github/
│  └─ workflows/
│     └─ deploy.yml
├─ terraform/
│  ├─ providers.tf
│  ├─ versions.tf
│  ├─ variables.tf
│  ├─ outputs.tf
│  ├─ main.tf
│  └─ modules/
│     ├─ network/
│     │  ├─ main.tf
│     │  ├─ variables.tf
│     │  └─ outputs.tf
│     ├─ firewall/
│     │  ├─ main.tf
│     │  ├─ variables.tf
│     │  └─ outputs.tf
│     ├─ appgw/
│     │  ├─ main.tf
│     │  ├─ variables.tf
│     │  └─ outputs.tf
│     └─ aks/
│        ├─ main.tf
│        ├─ variables.tf
│        └─ outputs.tf
└─ ansible/
   ├─ requirements.yml
   ├─ inventory.ini
   ├─ group_vars/
   │  └─ all.yml
   ├─ playbooks/
   │  ├─ deploy_app.yml
   │  └─ verify_dns.yml
   └─ k8s/
      ├─ namespace.yaml
      ├─ deployment.yaml
      ├─ service.yaml
      └─ ingress.yaml
```

