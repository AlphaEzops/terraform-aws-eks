{{- define "helpers.configmap-list-env-variables"}}
{{- range $key, $val := .Values.env }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $.Values.configMap.name }}
      key: {{ $key }}
{{- end}}
{{- end }}