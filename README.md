# Seabass Welfare Classification Using Biologger Data

This repository contains code to classify welfare states in European seabass (*Dicentrarchus labrax*) from biologger-derived physiological and behavioural data using a Random Forest (RF) model.

## Contents

- `scripts/`
  - `01_train_validate_RF.R` – Train, explore hyperparameters, and validate the RF model. 
  - `02_apply_model_dummy.R` – Apply the pre-trained RF model to a dummy dataset for demonstration.
- `data/`
  - `labelled_data.xlsx` – Annotated biologger dataset for model development.
  - `dummy_dataset.csv` – Simulated dataset matching the original structure for testing and reproducibility.

## Workflow

1. **Train** the RF model on annotated HR and ACC data.  
2. **Validate** model performance using cross-validation and test set metrics (accuracy, F1, ROC-AUC).  
3. **Save** the trained model as `rf_model_v8.rds` (optional; users can create it themselves).  
4. **Apply** the model to new data (dummy dataset provided for reproducibility and demonstration).

## Usage

1. Clone the repository:
  git clone https://github.com/yourusername/RFbiologgers.git

2. Set your R working directory to the repository folder.
   
3. Run scripts in order:
    source("scripts/01_train_validate_RF.R")  # Train and validate model
    source("scripts/02_apply_RF_dummy.R")     # Apply model to dummy dataset
   
4. Inspect output metrics, variable importance, confusion matrices, and predicted welfare states.

## Notes

- dummy_dataset.csv is for demonstration only and simulates the structure of new HR and ACC observations.
- Original data are available from the corresponding author on reasonable request.
- All scripts are fully commented for reproducibility.

*Correspondence*: ehoyo@imedea.uib-csic.es

