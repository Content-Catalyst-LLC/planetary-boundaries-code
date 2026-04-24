// Lightweight Earth system resilience diagnostic API in Go.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type ResilienceResponse struct {
	Boundary                 string  `json:"boundary"`
	PressureRatio            float64 `json:"pressure_ratio"`
	ResilienceCapacity       float64 `json:"resilience_capacity"`
	ResilienceGap            float64 `json:"resilience_gap"`
	InteractionPressure      float64 `json:"interaction_pressure"`
	ResilienceAdjustedRisk   float64 `json:"resilience_adjusted_risk"`
	RiskClass                string  `json:"risk_class"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	response := ResilienceResponse{
		Boundary:               "biosphere_integrity",
		PressureRatio:          1.70,
		ResilienceCapacity:     0.37,
		ResilienceGap:          0.63,
		InteractionPressure:    1.20,
		ResilienceAdjustedRisk: 2.36,
		RiskClass:              "high_risk",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/earth-system-resilience", handler)

	log.Println("Earth system resilience API running at http://localhost:8080/earth-system-resilience")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
