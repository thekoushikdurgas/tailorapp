import plotly.graph_objects as go
import plotly.express as px
import pandas as pd

# Data for the Flutter AI Tailoring App tech stack
data = {
    "categories": [
        {"name": "Core Flutter", "packages": ["flutter_sdk", "dart_sdk", "material_design"], "color": "#2196F3"},
        {"name": "State Management", "packages": ["provider", "riverpod", "getx", "flutter_bloc"], "color": "#4CAF50"},
        {"name": "AI Integration", "packages": ["google_generative_ai", "dart_openai", "tflite_flutter", "ml_kit"], "color": "#FF9800"},
        {"name": "UI/UX", "packages": ["camera", "flutter_canvas_api", "image_picker", "flutter_drawing_board"], "color": "#E91E63"},
        {"name": "Data & Storage", "packages": ["firebase_core", "cloud_firestore", "hive", "sqflite"], "color": "#9C27B0"},
        {"name": "Networking", "packages": ["dio", "http", "connectivity_plus"], "color": "#607D8B"},
        {"name": "Architecture", "packages": ["flutter_clean_architecture", "get_it", "injectable"], "color": "#795548"},
        {"name": "Testing", "packages": ["flutter_test", "mockito", "integration_test"], "color": "#009688"}
    ]
}

# Brand colors to use
brand_colors = ["#1FB8CD", "#FFC185", "#ECEBD5", "#5D878F", "#D2BA4C", "#B4413C", "#964325", "#944454"]

# Prepare data for treemap
df_data = []
for i, category in enumerate(data["categories"]):
    cat_name = category["name"][:15]
    for package in category["packages"]:
        pkg_name = package[:15]
        df_data.append({
            'category': cat_name,
            'package': pkg_name,
            'value': 1,
            'color': brand_colors[i % len(brand_colors)]
        })

df = pd.DataFrame(df_data)

# Create treemap
fig = go.Figure(go.Treemap(
    labels=[f"{row['category']}<br>{row['package']}" for _, row in df.iterrows()],
    parents=[row['category'] for _, row in df.iterrows()],
    values=df['value'],
    textinfo="label",
    textposition="middle center",
    marker=dict(
        colors=[row['color'] for _, row in df.iterrows()],
        line=dict(width=2, color="white")
    ),
    hovertemplate="<b>%{label}</b><br>Category: %{parent}<extra></extra>",
    maxdepth=2,
    textfont_size=10
))

# Add category level
categories = []
for i, category in enumerate(data["categories"]):
    categories.append({
        'label': category["name"][:15],
        'parent': "",
        'value': len(category["packages"]),
        'color': brand_colors[i % len(brand_colors)]
    })

# Create a proper hierarchical treemap
labels = [""]
parents = [""]
values = [sum(len(cat["packages"]) for cat in data["categories"])]
colors = ["#13343B"]

# Add categories
for i, category in enumerate(data["categories"]):
    cat_name = category["name"][:15]
    labels.append(cat_name)
    parents.append("")
    values.append(len(category["packages"]))
    colors.append(brand_colors[i % len(brand_colors)])

# Add packages
for i, category in enumerate(data["categories"]):
    cat_name = category["name"][:15]
    for package in category["packages"]:
        pkg_name = package[:15]
        labels.append(pkg_name)
        parents.append(cat_name)
        values.append(1)
        colors.append(brand_colors[i % len(brand_colors)])

fig = go.Figure(go.Treemap(
    labels=labels,
    parents=parents,
    values=values,
    textinfo="label",
    textposition="middle center",
    marker=dict(
        colors=colors,
        line=dict(width=2, color="white")
    ),
    hovertemplate="<b>%{label}</b><br>Parent: %{parent}<extra></extra>",
    maxdepth=2,
    textfont_size=10
))

fig.update_layout(
    title="Flutter AI Tailoring App Stack",
    font_size=12,
    uniformtext_minsize=8,
    uniformtext_mode='hide'
)

# Save the chart
fig.write_image("flutter_tech_stack.png")