// Lightweight regional aerosol-risk diagnostic API in Go.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type AerosolRiskResponse struct {
	Region                       string  `json:"region"`
	AODPressureRatio              float64 `json:"aod_pressure_ratio"`
	HealthExposureScore           float64 `json:"health_exposure_score"`
	ClimateHydrologyScore         float64 `json:"climate_hydrology_score"`
	GovernanceGap                 float64 `json:"governance_gap"`
	RegionalPlanetaryRiskScore    float64 `json:"regional_planetary_risk_score"`
	RiskClass                     string  `json:"risk_class"`
	DominantDriver                string  `json:"dominant_driver"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	response := AerosolRiskResponse{
		Region:                    "south_asia_monsoon_region",
		AODPressureRatio:           1.68,
		HealthExposureScore:        0.617,
		ClimateHydrologyScore:      2.55,
		GovernanceGap:              0.58,
		RegionalPlanetaryRiskScore: 2.42,
		RiskClass:                  "high_risk",
		DominantDriver:             "mixed_aerosol_climate_risk",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/regional-aerosol-risk", handler)

	log.Println("Regional aerosol-risk API running at http://localhost:8080/regional-aerosol-risk")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
