{{- define "helm-chart.fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}