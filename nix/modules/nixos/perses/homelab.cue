package dac

import (
	"github.com/perses/perses/cue/dac-utils/dashboard"
	"github.com/perses/perses/cue/dac-utils/panelgroup"
)

dashboard & {
	#name:    "homelab"
	#project: "homelab"
	#display: name: "Homelab"
	#duration: "1d"

	#panelGroups: {
		"0": panelgroup & {
			#title:      "CPU temperature"
			#cols:       1
			#height:     12
			#groupIndex: 0
			#panels: [
				{
					kind: "Panel"
					spec: {
						display: name: "CPU temperature by host"
						plugin: {
							kind: "TimeSeriesChart"
							spec: {}
						}
						queries: [
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "kula_cpu_temperature_celsius"
										seriesNameFormat: "{{host}}"
									}
								}
							},
						]
					}
				},
			]
		}
	}
}
