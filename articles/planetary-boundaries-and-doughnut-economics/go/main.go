// Lightweight Doughnut diagnostic API scaffold in Go.

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type ScoreResponse struct {
	Entity                   string  `json:"entity"`
	MeanEcologicalOvershoot float64 `json:"mean_ecological_overshoot"`
	MeanSocialShortfall     float64 `json:"mean_social_shortfall"`
	SafeAndJustScore        float64 `json:"safe_and_just_score"`
	DoughnutPosition        string  `json:"doughnut_position"`
}

func scoreHandler(w http.ResponseWriter, r *http.Request) {
	response := ScoreResponse{
		Entity:                   "Region A",
		MeanEcologicalOvershoot: 0.25,
		MeanSocialShortfall:     0.12,
		SafeAndJustScore:        0.815,
		DoughnutPosition:        "Both ecological overshoot and social shortfall",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/score", scoreHandler)

	log.Println("Doughnut diagnostic API running at http://localhost:8080/score")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
