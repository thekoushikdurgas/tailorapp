import plotly.graph_objects as go
import plotly.express as px
import pandas as pd
import numpy as np

# Create data for the BLoC architecture diagram
components = []
x_positions = []
y_positions = []
colors = []
symbols = []
sizes = []
labels = []

# Define positions and colors for different component types
ui_y = 4
event_y = 3
bloc_y = 2
state_y = 1
repo_y = 0

# Color mapping based on predefined palette
color_map = {
    'UI': '#FFC185',        # Light orange
    'Event': '#1FB8CD',     # Strong cyan  
    'BLoC': '#5D878F',      # Cyan
    'State': '#ECEBD5',     # Light green
    'Repo': '#D2BA4C'       # Moderate yellow
}

# BLoC data
blocs_data = [
    {"name": "AuthBloc", "events": ["LoginReq", "RegisterReq", "LogoutReq"], 
     "states": ["AuthInit", "AuthLoad", "AuthSuccess", "AuthFail"]},
    {"name": "DesignBloc", "events": ["CreateDes", "UpdateDes", "SaveDes", "LoadDes"], 
     "states": ["DesInit", "DesLoad", "DesLoaded", "DesError"]},
    {"name": "OrderBloc", "events": ["CreateOrd", "UpdateOrd", "TrackOrd", "LoadOrd"], 
     "states": ["OrdInit", "OrdLoad", "OrdCreated", "OrdError"]},
    {"name": "ProfileBloc", "events": ["UpdateProf", "LoadProf", "UpdateSet"], 
     "states": ["ProfInit", "ProfLoad", "ProfLoaded", "ProfError"]}
]

# Add UI components
ui_components = ["AuthUI", "DesignUI", "OrderUI", "ProfileUI"]
for i, ui in enumerate(ui_components):
    components.append(ui)
    x_positions.append(i * 2)
    y_positions.append(ui_y)
    colors.append(color_map['UI'])
    symbols.append('square')
    sizes.append(20)
    labels.append(ui)

# Add Events, BLoCs, and States
for i, bloc_data in enumerate(blocs_data):
    x_base = i * 2
    
    # Add Events
    for j, event in enumerate(bloc_data['events']):
        components.append(event)
        x_positions.append(x_base + (j - 1.5) * 0.3)
        y_positions.append(event_y)
        colors.append(color_map['Event'])
        symbols.append('circle')
        sizes.append(12)
        labels.append(event)
    
    # Add BLoC
    components.append(bloc_data['name'])
    x_positions.append(x_base)
    y_positions.append(bloc_y)
    colors.append(color_map['BLoC'])
    symbols.append('diamond')
    sizes.append(25)
    labels.append(bloc_data['name'])
    
    # Add States
    for j, state in enumerate(bloc_data['states']):
        components.append(state)
        x_positions.append(x_base + (j - 1.5) * 0.3)
        y_positions.append(state_y)
        colors.append(color_map['State'])
        symbols.append('circle')
        sizes.append(12)
        labels.append(state)

# Add Repository layer
repo_components = ["AuthRepo", "DesignRepo", "OrderRepo", "ProfileRepo"]
for i, repo in enumerate(repo_components):
    components.append(repo)
    x_positions.append(i * 2)
    y_positions.append(repo_y)
    colors.append(color_map['Repo'])
    symbols.append('hexagon')
    sizes.append(18)
    labels.append(repo)

# Create the scatter plot
fig = go.Figure()

# Add all components
fig.add_trace(go.Scatter(
    x=x_positions,
    y=y_positions,
    mode='markers+text',
    marker=dict(
        size=sizes,
        color=colors,
        symbol=symbols,
        line=dict(width=2, color='white')
    ),
    text=labels,
    textposition="middle center",
    textfont=dict(size=8, color='black'),
    hovertext=components,
    hovertemplate='<b>%{hovertext}</b><extra></extra>',
    showlegend=False
))

# Add flow arrows (simplified representation using lines)
arrow_x = []
arrow_y = []
for i in range(4):
    x_base = i * 2
    # UI to Events
    arrow_x.extend([x_base, x_base, None])
    arrow_y.extend([ui_y, event_y, None])
    # Events to BLoC
    arrow_x.extend([x_base, x_base, None])
    arrow_y.extend([event_y, bloc_y, None])
    # BLoC to States
    arrow_x.extend([x_base, x_base, None])
    arrow_y.extend([bloc_y, state_y, None])
    # BLoC to Repository
    arrow_x.extend([x_base, x_base, None])
    arrow_y.extend([bloc_y, repo_y, None])

fig.add_trace(go.Scatter(
    x=arrow_x,
    y=arrow_y,
    mode='lines',
    line=dict(color='#13343B', width=2, dash='dot'),
    hoverinfo='skip',
    showlegend=False
))

# Update layout
fig.update_layout(
    title="BLoC Architecture Flow",
    xaxis=dict(
        showgrid=False,
        zeroline=False,
        showticklabels=False,
        title=""
    ),
    yaxis=dict(
        showgrid=False,
        zeroline=False,
        ticktext=["Repository", "States", "BLoCs", "Events", "UI"],
        tickvals=[0, 1, 2, 3, 4],
        title="Layer"
    ),
    plot_bgcolor='white'
)

# Save the chart
fig.write_image("bloc_architecture_diagram.png")