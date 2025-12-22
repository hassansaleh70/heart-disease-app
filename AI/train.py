"""
Heart Disease Prediction - Model Training Script
This script loads the heart disease dataset, preprocesses it, trains multiple models,
performs hyperparameter tuning, and saves the best model.
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
from sklearn.metrics import confusion_matrix, roc_curve
import xgboost as xgb
import joblib
import warnings
warnings.filterwarnings('ignore')

def load_and_preprocess_data(filepath='heart.csv'):
    """
    Load and preprocess the heart disease dataset.
    
    Args:
        filepath: Path to the CSV file
    
    Returns:
        X_train, X_test, y_train, y_test, scaler, feature_names
    """
    print("=" * 60)
    print("STEP 1: Loading and Preprocessing Data")
    print("=" * 60)
    
    # Load dataset
    df = pd.read_csv(filepath)
    print(f"✓ Dataset loaded successfully: {df.shape[0]} rows, {df.shape[1]} columns")
    
    # Check for missing values
    missing = df.isnull().sum().sum()
    if missing > 0:
        print(f"⚠ Found {missing} missing values. Filling with median...")
        df = df.fillna(df.median())
    else:
        print("✓ No missing values found")
    
    # Separate features and target
    X = df.drop('target', axis=1)
    y = df['target']
    feature_names = X.columns.tolist()
    
    print(f"✓ Features: {len(feature_names)}")
    print(f"✓ Target distribution: Class 0: {(y==0).sum()}, Class 1: {(y==1).sum()}")
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    print(f"✓ Train set: {X_train.shape[0]} samples")
    print(f"✓ Test set: {X_test.shape[0]} samples")
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    print("✓ Features scaled using StandardScaler\n")
    
    return X_train_scaled, X_test_scaled, y_train, y_test, scaler, feature_names

def evaluate_model(model, X_test, y_test, model_name):
    """
    Evaluate a trained model and return metrics.
    
    Args:
        model: Trained model
        X_test: Test features
        y_test: Test labels
        model_name: Name of the model
    
    Returns:
        Dictionary of evaluation metrics
    """
    y_pred = model.predict(X_test)
    y_pred_proba = model.predict_proba(X_test)[:, 1]
    
    metrics = {
        'Model': model_name,
        'Accuracy': accuracy_score(y_test, y_pred),
        'Precision': precision_score(y_test, y_pred),
        'Recall': recall_score(y_test, y_pred),
        'F1 Score': f1_score(y_test, y_pred),
        'ROC AUC': roc_auc_score(y_test, y_pred_proba)
    }
    
    return metrics

def train_logistic_regression(X_train, y_train, X_test, y_test):
    """Train Logistic Regression with hyperparameter tuning."""
    print("Training Logistic Regression...")
    
    param_dist = {
        'C': [0.001, 0.01, 0.1, 1, 10, 100],
        'penalty': ['l2'],
        'solver': ['lbfgs', 'liblinear'],
        'max_iter': [1000]
    }
    
    lr = LogisticRegression(random_state=42)
    random_search = RandomizedSearchCV(
        lr, param_dist, n_iter=10, cv=5, 
        scoring='roc_auc', random_state=42, n_jobs=-1
    )
    random_search.fit(X_train, y_train)
    
    best_model = random_search.best_estimator_
    print(f"  Best params: {random_search.best_params_}")
    
    metrics = evaluate_model(best_model, X_test, y_test, 'Logistic Regression')
    return best_model, metrics

def train_random_forest(X_train, y_train, X_test, y_test):
    """Train Random Forest with hyperparameter tuning."""
    print("Training Random Forest...")
    
    param_dist = {
        'n_estimators': [50, 100, 200],
        'max_depth': [5, 10, 15, None],
        'min_samples_split': [2, 5, 10],
        'min_samples_leaf': [1, 2, 4],
        'max_features': ['sqrt', 'log2']
    }
    
    rf = RandomForestClassifier(random_state=42)
    random_search = RandomizedSearchCV(
        rf, param_dist, n_iter=20, cv=5, 
        scoring='roc_auc', random_state=42, n_jobs=-1
    )
    random_search.fit(X_train, y_train)
    
    best_model = random_search.best_estimator_
    print(f"  Best params: {random_search.best_params_}")
    
    metrics = evaluate_model(best_model, X_test, y_test, 'Random Forest')
    return best_model, metrics

def train_xgboost(X_train, y_train, X_test, y_test):
    """Train XGBoost with hyperparameter tuning."""
    print("Training XGBoost...")
    
    param_dist = {
        'n_estimators': [50, 100, 200],
        'max_depth': [3, 5, 7, 9],
        'learning_rate': [0.01, 0.05, 0.1, 0.2],
        'subsample': [0.7, 0.8, 0.9, 1.0],
        'colsample_bytree': [0.7, 0.8, 0.9, 1.0]
    }
    
    xgb_model = xgb.XGBClassifier(random_state=42, eval_metric='logloss')
    random_search = RandomizedSearchCV(
        xgb_model, param_dist, n_iter=20, cv=5, 
        scoring='roc_auc', random_state=42, n_jobs=-1
    )
    random_search.fit(X_train, y_train)
    
    best_model = random_search.best_estimator_
    print(f"  Best params: {random_search.best_params_}")
    
    metrics = evaluate_model(best_model, X_test, y_test, 'XGBoost')
    return best_model, metrics

def main():
    """Main training pipeline."""
    print("\n" + "=" * 60)
    print("HEART DISEASE PREDICTION - MODEL TRAINING")
    print("=" * 60 + "\n")
    
    # Load and preprocess data
    X_train, X_test, y_train, y_test, scaler, feature_names = load_and_preprocess_data()
    
    # Train models
    print("=" * 60)
    print("STEP 2: Training Models with Hyperparameter Tuning")
    print("=" * 60)
    
    models = {}
    metrics_list = []
    
    # Logistic Regression
    lr_model, lr_metrics = train_logistic_regression(X_train, y_train, X_test, y_test)
    models['Logistic Regression'] = lr_model
    metrics_list.append(lr_metrics)
    print("✓ Logistic Regression completed\n")
    
    # Random Forest
    rf_model, rf_metrics = train_random_forest(X_train, y_train, X_test, y_test)
    models['Random Forest'] = rf_model
    metrics_list.append(rf_metrics)
    print("✓ Random Forest completed\n")
    
    # XGBoost
    try:
        xgb_model, xgb_metrics = train_xgboost(X_train, y_train, X_test, y_test)
        models['XGBoost'] = xgb_model
        metrics_list.append(xgb_metrics)
        print("✓ XGBoost completed\n")
    except Exception as e:
        print(f"⚠ XGBoost training failed: {e}\n")
    
    # Compare models
    print("=" * 60)
    print("STEP 3: Model Comparison")
    print("=" * 60)
    
    results_df = pd.DataFrame(metrics_list)
    print("\nModel Performance Metrics:")
    print("-" * 60)
    print(results_df.to_string(index=False))
    print("-" * 60)
    
    # Select best model based on ROC AUC
    best_idx = results_df['ROC AUC'].idxmax()
    best_model_name = results_df.loc[best_idx, 'Model']
    best_model = models[best_model_name]
    
    print(f"\n\-_-/ BEST MODEL: {best_model_name}")
    print(f"   ROC AUC Score: {results_df.loc[best_idx, 'ROC AUC']:.4f}")
    print(f"   Accuracy: {results_df.loc[best_idx, 'Accuracy']:.4f}")
    print(f"   F1 Score: {results_df.loc[best_idx, 'F1 Score']:.4f}")
    
    # Save best model and scaler
    print("\n" + "=" * 60)
    print("STEP 4: Saving Model and Artifacts")
    print("=" * 60)
    
    model_data = {
        'model': best_model,
        'scaler': scaler,
        'feature_names': feature_names,
        'model_name': best_model_name,
        'metrics': results_df.loc[best_idx].to_dict(),
        'all_metrics': results_df.to_dict('records')
    }
    
    joblib.dump(model_data, 'model.pkl')
    print("✓ Best model saved as 'model.pkl'")
    print("✓ Scaler and feature names included")
    
    # Calculate confusion matrix and ROC curve for best model
    y_pred = best_model.predict(X_test)
    y_pred_proba = best_model.predict_proba(X_test)[:, 1]
    
    cm = confusion_matrix(y_test, y_pred)
    fpr, tpr, _ = roc_curve(y_test, y_pred_proba)
    
    # Save additional data for visualization
    viz_data = {
        'confusion_matrix': cm,
        'roc_curve': (fpr, tpr),
        'y_test': y_test.values,
        'y_pred_proba': y_pred_proba
    }
    joblib.dump(viz_data, 'viz_data.pkl')
    print("✓ Visualization data saved as 'viz_data.pkl'")
    
    print("\n" + "=" * 60)
    print("TRAINING COMPLETED SUCCESSFULLY!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. Run the Streamlit app: streamlit run app.py")
    print("2. The app will load model.pkl for predictions")
    print("=" * 60 + "\n")

if __name__ == "__main__":
    main()