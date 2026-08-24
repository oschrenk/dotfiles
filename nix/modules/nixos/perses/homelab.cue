package dac

import (
	"github.com/perses/perses/cue/dac-utils/dashboard"
)

// Panels sit in a single untitled layout rather than in named groups. Perses has no
// concept of a panel outside a layout — spec.layouts is what places them — but
// GridLayoutSpec.display is optional, and omitting it renders the panels without a
// group header. The panelgroup dac-util is not used here because it requires a #title
// and would therefore always draw one.
dashboard & {
	#name:    "homelab"
	#project: "homelab"
	#display: name: "Homelab"
	#duration: "1d"

	#panelGroups: {
		"0": {
			layout: {
				kind: "Grid"
				spec: items: [
					{
						x:       0
						y:       0
						width:   24
						height:  12
						content: {"$ref": "#/spec/panels/temperature"}
					},
					{
						x:       0
						y:       12
						width:   24
						height:  10
						content: {"$ref": "#/spec/panels/poe"}
					},
				]
			}

			panels: {
				temperature: {
					kind: "Panel"
					spec: {
						display: name: "Temperature by host"
						plugin: {
							kind: "TimeSeriesChart"
							spec: {}
						}
						queries: [
							// The three pis, labelled by host by kula itself.
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "kula_cpu_temperature_celsius"
										seriesNameFormat: "{{host}} cpu"
									}
								}
							},
							// The UNAS, via unpoller. Its CPU runs ~20 C hotter than the
							// pis and is the hottest thing in the caddy.
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "unpoller_unas_cpu_temperature_celsius"
										seriesNameFormat: "{{name}} cpu"
									}
								}
							},
							// Both drives, by bay. These are what the UNAS fan PID targets.
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "unpoller_unas_disk_temperature_celsius"
										seriesNameFormat: "{{name}} disk {{slot_id}}"
									}
								}
							},
						]
					}
				}

				poe: {
					kind: "Panel"
					spec: {
						display: name: "PoE draw by port"
						plugin: {
							kind: "TimeSeriesChart"
							spec: {}
						}
						queries: [
							// Only the 8-port switch supplies PoE; the 5-port draws none.
							// Ports are unnamed in the controller, so the series are
							// "Port N" until they are labelled there.
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "unpoller_device_port_poe_watts > 0"
										seriesNameFormat: "{{port_name}}"
									}
								}
							},
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "sum(unpoller_device_port_poe_watts)"
										seriesNameFormat: "total"
									}
								}
							},
						]
					}
				}
			}
		}
	}
}
