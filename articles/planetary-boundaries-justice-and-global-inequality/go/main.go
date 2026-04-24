// Lightweight planetary justice diagnostic API in Go.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type JusticeResponse struct {
	Group                     string  `json:"group"`
	EcologicalOveruse         float64 `json:"ecological_overuse"`
	MinimumAccessShortfall    float64 `json:"minimum_access_shortfall"`
	Vulnerability             float64 `json:"vulnerability"`
	PlanetaryJusticeGap       float64 `json:"planetary_justice_gap"`
	ResponsibilityAdjustedGap float64 `json:"responsibility_adjusted_gap"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	response := JusticeResponse{
		Group:                     "High-income high-consuming",
		EcologicalOveruse:         1.40,
		MinimumAccessShortfall:    0.00,
		Vulnerability:             0.22,
		PlanetaryJusticeGap:       0.54,
		ResponsibilityAdjustedGap: 1.89,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/planetary-justice", handler)

	log.Println("Planetary justice API running at http://localhost:8080/planetary-justice")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
