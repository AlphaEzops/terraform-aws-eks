{{- define "helpers.create-env-secrets"}}
{{- range .Values.secrets.secretDefinitions.data }}
- name: {{ .name }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.secrets.externalSecrets.name }}
      key: {{ .name }}
{{- end }}
{{- end }}
