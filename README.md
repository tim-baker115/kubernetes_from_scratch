# Kubernetes from scratch
The aim of this repo will be to document my progress learning kubernetes. It will break down each of the challenges I've faced in a set of readme's.

## Goal
There will be a set of pods which will each have a predefined purpose. The ultimate goal is to use machine learning techniques (known ones, we're not breaking any new ground here!). To identify shares within the FTSE100 which should be bought, sold or held. 

I'll also use technologies which might not be necessary for a bit more expertise (e.g there's no benefit of installing itsio - but it looks cool).

Components and their purpose detailed below:

| Component | Purpose | Notes |
| --------- | ------- | ---|
| PosgresDB | Store stock exchange data | Requires persistent storage |
| Scraper | Retrieve FTSE data | Use yfinance initially |
| ML Model 1 | Linear regression | Python |
| ML Model 2 | XGBoost | Python |
| ML Model 3 | Black Scholes/GARCH | Python |
| Treasury | Simulates bank loans, considers risk and returns of the models | £100,000 limit |
| Prometheus | Graphing and trending | |
| Grafana | Cooler looking graphs | |
| ArgoCD | Simplification of the above | |

## Index
1. [Hardware](README/1.%20hardware.md)
2. [Operating system](README/2.%20operating%20system.md)
3. [Kubernetes prerequisites](README/3.%20kubernetes%20prerequisites.md)
4. [Kubernetes install](README/4.%20kubernetes%20install.md)
5. [Networking](README/5.%20networking.md)