import plotly.graph_objects as go
import plotly.express as px
import json
import numpy as np

# Create comprehensive widget hierarchy based on user instructions
widgets = {
    # Root Level
    "MyApp": {"parent": None, "category": "App Root", "type": "MaterialApp", "level": 0},
    "ThemeData": {"parent": "MyApp", "category": "App Root", "type": "Configuration", "level": 1},
    "Routes": {"parent": "MyApp", "category": "App Root", "type": "Configuration", "level": 1},
    
    # Authentication Flow
    "AuthWrapper": {"parent": "MyApp", "category": "Authentication", "type": "StatelessWidget", "level": 1},
    "LoginScreen": {"parent": "AuthWrapper", "category": "Authentication", "type": "StatefulWidget", "level": 2},
    "SignUpScreen": {"parent": "AuthWrapper", "category": "Authentication", "type": "StatefulWidget", "level": 2},
    "ProfileSetupScreen": {"parent": "AuthWrapper", "category": "Authentication", "type": "StatefulWidget", "level": 2},
    
    # Main App Widgets
    "HomeScreen": {"parent": "AuthWrapper", "category": "Main App", "type": "StatefulWidget", "level": 2},
    "BottomNavigationBar": {"parent": "HomeScreen", "category": "Main App", "type": "Widget", "level": 3},
    "AppDrawer": {"parent": "HomeScreen", "category": "Main App", "type": "Widget", "level": 3},
    
    # Design Studio Widgets
    "DesignStudioScreen": {"parent": "HomeScreen", "category": "Design Studio", "type": "StatefulWidget", "level": 3},
    "CustomPainter": {"parent": "DesignStudioScreen", "category": "Design Studio", "type": "Widget", "level": 4},
    "ToolsPalette": {"parent": "DesignStudioScreen", "category": "Design Studio", "type": "Widget", "level": 4},
    "ColorPicker": {"parent": "DesignStudioScreen", "category": "Design Studio", "type": "Widget", "level": 4},
    "PatternLibrary": {"parent": "DesignStudioScreen", "category": "Design Studio", "type": "Widget", "level": 4},
    
    # Virtual Fitting Widgets
    "VirtualFittingScreen": {"parent": "HomeScreen", "category": "Virtual Fitting", "type": "StatefulWidget", "level": 3},
    "ARView": {"parent": "VirtualFittingScreen", "category": "Virtual Fitting", "type": "Widget", "level": 4},
    "CameraPreview": {"parent": "VirtualFittingScreen", "category": "Virtual Fitting", "type": "Widget", "level": 4},
    "DesignOverlay": {"parent": "VirtualFittingScreen", "category": "Virtual Fitting", "type": "Widget", "level": 4},
    
    # Order Management Widgets
    "OrderSummaryScreen": {"parent": "HomeScreen", "category": "Order Management", "type": "StatefulWidget", "level": 3},
    "PaymentScreen": {"parent": "OrderSummaryScreen", "category": "Order Management", "type": "StatefulWidget", "level": 4},
    "OrderTrackingScreen": {"parent": "OrderSummaryScreen", "category": "Order Management", "type": "StatefulWidget", "level": 4},
    
    # Profile Widgets
    "ProfileScreen": {"parent": "HomeScreen", "category": "Profile", "type": "StatefulWidget", "level": 3},
    "SettingsScreen": {"parent": "ProfileScreen", "category": "Profile", "type": "StatefulWidget", "level": 4},
    "MyDesignsScreen": {"parent": "ProfileScreen", "category": "Profile", "type": "StatefulWidget", "level": 4}
}

# Improved tree layout with better spacing
def create_improved_tree_layout(widgets):
    pos = {}
    
    # Group nodes by level
    levels = {}
    for widget_name, info in widgets.items():
        level = info["level"]
        if level not in levels:
            levels[level] = []
        levels[level].append(widget_name)
    
    # Calculate positions with improved spacing
    y_spacing = 150  # Increased vertical spacing
    max_level = max(levels.keys())
    
    for level, nodes in levels.items():
        y = (max_level - level) * y_spacing
        
        # Better horizontal spacing calculation
        if len(nodes) == 1:
            x_positions = [0]
        elif len(nodes) == 2:
            x_positions = [-200, 200]
        else:
            # Distribute nodes more evenly across width
            total_width = 1200  # Increased total width
            x_positions = []
            for i in range(len(nodes)):
                x = -total_width/2 + (i * total_width / (len(nodes) - 1))
                x_positions.append(x)
        
        for i, node in enumerate(nodes):
            pos[node] = (x_positions[i], y)
    
    return pos

pos = create_improved_tree_layout(widgets)

# Define more saturated colors for better distinction
category_colors = {
    "App Root": "#1FB8CD",
    "Authentication": "#FFC185", 
    "Main App": "#ECEBD5",
    "Design Studio": "#5D878F",
    "Virtual Fitting": "#D2BA4C",
    "Order Management": "#B4413C",
    "Profile": "#964325"
}

# Create edge traces for connections
edge_traces = []
for widget_name, info in widgets.items():
    if info["parent"] and info["parent"] in pos:
        x0, y0 = pos[info["parent"]]
        x1, y1 = pos[widget_name]
        
        edge_trace = go.Scatter(
            x=[x0, x1, None],
            y=[y0, y1, None],
            mode='lines',
            line=dict(width=2, color='#666'),
            hoverinfo='none',
            showlegend=False
        )
        edge_traces.append(edge_trace)

# Create node trace with improved text positioning
node_x = []
node_y = []
node_colors = []
hover_text = []

for widget_name, info in widgets.items():
    x, y = pos[widget_name]
    node_x.append(x)
    node_y.append(y)
    node_colors.append(category_colors[info["category"]])
    hover_text.append(f"{widget_name}<br>Type: {info['type']}<br>Category: {info['category']}")

# Create nodes without text (text will be separate)
node_trace = go.Scatter(
    x=node_x,
    y=node_y,
    mode='markers',
    marker=dict(
        size=30,  # Increased size
        color=node_colors,
        line=dict(width=2, color='white')
    ),
    hovertext=hover_text,
    hoverinfo='text',
    showlegend=False
)

# Create separate text trace positioned below nodes
text_x = []
text_y = []
text_labels = []

for widget_name, info in widgets.items():
    x, y = pos[widget_name]
    text_x.append(x)
    text_y.append(y - 25)  # Position text below the node
    
    # Truncate long names but keep readable
    display_name = widget_name
    if len(display_name) > 15:
        display_name = display_name[:13] + ".."
    
    text_labels.append(display_name)

text_trace = go.Scatter(
    x=text_x,
    y=text_y,
    mode='text',
    text=text_labels,
    textposition="middle center",
    textfont=dict(size=12, color='#333'),  # Increased font size and better contrast
    hoverinfo='none',
    showlegend=False
)

# Create the figure
fig = go.Figure(data=[node_trace, text_trace] + edge_traces)

# Add legend traces for categories
for category, color in category_colors.items():
    fig.add_trace(go.Scatter(
        x=[None],
        y=[None],
        mode='markers',
        marker=dict(size=15, color=color),
        name=category,
        showlegend=True
    ))

# Update layout with improved settings
fig.update_layout(
    title="Flutter Widget Hierarchy",
    showlegend=True,
    legend=dict(
        orientation='h',
        yanchor='bottom',
        y=1.02,
        xanchor='center',
        x=0.5
    ),
    hovermode='closest',
    xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
    yaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
    plot_bgcolor='white',
    font=dict(size=12)
)

# Save the chart
fig.write_image("flutter_widget_hierarchy.png")
print("Chart saved as flutter_widget_hierarchy.png")