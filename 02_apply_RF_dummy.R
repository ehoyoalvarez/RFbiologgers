# 02_apply_RF_dummy.R
# ---------------------------------------------------------------
# Example script to apply the pre-trained Random Forest model
# (rf_model_v8) to a new dataset.
# This demonstrates how to use the model for prediction.
# ---------------------------------------------------------------

# Load necessary libraries
library(randomForest)
library(dplyr)

# ---------------------------
# 0. Note: ensure rf_model_v8.rds exists by running 01_train_validate_RF.R
# ---------------------------

# ---------------------------
# 1. Load the pre-trained model
# ---------------------------
# Replace the path with the location of your saved model
rf_model <- readRDS("rf_model_v8.rds")

# ---------------------------
# 2. Create a dummy dataset
# ---------------------------
# This simulates new standardized HR and ACC data
set.seed(123)
dummy_data <- data.frame(
  id = factor(rep(1:5, each = 10)),      # 5 individuals, 10 observations each
  hr_std = rnorm(50, mean = 0, sd = 1),  # standardized heart rate
  acc_std = rnorm(50, mean = 0, sd = 1)  # standardized external acceleration
)

# View first rows
head(dummy_data)

# ---------------------------
# 3. Apply the Random Forest model
# ---------------------------
dummy_predictions <- predict(rf_model, newdata = dummy_data)

# Add predictions to the dataset
dummy_data$predicted_state <- dummy_predictions

# ---------------------------
# 4. Summary of predictions
# ---------------------------
cat("Predicted states for the dummy dataset:\n")
print(table(dummy_data$predicted_state))

# Optional: visualize predictions
library(ggplot2)
ggplot(dummy_data, aes(x = hr_std, y = acc_std, color = predicted_state)) +
  geom_point(size = 3, alpha = 0.7) +
  labs(
    title = "Random Forest Predictions on Dummy Dataset",
    x = "Standardized HR",
    y = "Standardized ACC",
    color = "Predicted State"
  ) +
  theme_minimal()
