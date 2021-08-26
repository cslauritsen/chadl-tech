---
title: Troubleshooting 404 Errors with Traefik Ingress with TLS
date: 2021-08-25T17:27:04-04:00
draft: false
---

## Errors and Traefik Ingress over HTTPS
When trying to setup this website, I wanted to use [Cert Manager](https://cert-manager.io) to 
handle the job of managing TLS certificates issued by [Let's Encrypt](https://letsencrypt.org).

The HTTP server always worked fine. For instance, running
```bash
curl http://chadl.tech/index.html
```

would show the HTML contents as expected.

However when I'd try the same thing over HTTPS, I kept getting a 404:

```bash
curl https://chadl.tech/index.html
404 Page Not Found
```

The "page" rendered by the failure was a little peculiar. My actual site was hosted by nginx, and I knew that this 404 wasn't coming from nginx. In fact, this made it perfectly clear that the request was not even making it the nginx container at all. It was being _dropped by the ingress (or something else)_ before being forwarded on to the application container.

### Missing Secret?
In the past, I saw this exact same behavior when the `Secret` object mentioned in the `Ingress` config was missing or misconfigured.
```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  tls:
  - hosts:
    - blog.example.com
    secretName: blog-prod-tls
  rules:
   ...
```

In the above example, if the secret `blog-prod-tls` didn't exist in the correct namespace, or didn't exist at all, Traefik would throw a 404 error when trying to access the site.

Alas, in my case, the secret was definitely there. It was correctly formatted and even had a valid certificate in it! [Cert Manager](https://cert-manager.io) did its job just fine. I was barking up the wrong tree.

### Traefik Configuration
I compared the broken cluster with another one that was working fine, and I noticed a very interesting discrepancy. The broker cluster was missing an arg that was present in the working cluster: 
*  `--entrypoints.websecure.http.tls=true`. 

So I did `kubectl edit deploy traefik -n kube-system` to fix it, and I added the following 2 lines to the `args:` section of the `traefik` container:

```yaml
        - --entrypoints.websecure.http.tls=true
        - --serversTransport.insecureSkipVerify=true
```

The first one fixed my 404 problem when accessing the site via https. The second one I like to use to prevent 500 internal server errors from happening if I don't have a valid, signed certificate when a backend service interfaces with the ingress over HTTPS.


