# VM Frontend Deployment with Bicep

This repository contains a generic, standardised Bicep template for deploying a front-end Virtual Machine (VM) workload in Azure.  
It was originally developed and used in a professional environment as a reusable script for each environment.

---

## Project Structure

infrastructure/
├── modules/
│   ├── keyvault.bicep         # Deploys an Azure Key Vault
│   ├── loadbalancer.bicep     # Deploys a Load Balancer and associated resources
│   ├── storage.bicep          # Deploys a Storage Account
│   └── vm.bicep               # Deploys a Virtual Machine
│
├── main.bicep                 # Root template – orchestrates all modules
├── dev.bicepparam             # Parameters for Development environment
├── stage.bicepparam           # Parameters for Staging environment
├── prod.bicepparam            # Parameters for Production environment
│
├── .gitignore                 # Git ignored files
└── README.md                  # Documentation (this file)