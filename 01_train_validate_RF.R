# ===============================================
# Random Forest Model for Seabass Welfare States Classification
# Author: Esther Hoyo-Alvarez
# Date: 2026-01-12
# ===============================================

# Load libraries
library(readxl)
library(dplyr)
library(caret)
library(randomForest)
library(pROC)
library(MLmetrics)
library(ggplot2)
library(pheatmap)

# -------------------------------
# 0. Load and preprocess data
# -------------------------------
df <- read_excel("labelled_data.xlsx") # Annotated biologger dataset

df$id <- as.factor(df$id)
df$real_label <- as.factor(df$real_label)

# -------------------------------
# 1. Standardize variables by individual (Z-score)
# -------------------------------
df_std <- df %>%
  group_by(id) %>%
  mutate(
    hr_std = (hr - mean(hr, na.rm = TRUE)) / sd(hr, na.rm = TRUE),
    acc_std = (acc - mean(acc, na.rm = TRUE)) / sd(acc, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  na.omit()  # Remove rows with NA

# -------------------------------
# 2. Train-Test split (70%-30%) maintaining label proportion
# -------------------------------
set.seed(888)
train_index <- createDataPartition(df_std$real_label, p = 0.7, list = FALSE)

train_set <- df_std[train_index, ]
test_set <- df_std[-train_index, ]

# -------------------------------
# 3. Hyperparameter exploration (nodesize, class weights)
# -------------------------------
levels(train_set$real_label) <- make.names(levels(train_set$real_label))
levels(test_set$real_label) <- make.names(levels(test_set$real_label))

classwt_list <- list(
  c(1.6, 1.8, 1.8, 0.8),
  c(2.0, 2.0, 2.0, 0.6),
  c(1.5, 1.5, 1.5, 0.9),
  c(2.2, 1.8, 1.8, 0.5)
)
nodesize_list <- c(1, 2, 5)
mtry_grid <- expand.grid(mtry = 2)  # We keep both variables: HR & ACC

ctrl <- trainControl(method = "cv", number = 5, classProbs = TRUE,
                     summaryFunction = multiClassSummary)

results <- list()
i <- 1
for(cw in classwt_list){
  for(ns in nodesize_list){
    model <- train(
      real_label ~ hr_std + acc_std,
      data = train_set,
      method = "rf",
      trControl = ctrl,
      tuneGrid = mtry_grid,
      ntree = 500,
      metric = "Kappa",
      importance = TRUE,
      nodesize = ns,
      classwt = cw
    )
    results[[i]] <- list(model = model, classwt = cw, nodesize = ns)
    i <- i + 1
  }
}

# Compare models
kappas <- sapply(results, function(x) max(x$model$results$Kappa, na.rm = TRUE))
accuracies <- sapply(results, function(x) max(x$model$results$Accuracy, na.rm = TRUE))

best_kappa_model <- results[[which.max(kappas)]]
best_acc_model <- results[[which.max(accuracies)]]

# -------------------------------
# 4. Train final RF model (v8)
# -------------------------------
set.seed(888)
rf_v8 <- randomForest(
  real_label ~ hr_std + acc_std,
  data = train_set,
  ntree = 500,
  classwt = c(1.5, 1.5, 1.5, 0.9),
  mtry = 2,
  nodesize = 5,
  importance = TRUE
)

print(rf_v8)
plot(rf_v8)

# -------------------------------
# 5. Model validation
# -------------------------------
# Predictions on test set
test_predictions <- predict(rf_v8, newdata = test_set)

conf_matrix <- confusionMatrix(test_predictions, test_set$real_label)
print(conf_matrix)

cat("Accuracy: ", conf_matrix$overall["Accuracy"], "\n")
cat("F1-Score per class:\n")
print(conf_matrix$byClass[, "F1"])

# Variable importance
importance_rf <- varImp(rf_v8, scale = TRUE)
print(importance_rf)
varImpPlot(rf_v8)

# Normalized confusion matrix heatmap
norm_conf_matrix <- prop.table(conf_matrix$table, margin = 1)
pheatmap(norm_conf_matrix, cluster_rows = FALSE, cluster_cols = FALSE, 
         color = colorRampPalette(c("white", "blue"))(50),
         main = "Normalized Confusion Matrix")

# Multiclass ROC and AUC
roc_curves <- multiclass.roc(test_set$real_label, as.numeric(test_predictions))
auc_values <- sapply(roc_curves$rocs, function(roc) auc(roc))
cat("AUC per class:\n")
print(auc_values)

# -------------------------------
# 6. Cross-validation (20-fold)
# -------------------------------
cv_control <- trainControl(method = "cv", number = 20)
set.seed(888)
cv_model <- train(
  real_label ~ hr_std + acc_std,
  data = train_set,
  method = "rf",
  trControl = cv_control,
  tuneLength = 3
)
print(cv_model)
                     
# -------------------------------
# 7. Scatter plot of predicted states
# -------------------------------
test_set$rf_pred <- predictions
ggplot(test_set, aes(x = hr_std, y = acc_std, color = rf_pred)) +
  geom_point(alpha = 0.7, size = 3) +
  labs(title = "RF Predictions on Test Set",
       x = "Standardized HR", y = "Standardized ACC", color = "Predicted State") +
  theme_minimal()
