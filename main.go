package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type ApiResponse struct {
	Code    uint32
	Message string
}

func main() {
	router := http.NewServeMux()

	router.HandleFunc("/", (func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(&ApiResponse{Code: http.StatusOK, Message: "Hello World, Docker Production Setup !"})
	}))

	err := http.ListenAndServe(":3000", router)
	if err != nil {
		log.Fatal(err)
	}
}
