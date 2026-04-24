// Lightweight critique-risk diagnostic API in Go.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type DomainScore struct {
	Domain string  `json:"domain"`
	Score  float64 `json:"score"`
}

type CritiqueRiskResponse struct {
	CaseName          string        `json:"case_name"`
	TotalCritiqueRisk float64       `json:"total_critique_risk"`
	RiskClass         string        `json:"risk_class"`
	DomainScores      []DomainScore `json:"domain_scores"`
}

func handler(w http.ResponseWriter, r *http.Request) {
	response := CritiqueRiskResponse{
		CaseName:          "Global aggregate dashboard",
		TotalCritiqueRisk: 0.75,
		RiskClass:         "high",
		DomainScores: []DomainScore{
			{Domain: "biophysical", Score: 0.85},
			{Domain: "justice", Score: 0.72},
			{Domain: "legitimacy", Score: 0.76},
			{Domain: "political_economy", Score: 0.82},
			{Domain: "operationalization", Score: 0.60},
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/critique-risk", handler)

	log.Println("Critique-risk API running at http://localhost:8080/critique-risk")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
