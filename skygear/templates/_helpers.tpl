{{- define "skygear.skygear-server.name" }}
{{- printf "%s-skygear-server" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.skygear-server.master.name" }}
{{- printf "%s-skygear-server-master" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.skygear-server.slave.name" }}
{{- printf "%s-skygear-server-slave" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.secret.name" }}
{{- printf "%s-secret" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.pgbouncer.name" }}
{{- printf "%s-pgbouncer" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.staticasset.name" }}
{{- printf "%s-staticasset" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "skygear.skygear-server.service.ports" }}
- name: http
  protocol: TCP
  port: 80
  targetPort: http
{{- end }}

{{- define "skygear.skygear-server.ports" }}
- name: http
  protocol: TCP
  containerPort: 3000
{{- end }}

{{- define "skygear.env-vars" }}
- name: APP_NAME
  value: {{ .Values.appName | quote }}
- name: LOG_LEVEL
  value: {{ .Values.logLevel | quote }}
- name: DEV_MODE
  value: {{ .Values.devMode | quote }}
- name: SENTRY_DNS
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: SENTRY_DNS
- name: DB_IMPL_NAME
  value: "pq"
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: DATABASE_URL
- name: TOKEN_STORE
  value: "jwt"
- name: ASSET_STORE
  value: {{ .Values.assetStore.type | quote }}
{{- if .Values.assetStore.isPublic }}
- name: ASSET_STORE_PUBLIC
  value: "YES"
{{- else }}
- name: ASSET_STORE_PUBLIC
  value: "NO"
{{- end }}
{{- if (eq .Values.assetStore.type "cloud") }}
- name: CLOUD_ASSET_HOST
  value: {{ .Values.assetStore.cloud.host | quote }}
- name: CLOUD_ASSET_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: CLOUD_ASSET_TOKEN
- name: CLOUD_ASSET_PUBLIC_PREFIX
  value: {{ .Values.assetStore.cloud.publicPrefix | quote }}
- name: CLOUD_ASSET_PRIVATE_PREFIX
  value: {{ .Values.assetStore.cloud.privatePrefix | quote }}
{{- end }}
{{- if (eq .Values.assetStore.type "s3") }}
- name: ASSET_STORE_REGION
  value: {{ .Values.assetStore.s3.region | quote }}
- name: ASSET_STORE_BUCKET
  value: {{ .Values.assetStore.s3.bucket | quote }}
- name: ASSET_STORE_S3_URL_PREFIX
  value: {{ .Values.assetStore.s3.urlPrefix | quote }}
- name: ASSET_STORE_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: ASSET_STORE_ACCESS_KEY
- name: ASSET_STORE_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: ASSET_STORE_SECRET_KEY
{{- end }}
- name: SMTP_HOST
  value: "smtp.sendgrid.net"
- name: SMTP_PORT
  value: "587"
- name: SMTP_MODE
  value: "tls"
- name: SMTP_LOGIN
  value: "apikey"
- name: SMTP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: SMTP_PASSWORD
- name: HTTP
  value: "true"
- name: URL_PREFIX
  value: {{ .Values.urlPrefix }}
- name: DEIS_APP
  value: {{ .Values.appName | quote }}
- name: DEIS_RELEASE
  value: {{ .Values.deisRelease | quote }}
- name: API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: API_KEY
- name: MASTER_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: MASTER_KEY
- name: TOKEN_STORE_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: TOKEN_STORE_SECRET
- name: CUSTOM_TOKEN_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: CUSTOM_TOKEN_SECRET
- name: SEND_SMS
  value: "true"
{{- if .Values.cms.configFileURL }}
- name: CMS_CONFIG_FILE_URL
  value: {{ .Values.cms.configFileURL | quote }}
{{- end }}
{{- if .Values.gcm.enabled }}
- name: GCM_ENABLE
  value: "YES"
- name: GCM_APIKEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: GCM_APIKEY
{{- end }}
{{- if .Values.fcm.enabled }}
- name: FCM_ENABLE
  value: "YES"
{{- if .Values.fcm.serverKey }}
- name: FCM_TYPE
  value: server_key
- name: FCM_SERVER_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: FCM_SERVER_KEY
{{- end }}
{{- end }}
{{- if .Values.apns.enabled }}
- name: APNS_ENABLE
  value: "YES"
- name: APNS_ENV
  value: production
- name: APNS_TYPE
  value: {{ .Values.apns.type | quote }}
- name: APNS_TEAM_ID
  value: {{ .Values.apns.teamID | quote }}
{{- if (eq .Values.apns.type "certificate") }}
- name: APNS_CERTIFICATE
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: APNS_CERTIFICATE
- name: APNS_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: APNS_PRIVATE_KEY
{{- end }}
{{- if (eq .Values.apns.type "token") }}
- name: APNS_KEY_ID
  value: {{ .Values.apns.keyID }}
- name: APNS_TOKEN_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "skygear.secret.name" . | quote }}
      key: APNS_TOKEN_KEY
{{- end }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "skygear.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "skygear.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "skygear.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "skygear.labels" -}}
helm.sh/chart: {{ include "skygear.chart" . }}
{{ include "skygear.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "skygear.selectorLabels" -}}
app.kubernetes.io/name: {{ include "skygear.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
