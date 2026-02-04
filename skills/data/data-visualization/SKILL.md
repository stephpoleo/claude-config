---
name: data-visualization
description: Create effective data visualizations with Python libraries
user-invocable: true
categories: [data, visualization, python, analytics]
version: 1.0.0
---

# Data Visualization

Create clear, effective, and professional data visualizations using Python libraries like matplotlib, seaborn, and plotly.

## Usage

```
/data-visualization <chart-type> <description>
```

### Examples

```
/data-visualization "line chart for time series sales data"
/data-visualization "heatmap for correlation matrix"
/data-visualization "interactive dashboard with plotly"
```

## Libraries

### Matplotlib - Base Library

```python
import matplotlib.pyplot as plt
import numpy as np

# Basic line plot
plt.figure(figsize=(10, 6))
plt.plot(x, y, label='Sales', linewidth=2, color='#2E86AB')
plt.xlabel('Date', fontsize=12)
plt.ylabel('Revenue ($)', fontsize=12)
plt.title('Monthly Sales Trend', fontsize=14, fontweight='bold')
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('sales_trend.png', dpi=300, bbox_inches='tight')
plt.show()
```

### Seaborn - Statistical Graphics

```python
import seaborn as sns
import pandas as pd

# Set style
sns.set_style('whitegrid')
sns.set_palette('husl')

# Distribution plot
plt.figure(figsize=(10, 6))
sns.histplot(data=df, x='age', hue='category', kde=True, bins=30)
plt.title('Age Distribution by Category')
plt.show()

# Correlation heatmap
plt.figure(figsize=(12, 8))
correlation = df.corr()
sns.heatmap(correlation, annot=True, fmt='.2f', cmap='coolwarm',
            center=0, square=True, linewidths=1)
plt.title('Feature Correlation Matrix')
plt.tight_layout()
plt.show()
```

### Plotly - Interactive Visualizations

```python
import plotly.express as px
import plotly.graph_objects as go

# Interactive line chart
fig = px.line(df, x='date', y='sales',
              title='Sales Over Time',
              labels={'sales': 'Revenue ($)', 'date': 'Date'})
fig.update_layout(hovermode='x unified')
fig.show()

# Interactive scatter with color
fig = px.scatter(df, x='age', y='income', color='category',
                 size='purchases', hover_data=['name'],
                 title='Customer Segmentation')
fig.show()
```

## Common Visualizations

### 1. Time Series

```python
def plot_time_series(df, date_col, value_col, title='Time Series'):
    """Plot time series with trend line."""
    fig, ax = plt.subplots(figsize=(12, 6))

    # Main line
    ax.plot(df[date_col], df[value_col],
            linewidth=2, label='Actual', color='#2E86AB')

    # Moving average
    df['MA_7'] = df[value_col].rolling(window=7).mean()
    ax.plot(df[date_col], df['MA_7'],
            linewidth=2, label='7-day MA',
            color='#A23B72', linestyle='--')

    ax.set_xlabel('Date', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig
```

### 2. Distribution Comparison

```python
def plot_distributions(df, column, groupby=None):
    """Plot distribution with optional grouping."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Histogram
    if groupby:
        for group in df[groupby].unique():
            data = df[df[groupby] == group][column]
            axes[0].hist(data, alpha=0.5, label=group, bins=30)
        axes[0].legend()
    else:
        axes[0].hist(df[column], bins=30, edgecolor='black')

    axes[0].set_xlabel(column)
    axes[0].set_ylabel('Frequency')
    axes[0].set_title('Distribution')

    # Box plot
    if groupby:
        df.boxplot(column=column, by=groupby, ax=axes[1])
    else:
        axes[1].boxplot(df[column])

    axes[1].set_title('Box Plot')

    plt.tight_layout()
    return fig
```

### 3. Correlation Analysis

```python
def plot_correlation_matrix(df, figsize=(12, 10)):
    """Plot correlation matrix with annotations."""
    # Calculate correlation
    corr = df.select_dtypes(include=[np.number]).corr()

    # Create mask for upper triangle
    mask = np.triu(np.ones_like(corr, dtype=bool))

    # Plot
    fig, ax = plt.subplots(figsize=figsize)
    sns.heatmap(corr, mask=mask, annot=True, fmt='.2f',
                cmap='RdBu_r', center=0, square=True,
                linewidths=1, cbar_kws={'shrink': 0.8})

    plt.title('Correlation Matrix', fontsize=14, fontweight='bold')
    plt.tight_layout()
    return fig
```

### 4. Categorical Comparison

```python
def plot_categorical_comparison(df, category_col, value_col):
    """Plot categorical data comparison."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Bar plot
    summary = df.groupby(category_col)[value_col].mean().sort_values(ascending=False)
    axes[0].bar(summary.index, summary.values, color='#2E86AB')
    axes[0].set_xlabel(category_col)
    axes[0].set_ylabel(f'Average {value_col}')
    axes[0].set_title('Average by Category')
    axes[0].tick_params(axis='x', rotation=45)

    # Count plot
    counts = df[category_col].value_counts()
    axes[1].bar(counts.index, counts.values, color='#A23B72')
    axes[1].set_xlabel(category_col)
    axes[1].set_ylabel('Count')
    axes[1].set_title('Count by Category')
    axes[1].tick_params(axis='x', rotation=45)

    plt.tight_layout()
    return fig
```

### 5. Scatter Plot with Regression

```python
def plot_scatter_with_regression(df, x_col, y_col, hue_col=None):
    """Scatter plot with regression line."""
    fig, ax = plt.subplots(figsize=(10, 6))

    if hue_col:
        for category in df[hue_col].unique():
            data = df[df[hue_col] == category]
            ax.scatter(data[x_col], data[y_col],
                      label=category, alpha=0.6, s=50)
    else:
        ax.scatter(df[x_col], df[y_col], alpha=0.6, s=50)

    # Add regression line
    from scipy import stats
    slope, intercept, r_value, p_value, std_err = stats.linregress(df[x_col], df[y_col])
    line = slope * df[x_col] + intercept
    ax.plot(df[x_col], line, 'r--', linewidth=2,
            label=f'y={slope:.2f}x+{intercept:.2f} (R²={r_value**2:.3f})')

    ax.set_xlabel(x_col, fontsize=12)
    ax.set_ylabel(y_col, fontsize=12)
    ax.set_title(f'{y_col} vs {x_col}', fontsize=14, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig
```

## Interactive Dashboards with Plotly

```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots

def create_dashboard(df):
    """Create interactive dashboard."""
    # Create subplots
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Sales Trend', 'Category Distribution',
                       'Revenue by Region', 'Top Products'),
        specs=[[{'type': 'scatter'}, {'type': 'bar'}],
               [{'type': 'bar'}, {'type': 'table'}]]
    )

    # Sales trend
    fig.add_trace(
        go.Scatter(x=df['date'], y=df['sales'],
                  name='Sales', mode='lines+markers'),
        row=1, col=1
    )

    # Category distribution
    category_counts = df['category'].value_counts()
    fig.add_trace(
        go.Bar(x=category_counts.index, y=category_counts.values,
               name='Categories'),
        row=1, col=2
    )

    # Revenue by region
    revenue_by_region = df.groupby('region')['revenue'].sum().sort_values(ascending=False)
    fig.add_trace(
        go.Bar(x=revenue_by_region.index, y=revenue_by_region.values,
               name='Revenue'),
        row=2, col=1
    )

    # Top products table
    top_products = df.groupby('product')['sales'].sum().sort_values(ascending=False).head(10)
    fig.add_trace(
        go.Table(
            header=dict(values=['Product', 'Sales']),
            cells=dict(values=[top_products.index, top_products.values])
        ),
        row=2, col=2
    )

    # Update layout
    fig.update_layout(
        title_text='Sales Dashboard',
        showlegend=False,
        height=800
    )

    return fig
```

## Best Practices

### 1. Color Palettes

```python
# Professional color schemes
COLORS = {
    'blue': '#2E86AB',
    'pink': '#A23B72',
    'orange': '#F18F01',
    'green': '#06A77D',
    'gray': '#5E6472'
}

# Seaborn palettes
sns.set_palette('husl')  # Evenly spaced colors
sns.set_palette('Set2')  # Qualitative
sns.set_palette('RdYlBu')  # Diverging
```

### 2. Figure Size and DPI

```python
# Standard sizes
plt.figure(figsize=(10, 6))  # Wide chart
plt.figure(figsize=(8, 8))   # Square chart
plt.figure(figsize=(12, 4))  # Very wide

# High resolution
plt.savefig('chart.png', dpi=300, bbox_inches='tight')
```

### 3. Labels and Titles

```python
# Clear labeling
plt.xlabel('Time (months)', fontsize=12)
plt.ylabel('Revenue (USD)', fontsize=12)
plt.title('Monthly Revenue Trend 2024', fontsize=14, fontweight='bold', pad=20)
```

### 4. Grid and Style

```python
# Clean grid
plt.grid(True, alpha=0.3, linestyle='--')

# Remove spines
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
```

### 5. Accessibility

```python
# Use colorblind-friendly palettes
sns.set_palette('colorblind')

# Add patterns for black and white printing
```

## Advanced Techniques

### Facet Grids

```python
# Multiple subplots
g = sns.FacetGrid(df, col='category', row='region', height=4)
g.map(plt.hist, 'sales', bins=20)
g.add_legend()
```

### 3D Plots

```python
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')
ax.scatter(df['x'], df['y'], df['z'], c=df['category'], s=50)
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')
```

### Animated Plots (Plotly)

```python
import plotly.express as px

fig = px.scatter(df, x='x', y='y', animation_frame='year',
                 size='population', color='continent',
                 hover_name='country', log_x=True,
                 range_x=[100, 100000], range_y=[25, 90])
fig.show()
```

## Export Options

```python
# High-quality PNG
plt.savefig('chart.png', dpi=300, bbox_inches='tight', facecolor='white')

# Vector format (scalable)
plt.savefig('chart.svg', format='svg', bbox_inches='tight')

# PDF for reports
plt.savefig('chart.pdf', bbox_inches='tight')

# Interactive HTML (Plotly)
fig.write_html('dashboard.html')
```

## Common Mistakes to Avoid

1. **Too much information** - Keep it simple
2. **Poor color choices** - Use professional palettes
3. **Missing labels** - Always label axes and add titles
4. **Wrong chart type** - Choose appropriate visualization
5. **No legend** - Include legend when needed
6. **Low resolution** - Use high DPI for final output
7. **Inconsistent styling** - Use consistent colors and fonts
8. **Cluttered plots** - Remove unnecessary elements

## Checklist

- [ ] Appropriate chart type selected
- [ ] Clear and descriptive title
- [ ] Labeled axes with units
- [ ] Legend included (if needed)
- [ ] Professional color palette
- [ ] High resolution export
- [ ] Grid for readability
- [ ] Proper figure size
- [ ] Clean and uncluttered
- [ ] Accessible to colorblind viewers
