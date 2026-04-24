// Lightweight planetary-boundary diagnostic API in Go.

package main

import (
	"encoding/json"
	"log"
	"math"
	"net/http"
)

type PlanetaryBoundaryResponse struct {
	Boundary                 string  `json:"boundary"`
	BoundaryPressureRatio    float64 `json:"boundary_pressure_ratio"`
	UncertaintyMargin        float64 `json:"uncertainty_margin"`
	ThresholdRiskScore       float64 `json:"threshold_risk_score"`
	SystemicBoundaryRisk      float64 `json:"systemic_boundary_risk"`
	RiskZone                 string  `json:"risk_zone"`
	ResponseUrgency          string  `json:"response_urgency"`
}

func logisticRisk(pressureRatio float64, steepness float64) float64 {
	return 1.0 / (1.0 + math.Exp(-steepness*(pressureRatio-1.0)))
}

func handler(w http.ResponseWriter, r *http.Request) {
	observed := 1.75
	boundary := 1.00
	uncertainty := 0.18
	pressureRatio := observed / boundary
	thresholdRisk := logisticRisk(pressureRatio, 8.0)

	response := PlanetaryBoundaryResponse{
		Boundary:              "biosphere_integrity",
		BoundaryPressureRatio: pressureRatio,
		UncertaintyMargin:     (boundary - observed) / uncertainty,
		ThresholdRiskScore:    thresholdRisk,
		SystemicBoundaryRisk:  2.68,
		RiskZone:              "high_risk_zone",
		ResponseUrgency:       "immediate_systemic_response",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/planetary-boundary-risk", handler)

	log.Println("Planetary-boundary API running at http://localhost:8080/planetary-boundary-risk")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
