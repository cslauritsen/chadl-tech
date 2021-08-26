---
title: Troubleshooting Internal Server (HTTP 5xx) Errors with Traefik Ingress 
date: 2021-08-25T17:27:04-04:00
draft: false
---

Troubleshooting the Traefik ingress controller can leave you scratching your pate. Errors bubble up, but Traefik is completely mum about what's gone wrong (logs are terse or non-existent by default.) 

## Internal Server Error
This one I found happens whenever your ingress wants to access a backend service that is itself protected by TLS self-signed certificate. I.e., you didn't bother to acquire, nor sign up to maintain a CA-signed cert for this backend service. 

Seriously, who wants to do that?  Wouldn't it be good if Traefik would just implicitly trust any services we've deployed to the cluster? Your opinion may be different, but it's my cluster and I don't want to bother with getting a cert to guarantee the internal ClusterIP traffic.

Turns out the solution isn't too bad, but it does require editing the traefik configuration:


```bash
kubectl -n kube-system edit deployment traefik
```

Then, scroll down to the `args` list and you can add a new command-line argument to the `traefik` container:
```yaml
        - --serversTransport.insecureSkipVerify=true
```

This will tell Traefik to ignore self-signed certificate errors on backend services protected by TLS. 

# Adapting for k3s
The above steps solved my problem, but I wanted to know how I could better automate the inclusion of this whenever I build a new [k3s](https://k3s.io) cluster. After all, in my work, I'm going to be creating a crapload of k3s clusters and I don't want to hand-edit each one to fix this issue. 

Turns out, k3s deploys Traefik using a Helm chart. To address such issues surrounding Helm chart configuration, K3s also offers a `HelmChartConfig` addon that can be used to inject arguments into the `traefik` deployment.

```bash
cat /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
```

```yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    additionalArguments:
      - --serversTransport.insecureSkipVerify=true
```

Drop a `.yaml` file containing those contents into the `/var/lib/rancher/k3s/server/manifests`
directory, and voilà, when the traefik pod starts, it will have added your amendment to its `args:` list.

Problem solved.

