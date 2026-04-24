// Lightweight biogeochemical-flow diagnostic API in Go.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type NutrientRiskResponse struct {
	Region                     string  `json:"region"`
	NitrogenUseEfficiency       float64 `json:"nitrogen_use_efficiency"`
	PhosphorusUseEfficiency     float64 `json:"phosphorus_use_efficiency"`
	NitrogenBoundaryPressure    float64 `json:"nitrogen_boundary_pressure"`
	PhosphorusBoundaryPressure  float64 `json:"phosphorus_boundary_pressure"`
	EutrophicationPressure      float64 `json:"eutrophication_pressure"`
	PlanetaryNutrientRiskScore  float64 `json:"planetary_nutrient_risk_score"`
	RiskClass                   string  `json:"risk_class"`
	Priority                    string  `json:"priority"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	response := NutrientRiskResponse{
		Region:                    "coastal_dead_zone_drainage",
		NitrogenUseEfficiency:      0.551,
		PhosphorusUseEfficiency:    0.443,
		NitrogenBoundaryPressure:   1.56,
		PhosphorusBoundaryPressure: 1.40,
		EutrophicationPressure:     1.20,
		PlanetaryNutrientRiskScore: 2.45,
		RiskClass:                  "severe_risk",
		Priority:                   "phosphorus_loss_and_recovery_priority",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/biogeochemical-flow-risk", handler)

	log.Println("Biogeochemical-flow API running at http://localhost:8080/biogeochemical-flow-risk")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
