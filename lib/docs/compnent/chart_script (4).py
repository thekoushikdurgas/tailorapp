import plotly.graph_objects as go
import plotly.express as px
import numpy as np

# Define the Firebase services and their positions with better spacing
services = {
    'Flutter App': {'x': 0, 'y': 0, 'color': '#FF6B35', 'size': 60},
    'Firebase Auth': {'x': -3, 'y': 3, 'color': '#FFC185', 'size': 40},
    'Cloud Firestore': {'x': 3, 'y': 3, 'color': '#1FB8CD', 'size': 40},
    'Firebase Storage': {'x': -3, 'y': -3, 'color': '#ECEBD5', 'size': 40},
    'Cloud Functions': {'x': 3, 'y': -3, 'color': '#5D878F', 'size': 40},
    'Firebase Analytics': {'x': -4.5, 'y': 0, 'color': '#D2BA4C', 'size': 35},
    'Firebase Messaging': {'x': 4.5, 'y': 0, 'color': '#B4413C', 'size': 35},
    'AI Services': {'x': 5.5, 'y': -2, 'color': '#964325', 'size': 30},
    'Payment APIs': {'x': 5.5, 'y': -1, 'color': '#944454', 'size': 30},
    'External APIs': {'x': 5.5, 'y': -3, 'color': '#13343B', 'size': 30}
}

# Define connections with specific labels and better positioning
connections = [
    ('Flutter App', 'Firebase Auth', 'Auth & Login'),
    ('Flutter App', 'Cloud Firestore', 'Data Sync'),
    ('Flutter App', 'Firebase Storage', 'File Upload'),
    ('Flutter App', 'Cloud Functions', 'API Calls'),
    ('Flutter App', 'Firebase Analytics', 'User Events'),
    ('Flutter App', 'Firebase Messaging', 'Push Notifs'),
    ('Firebase Auth', 'Cloud Firestore', 'User Data'),
    ('Cloud Firestore', 'Cloud Functions', 'Data Process'),
    ('Firebase Storage', 'Cloud Functions', 'File Process'),
    ('Cloud Functions', 'AI Services', 'ML Process'),
    ('Cloud Functions', 'Payment APIs', 'Payments'),
    ('Cloud Functions', 'External APIs', '3rd Party'),
    ('Firebase Messaging', 'Cloud Functions', 'Notifications')
]

# Create the network diagram
fig = go.Figure()

# Add edges (connections) without overlapping labels
for source, target, label in connections:
    source_pos = services[source]
    target_pos = services[target]
    
    # Calculate midpoint for label positioning
    mid_x = (source_pos['x'] + target_pos['x']) / 2
    mid_y = (source_pos['y'] + target_pos['y']) / 2
    
    # Add connection line
    fig.add_trace(go.Scatter(
        x=[source_pos['x'], target_pos['x']],
        y=[source_pos['y'], target_pos['y']],
        mode='lines',
        line=dict(color='#FF6B35', width=4),
        hoverinfo='text',
        hovertext=f"{source} → {target}<br>{label}",
        showlegend=False,
        opacity=0.8
    ))
    
    # Add arrowhead using annotation
    dx = target_pos['x'] - source_pos['x']
    dy = target_pos['y'] - source_pos['y']
    
    # Position arrow closer to target
    arrow_x = source_pos['x'] + dx * 0.8
    arrow_y = source_pos['y'] + dy * 0.8
    
    fig.add_annotation(
        x=arrow_x,
        y=arrow_y,
        ax=source_pos['x'] + dx * 0.6,
        ay=source_pos['y'] + dy * 0.6,
        xref='x', yref='y',
        axref='x', ayref='y',
        arrowhead=3,
        arrowsize=2,
        arrowwidth=3,
        arrowcolor='#FF6B35',
        showarrow=True
    )

# Add connection labels as separate text elements with better visibility
label_positions = [
    (-1.5, 1.5, 'Auth & Login'),
    (1.5, 1.5, 'Data Sync'),
    (-1.5, -1.5, 'File Upload'),
    (1.5, -1.5, 'API Calls'),
    (-2.25, 0, 'User Events'),
    (2.25, 0, 'Push Notifs'),
    (0, 3, 'User Data'),
    (3, 0, 'Data Process'),
    (0, -3, 'File Process'),
    (4.25, -1.5, 'ML Process'),
    (4.25, -0.5, 'Payments'),
    (4.25, -2.5, '3rd Party'),
    (4.25, -0.5, 'Notifications')
]

for i, (lx, ly, label_text) in enumerate(label_positions):
    if i < len(connections):  # Avoid index out of range
        fig.add_trace(go.Scatter(
            x=[lx],
            y=[ly],
            mode='text',
            text=label_text,
            textfont=dict(size=11, color='#FF6B35', family='Arial Bold'),
            hoverinfo='none',
            showlegend=False
        ))

# Add nodes with better text visibility
for service, props in services.items():
    # Abbreviate service names to fit 15 character limit
    display_name = service.replace('Firebase ', '').replace('Cloud ', '')
    if service == 'Firebase Analytics':
        display_name = 'Analytics'
    elif service == 'Firebase Messaging':
        display_name = 'Messaging'
    elif service == 'Firebase Storage':
        display_name = 'Storage'
    elif service == 'Cloud Functions':
        display_name = 'Functions'
    elif service == 'Cloud Firestore':
        display_name = 'Firestore'
    elif service == 'Firebase Auth':
        display_name = 'Auth'
    elif service == 'Payment APIs':
        display_name = 'Payment'
    elif service == 'External APIs':
        display_name = 'External'
    elif service == 'AI Services':
        display_name = 'AI/ML'
    
    fig.add_trace(go.Scatter(
        x=[props['x']],
        y=[props['y']],
        mode='markers+text',
        marker=dict(
            size=props['size'],
            color=props['color'],
            line=dict(width=4, color='#FF6B35')
        ),
        text=display_name,
        textposition='middle center',
        textfont=dict(size=13, color='white', family='Arial Black'),
        hoverinfo='text',
        hovertext=f"{service}<br>Integration point",
        showlegend=False
    ))

# Update layout with Firebase theme
fig.update_layout(
    title='Firebase Integration Flow',
    xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
    yaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
    plot_bgcolor='rgba(0,0,0,0)',
    paper_bgcolor='white',
    showlegend=False,
    hovermode='closest'
)

fig.update_xaxes(range=[-6, 7])
fig.update_yaxes(range=[-4.5, 4.5])

# Save the chart
fig.write_image('firebase_integration_diagram.png')