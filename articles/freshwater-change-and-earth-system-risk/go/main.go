// Lightweight freshwater-change diagnostic API in Go.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type FreshwaterRiskResponse struct {
	Region                         string  `json:"region"`
	BlueWaterDeviation             float64 `json:"blue_water_deviation"`
	GreenWaterDeviation            float64 `json:"green_water_deviation"`
	HydrologicalBoundaryPressure   float64 `json:"hydrological_boundary_pressure"`
	FreshwaterSystemRiskScore      float64 `json:"freshwater_system_risk_score"`
	RiskClass                      string  `json:"risk_class"`
	Priority                       string  `json:"priority"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	response := FreshwaterRiskResponse{
		Region:                       "semi_arid_irrigation_basin",
		BlueWaterDeviation:           -0.32,
		GreenWaterDeviation:          -0.38,
		HydrologicalBoundaryPressure: 0.445,
		FreshwaterSystemRiskScore:    0.610,
		RiskClass:                    "moderate_risk",
		Priority:                     "groundwater_depletion_priority",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/freshwater-change-risk", handler)

	log.Println("Freshwater-change API running at http://localhost:8080/freshwater-change-risk")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
