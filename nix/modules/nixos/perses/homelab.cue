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
						width:   8
						height:  10
						content: {"$ref": "#/spec/panels/cpu"}
					},
					{
						x:       8
						y:       0
						width:   8
						height:  10
						content: {"$ref": "#/spec/panels/memory"}
					},
					{
						x:       16
						y:       0
						width:   8
						height:  10
						content: {"$ref": "#/spec/panels/temperature"}
					},
					{
						x:       0
						y:       10
						width:   8
						height:  10
						content: {"$ref": "#/spec/panels/poe"}
					},
					{
						x:       8
						y:       10
						width:   8
						height:  10
						content: {"$ref": "#/spec/panels/cost"}
					},
					{
						x:       16
						y:       10
						width:   8
						height:  10
						content: {"$ref": "#/spec/panels/costByPort"}
					},
					{
						x:       0
						y:       20
						width:   8
						height:  10
						content: {"$ref": "#/spec/panels/fx"}
					},
				]
			}

			panels: {
				// Percent on one axis for every source, so the fleet is comparable at a
				// glance. The three pis come from kula, the UNAS and both switches from
				// unpoller, which is the same split the temperature panel uses.
				cpu: {
					kind: "Panel"
					spec: {
						display: {
							name:        "CPU by host"
							description: "Everything in the caddy that reports it: the three pis via kula, the UNAS, and both switches. Switch values are 0-1 ratios scaled to percent; the UNAS is already a percent, and it really is that idle - it peaks around 0.3% where the pis reach 90%."
						}
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
										query:            "kula_cpu_usage_percent"
										seriesNameFormat: "{{host}}"
									}
								}
							},
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "unpoller_unas_cpu_load_percent"
										seriesNameFormat: "{{name}}"
									}
								}
							},
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "unpoller_device_cpu_utilization_ratio * 100"
										seriesNameFormat: "{{name}}"
									}
								}
							},
						]
					}
				}

				// Percent used rather than bytes: the sources disagree on units — kula
				// reports a percent, unpoller gives the UNAS a total and an available
				// figure labelled _bytes that are actually KB, and the switches a 0-1
				// ratio. Deriving a percentage from each makes the mislabelling moot.
				memory: {
					kind: "Panel"
					spec: {
						display: {
							name:        "Memory by host"
							description: "Percent used, so the sources stay comparable despite different units underneath - unpoller labels the UNAS figures _bytes but reports KB, which a ratio makes irrelevant. Switches sit high by design; they are appliances, not spare capacity."
						}
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
										query:            "kula_memory_used_percent"
										seriesNameFormat: "{{host}}"
									}
								}
							},
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "(1 - unpoller_unas_memory_available_bytes / unpoller_unas_memory_total_bytes) * 100"
										seriesNameFormat: "{{name}}"
									}
								}
							},
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "unpoller_device_memory_utilization_ratio * 100"
										seriesNameFormat: "{{name}}"
									}
								}
							},
						]
					}
				}

				// last_over_time, not a bare selector. One sample per day is far outside
				// Prometheus' 5m lookback, so `fx_rate` alone resolves to nothing for all
				// but five minutes of each day — in range queries as much as instant ones,
				// which renders an empty panel rather than an obviously broken one. 36h
				// rather than 24h so a weekend or a holiday does not open a gap.
				fx: {
					kind: "Panel"
					spec: {
						display: {
							name:        "GTQ per EUR"
							description: "GTQ per EUR, one sample per day because that is how often the rate exists. Derived rather than fetched: Banco de Guatemala for GTQ/USD divided by the ECB for EUR/USD, each forward-filled over its own weekends and holidays. Backfilled history only for now - the series stops at the day it was imported until the live exporter in DOTFILES-18 is enabled, and the 90d retention window trims the oldest day as it slides."
						}
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
										query:            "last_over_time(fx_rate{base=\"EUR\",quote=\"GTQ\"}[36h])"
										seriesNameFormat: "GTQ per EUR"
									}
								}
							},
						]
					}
				}

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
							// The series names come from the port names set on the switch
							// in the controller, so re-cabling is a rename there rather
							// than an edit here.
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

				// Costed from the recording rules rather than from a query expression here:
				// this file is built by `task perses-dashboards`, outside the nix evaluation,
				// so it cannot read the tariff from my.electricity. Referencing the recorded
				// series keeps the rate stated exactly once, in options.nix.
				cost: {
					kind: "Panel"
					spec: {
						display: {
							name:        "PoE cost, whole caddy (Q/month)"
							description: "The band is two independent unknowns, not an error bar. Lower takes the reported watts at the non-subsidised tariff; upper assumes the top consumption tier and adds the switch PSU and cable loss the port cannot see. Both rates live in nix/options.nix under my.electricity, and the arithmetic is a recording rule in modules/nixos/prometheus.nix. What this excludes, stated here because a number on a dashboard is believed: the switch reports PoE it delivers, not what the device consumes; neither switch's own draw is counted; and anything with its own PSU contributes nothing here and everything to the bill. So this is the cost of the PoE-powered part of the caddy, which is a smaller claim than the cost of the homelab."
						}
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
										query:            "homelab:poe_cost_gtq_per_month:low"
										seriesNameFormat: "lower bound"
									}
								}
							},
							{
								kind: "TimeSeriesQuery"
								spec: plugin: {
									kind: "PrometheusTimeSeriesQuery"
									spec: {
										query:            "homelab:poe_cost_gtq_per_month:high"
										seriesNameFormat: "upper bound"
									}
								}
							},
						]
					}
				}

				// Upper bound only. Per-port series at the upper factor sum to the `high`
				// line above exactly, which is the arithmetic check on both panels; a
				// midpoint would be a number nothing else agrees with. Port names come from
				// the controller, same as the draw panel.
				costByPort: {
					kind: "Panel"
					spec: {
						display: {
							name:        "PoE cost by port (Q/month, upper bound)"
							description: "Upper bound per port, so these sum to the upper bound above. What this excludes, stated here because a number on a dashboard is believed: the switch reports PoE it delivers, not what the device consumes; neither switch's own draw is counted; and anything with its own PSU contributes nothing here and everything to the bill. So this is the cost of the PoE-powered part of the caddy, which is a smaller claim than the cost of the homelab."
						}
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
										query:            "homelab:poe_cost_gtq_per_month:by_port"
										seriesNameFormat: "{{port_name}}"
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
