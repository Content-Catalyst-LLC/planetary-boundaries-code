// Doughnut diagnostic API in Go.
//
// This service exposes a simple JSON endpoint that represents how a
// Doughnut diagnostic score could be served to dashboards or clients.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type IndicatorScore struct {
	Indicator string  `json:"indicator"`
	Domain    string  `json:"domain"`
	Observed  float64 `json:"observed"`
	Threshold float64 `json:"threshold"`
	Penalty   float64 `json:"penalty"`
}

type DiagnosticResponse struct {
	Entity                   string           `json:"entity"`
	WeightedEcologicalScore float64          `json:"weighted_ecological_overshoot"`
	WeightedSocialScore     float64          `json:"weighted_social_shortfall"`
	SafeAndJustScore        float64          `json:"safe_and_just_score"`
	DiagnosticClass         string           `json:"diagnostic_class"`
	Indicators              []IndicatorScore `json:"indicators"`
}

func ceilingPenalty(observed float64, threshold float64) float64 {
	if observed > threshold {
		return (observed - threshold) / threshold
	}
	return 0
}

func floorPenalty(observed float64, threshold float64) float64 {
	if observed < threshold {
		return (threshold - observed) / threshold
	}
	return 0
}

func diagnosticHandler(w http.ResponseWriter, r *http.Request) {
	indicators := []IndicatorScore{
		{
			Indicator: "co2_per_capita",
			Domain:    "ecological",
			Observed:  9.8,
			Threshold: 3.0,
			Penalty:   ceilingPenalty(9.8, 3.0),
		},
		{
			Indicator: "basic_health_access",
			Domain:    "social",
			Observed:  0.82,
			Threshold: 0.90,
			Penalty:   floorPenalty(0.82, 0.90),
		},
	}

	response := DiagnosticResponse{
		Entity:                   "Region B",
		WeightedEcologicalScore: 0.85,
		WeightedSocialScore:     0.11,
		SafeAndJustScore:        0.52,
		DiagnosticClass:         "both_overshoot_and_shortfall",
		Indicators:              indicators,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/diagnostic", diagnosticHandler)

	log.Println("Doughnut diagnostic API running at http://localhost:8080/diagnostic")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
