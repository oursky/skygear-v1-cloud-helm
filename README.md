# Skygear v1 cloud Helm Chart

This Helm chart is supposed to be used to migrate an app running on the Skygear Cloud.

Read the [values.yaml](./skygear/values.yaml) to see the configuration of this chart.

This chart does NOT include any ingress. You must define the ingress yourself.

# Recipes

Here are some common customization you want to make

## Define you ingress

Here is an example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress-1
  annotations:
    kubernetes.io/tls-acme: "true"
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
spec:
  tls:
  - secretName: web-tls
    hosts:
    - {{ .Values.skygear.appName }}.skygeario.com
  rules:
  - host: {{ .Values.skygear.appName }}.skygeario.com
    http:
      paths:
      - pathType: ImplementationSpecific
        path: /
        backend:
          service:
            name: {{ include "skygear.skygear-server.name" . | quote }}
            port:
              name: http
      - pathType: ImplementationSpecific
        path: /pubsub
        backend:
          service:
            name: {{ include "skygear.skygear-server.master.name" . | quote }}
            port:
              name: http
      - pathType: ImplementationSpecific
        path: /_pubsub
        backend:
          service:
            name: {{ include "skygear.skygear-server.master.name" . | quote }}
            port:
              name: http
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress-2
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/upstream-vhost: {{ .Values.skygear.staticAsset.host | quote }}
    nginx.ingress.kubernetes.io/rewrite-target: /{{ .Values.skygear.appName}}/{{ .Values.skygear.staticAsset.hash }}/static/$2
spec:
  tls:
  - secretName: web-tls
    hosts:
    - {{ .Values.skygear.appName }}.skygeario.com
  rules:
  - host: {{ .Values.skygear.appName }}.skygeario.com
    http:
      paths:
      - pathType: ImplementationSpecific
        path: /static(/|$)(.*)
        backend:
          service:
            name: {{ include "skygear.staticasset.name" . | quote }}
            port:
              number: 80
```
