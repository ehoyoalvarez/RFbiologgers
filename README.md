# Seabass Welfare Classification Using Biologger Data

This repository contains code to classify welfare states in European seabass (*Dicentrarchus labrax*) from biologger-derived physiological and behavioural data using a Random Forest model.

## Contents

- `scripts/`
  - `01_train_validate_RF.R` – Train and Validate the Random Forest model
  - `02_apply_model_dummy.R` – Apply the model to a dummy dataset
- `data/`
  - `labelled_data.xlsx` – Annotated biologger dataset for model development
  - `dummy_dataset.csv` – Simulated dataset for testing and reproducibility

## Workflow

1. **Train** the model on annotated biologger data (HR and ACC).  
2. **Validate** model performance using cross-validation.  
3. **Apply** the model to new data (dummy dataset provided for demonstration).

## Usage

1. Clone the repository:
  git clone https://github.com/yourusername/RFbiologgers.git

2. Set your R working directory to the repository folder.
  Run scripts in order: 01_train_validate_RF.R, 03_apply_model_dummy.R.

3. Inspect output metrics and predicted welfare states.

## Notes

- dummy_dataset.csv is for testing only and matches the structure of the original data.
- Original data are available from the corresponding author on reasonable request.
- Scripts are fully commented for reproducibility.

Correspondence: ehoyo@imedea.uib-csic.es

