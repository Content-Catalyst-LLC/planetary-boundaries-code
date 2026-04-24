// Lightweight land-system-change diagnostic API in Go.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type LandSystemRiskResponse struct {
	Biome                  string  `json:"biome"`
	ForestBoundaryPressure float64 `json:"forest_boundary_pressure"`
	BiomeIntegrityIndex    float64 `json:"biome_integrity_index"`
	RegulatoryImportance   float64 `json:"regulatory_importance"`
	LandSystemPressure     float64 `json:"land_system_pressure"`
	LandSystemRiskScore    float64 `json:"land_system_risk_score"`
	RiskClass              string  `json:"risk_class"`
	Priority               string  `json:"priority"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	response := LandSystemRiskResponse{
		Biome:                  "tropical_forest_frontier",
		ForestBoundaryPressure: 1.181,
		BiomeIntegrityIndex:    0.134,
		RegulatoryImportance:   0.940,
		LandSystemPressure:     0.767,
		LandSystemRiskScore:    0.953,
		RiskClass:              "moderate_risk",
		Priority:               "forest_boundary_recovery_priority",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/land-system-risk", handler)

	log.Println("Land-system-change API running at http://localhost:8080/land-system-risk")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
