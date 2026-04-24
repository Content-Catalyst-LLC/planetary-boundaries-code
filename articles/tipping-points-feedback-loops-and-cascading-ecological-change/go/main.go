// Lightweight tipping-risk diagnostic API in Go.

package main

import (
	"encoding/json"
	"log"
	"math"
	"net/http"
)

type TippingRiskResponse struct {
	Element              string  `json:"element"`
	PressureRatio        float64 `json:"pressure_ratio"`
	CascadePressure      float64 `json:"cascade_pressure"`
	TippingProbability   float64 `json:"tipping_probability"`
	CascadeAdjustedRisk  float64 `json:"cascade_adjusted_risk"`
	RiskClass            string  `json:"risk_class"`
}

func logistic(value float64) float64 {
	return 1.0 / (1.0 + math.Exp(-value))
}

func handler(w http.ResponseWriter, r *http.Request) {
	pressureRatio := 1.55
	cascadePressure := 0.30
	feedbackStrength := 0.76
	resilienceCapacity := 0.36
	monitoringGap := 0.44

	tippingProbability := logistic(
		1.8*(pressureRatio-1.0) +
			1.2*cascadePressure +
			0.8*feedbackStrength -
			0.9*resilienceCapacity,
	)

	risk := tippingProbability * (1.0 + cascadePressure) * (1.0 + monitoringGap)

	response := TippingRiskResponse{
		Element:             "amazon_rainforest",
		PressureRatio:       pressureRatio,
		CascadePressure:     cascadePressure,
		TippingProbability:  tippingProbability,
		CascadeAdjustedRisk: risk,
		RiskClass:           "high_risk",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/tipping-risk", handler)

	log.Println("Tipping-risk API running at http://localhost:8080/tipping-risk")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
