# Vagrant Kubernetes HA Cluster
This project is a Vagrant based project which creates a K8s HA cluster.

## Details
When running the command `sudo vagrant up`, this will create:
- 1 load balancer (haproxy)
- 2 masters
- 2 nodes

The network is currently using *weave* and is doing a small hack in order to select the proper NIC under Vagrant. Basically an `ip route` route is added during the provisionning.

## How to install
```bash
sudo vagrant up
```

The reason why we need a sudo is simple, we create a load balancer that will use the host OS ports *443* and *80*. This will allow the ingress/services to work using the host OS ip.

## Ingress-Nginx
If you want to put your certificates "for fun" using let's encrypt "the hard way". 

```bash
sudo apt-update
sudo apt-get install letsencrypt
sudo certbot certonly --manual --preferred-challenges=dns --email you@yourdomain.com --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d *.yourdomain.com,yourdomain.com
```

1. Now go edit your configuration at your provider for the acme TXT DNS challenge
2. Wait until you see your TXT record updated on let's say https://mxtoolbox.com/SuperTool.aspx
3. Then complete the challenge

You will have the following files in the folder given within the output:
* cert.pem **Important**
* chain.pem
* fullchain.pem
* privkey.pem **Important**
* README

Once this is done, connect to your k8s-master-1 (if not already done) and then create the secret:

```bash
kubectl create secret tls yourdomain-tls-secret --cert=cert.pem --key=privkey.pem -n nginx-ingress
kubectl edit daemonset nginx-ingress -n nginx-ingress
```

In the edit, add/replace the following configuration:

```yaml
...
      - args:
        - -nginx-configmaps=$(POD_NAMESPACE)/nginx-config
        - -default-server-tls-secret=$(POD_NAMESPACE)/yourdomain-tls-secret
        - -wildcard-tls-secret=$(POD_NAMESPACE)/yourdomain-tls-secret
...
```

Now you can test your wildcard certificate by creating an nginx pod/service/ingress:

```bash
kubectl run nx-test --image nginx --replicas=2
kubectl expose deployment nx-test --port 80
kubectl create ns test
cat <<EOF | kubectl apply -n test -f -
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: nx.yourdomain.com
    http:
      paths:
      - backend:
          serviceName: nx
          servicePort: 80
        path: /
  tls:
  - hosts:
    - nx.yourdomain.com
EOF
```

Now, if you browse to your *https://nx.yourdomain.com* it should be working in HTTPS with a green "lock" for a valid certificate.

## Futur part in the project
1. I would like to make the `Vagrantfile` more configurable. Which mean, you could select the network by adding some option when running the vagrant file. This will allow to use either let's say `weave`, `flannel` or `calico`.
