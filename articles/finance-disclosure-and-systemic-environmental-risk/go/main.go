// Lightweight finance disclosure risk API in Go.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type RiskResponse struct {
	PortfolioName                  string  `json:"portfolio_name"`
	SystemicEnvironmentalRisk       float64 `json:"systemic_environmental_risk"`
	WeightedDisclosureAdequacy      float64 `json:"weighted_disclosure_adequacy"`
	WeightedTransitionCredibility   float64 `json:"weighted_transition_credibility"`
	HighestRiskDomain              string  `json:"highest_risk_domain"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	response := RiskResponse{
		PortfolioName:                "Illustrative Portfolio",
		SystemicEnvironmentalRisk:     1.42,
		WeightedDisclosureAdequacy:    0.61,
		WeightedTransitionCredibility: 0.49,
		HighestRiskDomain:            "climate",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/finance-boundary-risk", handler)

	log.Println("Finance disclosure risk API running at http://localhost:8080/finance-boundary-risk")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
