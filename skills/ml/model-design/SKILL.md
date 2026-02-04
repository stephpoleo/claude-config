---
name: model-design
description: Design and implement machine learning models (supervised and unsupervised)
user-invocable: true
categories: [ml, data-science, python]
version: 1.0.0
---

# Machine Learning Model Design

Design, implement, and evaluate machine learning models following data science best practices.

## Usage

```
/model-design <model-type> <description>
```

### Examples

```
/model-design supervised "customer churn prediction with classification"
/model-design unsupervised "customer segmentation using clustering"
/model-design supervised "sales forecasting with regression"
```

## Project Structure

```
ml-project/
├── data/
│   ├── raw/
│   ├── processed/
│   └── features/
├── notebooks/
│   ├── 01_exploration.ipynb
│   ├── 02_feature_engineering.ipynb
│   └── 03_modeling.ipynb
├── src/
│   ├── data/
│   │   ├── __init__.py
│   │   └── preprocessing.py
│   ├── features/
│   │   ├── __init__.py
│   │   └── engineering.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── train.py
│   │   └── predict.py
│   └── evaluation/
│       ├── __init__.py
│       └── metrics.py
├── models/              # Saved models
├── config/
│   └── model_config.yaml
├── requirements.txt
└── README.md
```

## Supervised Learning

### Classification Example

```python
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score
import joblib


class ChurnPredictor:
    """Customer churn prediction model."""

    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()
        self.feature_names = None

    def prepare_data(self, df: pd.DataFrame):
        """Prepare data for modeling."""
        # Feature engineering
        df['account_age_days'] = (pd.Timestamp.now() - df['created_at']).dt.days
        df['avg_monthly_spend'] = df['total_spend'] / df['months_active']

        # Select features
        features = [
            'account_age_days',
            'avg_monthly_spend',
            'support_tickets',
            'login_frequency'
        ]

        X = df[features]
        y = df['churned']

        self.feature_names = features

        return X, y

    def train(self, X, y):
        """Train the model."""
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )

        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)

        # Train model
        self.model = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            min_samples_split=20,
            class_weight='balanced',
            random_state=42
        )

        self.model.fit(X_train_scaled, y_train)

        # Evaluate
        train_score = self.model.score(X_train_scaled, y_train)
        test_score = self.model.score(X_test_scaled, y_test)

        print(f"Train accuracy: {train_score:.4f}")
        print(f"Test accuracy: {test_score:.4f}")

        # Cross-validation
        cv_scores = cross_val_score(
            self.model, X_train_scaled, y_train, cv=5
        )
        print(f"CV accuracy: {cv_scores.mean():.4f} (+/- {cv_scores.std():.4f})")

        # Detailed evaluation
        y_pred = self.model.predict(X_test_scaled)
        y_pred_proba = self.model.predict_proba(X_test_scaled)[:, 1]

        print("\nClassification Report:")
        print(classification_report(y_test, y_pred))

        print(f"\nROC-AUC: {roc_auc_score(y_test, y_pred_proba):.4f}")

        # Feature importance
        self._print_feature_importance()

        return X_test, y_test

    def _print_feature_importance(self):
        """Print feature importance."""
        importances = self.model.feature_importances_
        indices = np.argsort(importances)[::-1]

        print("\nFeature Importance:")
        for i in indices:
            print(f"{self.feature_names[i]}: {importances[i]:.4f}")

    def predict(self, X):
        """Make predictions."""
        X_scaled = self.scaler.transform(X)
        return self.model.predict(X_scaled)

    def predict_proba(self, X):
        """Predict probabilities."""
        X_scaled = self.scaler.transform(X)
        return self.model.predict_proba(X_scaled)

    def save(self, path: str):
        """Save model to disk."""
        joblib.dump({
            'model': self.model,
            'scaler': self.scaler,
            'features': self.feature_names
        }, path)

    @classmethod
    def load(cls, path: str):
        """Load model from disk."""
        data = joblib.load(path)
        instance = cls()
        instance.model = data['model']
        instance.scaler = data['scaler']
        instance.feature_names = data['features']
        return instance
```

### Regression Example

```python
from sklearn.linear_model import LinearRegression, Ridge, Lasso
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error


class SalesForecaster:
    """Sales forecasting model."""

    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()

    def prepare_features(self, df: pd.DataFrame):
        """Engineer time series features."""
        df = df.copy()

        # Time-based features
        df['day_of_week'] = df['date'].dt.dayofweek
        df['month'] = df['date'].dt.month
        df['quarter'] = df['date'].dt.quarter
        df['is_weekend'] = df['day_of_week'].isin([5, 6]).astype(int)

        # Lag features
        for lag in [1, 7, 30]:
            df[f'sales_lag_{lag}'] = df['sales'].shift(lag)

        # Rolling statistics
        df['sales_rolling_mean_7'] = df['sales'].rolling(7).mean()
        df['sales_rolling_std_7'] = df['sales'].rolling(7).std()

        # Drop NaN from lag features
        df = df.dropna()

        return df

    def train(self, X, y):
        """Train regression model."""
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, shuffle=False  # Time series: no shuffle
        )

        # Scale
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)

        # Train
        self.model = Ridge(alpha=1.0)
        self.model.fit(X_train_scaled, y_train)

        # Evaluate
        y_pred_train = self.model.predict(X_train_scaled)
        y_pred_test = self.model.predict(X_test_scaled)

        print("Training Metrics:")
        print(f"R²: {r2_score(y_train, y_pred_train):.4f}")
        print(f"RMSE: {np.sqrt(mean_squared_error(y_train, y_pred_train)):.2f}")
        print(f"MAE: {mean_absolute_error(y_train, y_pred_train):.2f}")

        print("\nTest Metrics:")
        print(f"R²: {r2_score(y_test, y_pred_test):.4f}")
        print(f"RMSE: {np.sqrt(mean_squared_error(y_test, y_pred_test)):.2f}")
        print(f"MAE: {mean_absolute_error(y_test, y_pred_test):.2f}")

        return X_test, y_test
```

## Unsupervised Learning

### Clustering Example

```python
from sklearn.cluster import KMeans, DBSCAN
from sklearn.decomposition import PCA
from sklearn.metrics import silhouette_score
import matplotlib.pyplot as plt


class CustomerSegmentation:
    """Customer segmentation using clustering."""

    def __init__(self, n_clusters=4):
        self.n_clusters = n_clusters
        self.model = None
        self.scaler = StandardScaler()
        self.pca = None

    def prepare_data(self, df: pd.DataFrame):
        """Prepare customer features."""
        features = [
            'total_purchases',
            'avg_order_value',
            'days_since_last_purchase',
            'account_age_days',
            'support_interactions'
        ]

        X = df[features]
        return X

    def find_optimal_clusters(self, X, max_k=10):
        """Find optimal number of clusters using elbow method."""
        X_scaled = self.scaler.fit_transform(X)

        inertias = []
        silhouette_scores = []

        for k in range(2, max_k + 1):
            kmeans = KMeans(n_clusters=k, random_state=42)
            kmeans.fit(X_scaled)

            inertias.append(kmeans.inertia_)
            silhouette_scores.append(silhouette_score(X_scaled, kmeans.labels_))

        # Plot
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

        ax1.plot(range(2, max_k + 1), inertias, marker='o')
        ax1.set_xlabel('Number of Clusters')
        ax1.set_ylabel('Inertia')
        ax1.set_title('Elbow Method')

        ax2.plot(range(2, max_k + 1), silhouette_scores, marker='o')
        ax2.set_xlabel('Number of Clusters')
        ax2.set_ylabel('Silhouette Score')
        ax2.set_title('Silhouette Analysis')

        plt.tight_layout()
        plt.show()

    def train(self, X):
        """Train clustering model."""
        X_scaled = self.scaler.fit_transform(X)

        # K-Means
        self.model = KMeans(n_clusters=self.n_clusters, random_state=42)
        labels = self.model.fit_predict(X_scaled)

        # Evaluate
        score = silhouette_score(X_scaled, labels)
        print(f"Silhouette Score: {score:.4f}")

        # PCA for visualization
        self.pca = PCA(n_components=2)
        X_pca = self.pca.fit_transform(X_scaled)

        # Plot clusters
        plt.figure(figsize=(10, 6))
        scatter = plt.scatter(
            X_pca[:, 0], X_pca[:, 1],
            c=labels, cmap='viridis', alpha=0.6
        )
        plt.colorbar(scatter)
        plt.title('Customer Segments (PCA)')
        plt.xlabel('PC1')
        plt.ylabel('PC2')
        plt.show()

        return labels

    def analyze_segments(self, df: pd.DataFrame, labels):
        """Analyze characteristics of each segment."""
        df['segment'] = labels

        print("\nSegment Analysis:")
        for segment in range(self.n_clusters):
            print(f"\n=== Segment {segment} ===")
            segment_data = df[df['segment'] == segment]
            print(f"Size: {len(segment_data)} ({len(segment_data)/len(df)*100:.1f}%)")
            print(segment_data.describe())
```

## Model Evaluation

```python
def evaluate_classification_model(y_true, y_pred, y_pred_proba=None):
    """Comprehensive classification evaluation."""
    from sklearn.metrics import (
        accuracy_score, precision_score, recall_score, f1_score,
        roc_auc_score, confusion_matrix, classification_report
    )

    print("=== Classification Metrics ===")
    print(f"Accuracy:  {accuracy_score(y_true, y_pred):.4f}")
    print(f"Precision: {precision_score(y_true, y_pred, average='weighted'):.4f}")
    print(f"Recall:    {recall_score(y_true, y_pred, average='weighted'):.4f}")
    print(f"F1 Score:  {f1_score(y_true, y_pred, average='weighted'):.4f}")

    if y_pred_proba is not None:
        print(f"ROC-AUC:   {roc_auc_score(y_true, y_pred_proba):.4f}")

    print("\n=== Confusion Matrix ===")
    print(confusion_matrix(y_true, y_pred))

    print("\n=== Classification Report ===")
    print(classification_report(y_true, y_pred))
```

## Best Practices

1. **Data Splitting**: Train/validation/test splits
2. **Feature Engineering**: Create meaningful features
3. **Feature Scaling**: Normalize/standardize when needed
4. **Cross-Validation**: Use k-fold CV
5. **Hyperparameter Tuning**: Grid/random search
6. **Model Selection**: Try multiple algorithms
7. **Ensemble Methods**: Combine models
8. **Monitor Overfitting**: Train vs test performance
9. **Feature Selection**: Remove irrelevant features
10. **Model Interpretability**: Understand predictions
11. **Versioning**: Track data, code, and models
12. **Documentation**: Document assumptions and decisions

## Tools

- **scikit-learn**: ML algorithms
- **pandas**: Data manipulation
- **numpy**: Numerical computing
- **matplotlib/seaborn**: Visualization
- **xgboost/lightgbm**: Gradient boosting
- **mlflow**: Experiment tracking
- **optuna**: Hyperparameter optimization
