import plotly.graph_objects as go
import plotly.io as pio

# Create a structured architecture diagram using scatter plot with shapes
fig = go.Figure()

# Define positions for different layers
# Frontend Layer (top)
frontend_y = 4
frontend_components = [
    ("UI Components", 1, frontend_y),
    ("State Mgmt", 2, frontend_y),
    ("Navigation", 3, frontend_y),
    ("Auth Screen", 4, frontend_y),
    ("Design Studio", 5, frontend_y),
    ("Virtual Fit", 6, frontend_y)
]

# Integration Layer (middle)
integration_y = 3
integration_components = [
    ("Firebase Auth", 1, integration_y),
    ("Firestore", 2, integration_y),
    ("Storage", 3, integration_y),
    ("AI Design API", 4, integration_y),
    ("Size Rec", 5, integration_y),
    ("Stripe", 6, integration_y)
]

# Backend Layer (bottom)
backend_y = 2
backend_components = [
    ("Payment Proc", 1, backend_y),
    ("Order Svc", 2, backend_y),
    ("AI Integration", 3, backend_y),
    ("ML Services", 4, backend_y),
    ("Database", 5, backend_y),
    ("File Storage", 6, backend_y)
]

# Data Flow Layer (very bottom)
dataflow_y = 1
dataflow_components = [
    ("User Auth", 1.5, dataflow_y),
    ("Design Flow", 2.5, dataflow_y),
    ("Order Flow", 3.5, dataflow_y),
    ("Real-time", 4.5, dataflow_y)
]

# Add all components as scatter points
all_components = frontend_components + integration_components + backend_components + dataflow_components

# Frontend layer
fig.add_trace(go.Scatter(
    x=[comp[1] for comp in frontend_components],
    y=[comp[2] for comp in frontend_components],
    mode='markers+text',
    text=[comp[0] for comp in frontend_components],
    textposition='middle center',
    marker=dict(size=60, color='#1FB8CD', symbol='square'),
    name='Frontend',
    showlegend=True
))

# Integration layer
fig.add_trace(go.Scatter(
    x=[comp[1] for comp in integration_components],
    y=[comp[2] for comp in integration_components],
    mode='markers+text',
    text=[comp[0] for comp in integration_components],
    textposition='middle center',
    marker=dict(size=60, color='#FFC185', symbol='square'),
    name='Integration',
    showlegend=True
))

# Backend layer
fig.add_trace(go.Scatter(
    x=[comp[1] for comp in backend_components],
    y=[comp[2] for comp in backend_components],
    mode='markers+text',
    text=[comp[0] for comp in backend_components],
    textposition='middle center',
    marker=dict(size=60, color='#ECEBD5', symbol='square'),
    name='Backend',
    showlegend=True
))

# Data flow layer
fig.add_trace(go.Scatter(
    x=[comp[1] for comp in dataflow_components],
    y=[comp[2] for comp in dataflow_components],
    mode='markers+text',
    text=[comp[0] for comp in dataflow_components],
    textposition='middle center',
    marker=dict(size=60, color='#5D878F', symbol='square'),
    name='Data Flow',
    showlegend=True
))

# Add arrows showing data flow connections
arrow_connections = [
    # Frontend to Integration
    (4, frontend_y, 1, integration_y),  # Auth Screen -> Firebase Auth
    (5, frontend_y, 4, integration_y),  # Design Studio -> AI Design API
    (6, frontend_y, 5, integration_y),  # Virtual Fit -> Size Rec
    
    # Integration to Backend
    (1, integration_y, 1, backend_y),   # Firebase Auth -> Payment Proc
    (2, integration_y, 2, backend_y),   # Firestore -> Order Svc
    (4, integration_y, 3, backend_y),   # AI Design API -> AI Integration
    (5, integration_y, 4, backend_y),   # Size Rec -> ML Services
    
    # Backend to Data Flow
    (1, backend_y, 1.5, dataflow_y),    # Payment Proc -> User Auth
    (2, backend_y, 3.5, dataflow_y),    # Order Svc -> Order Flow
    (3, backend_y, 2.5, dataflow_y),    # AI Integration -> Design Flow
    (4, backend_y, 4.5, dataflow_y),    # ML Services -> Real-time
]

# Add arrows as shapes
for start_x, start_y, end_x, end_y in arrow_connections:
    fig.add_shape(
        type="line",
        x0=start_x, y0=start_y-0.1,
        x1=end_x, y1=end_y+0.1,
        line=dict(color="#D2BA4C", width=2),
    )
    
    # Add arrowhead
    fig.add_shape(
        type="circle",
        x0=end_x-0.05, y0=end_y+0.05,
        x1=end_x+0.05, y1=end_y+0.15,
        fillcolor="#D2BA4C",
        line=dict(color="#D2BA4C", width=1)
    )

# Update layout
fig.update_layout(
    title="AI Tailoring Platform Architecture",
    xaxis=dict(
        showgrid=False,
        showticklabels=False,
        zeroline=False,
        range=[0, 7]
    ),
    yaxis=dict(
        showgrid=False,
        showticklabels=False,
        zeroline=False,
        range=[0.5, 4.5]
    ),
    plot_bgcolor='white',
    legend=dict(orientation='h', yanchor='bottom', y=1.05, xanchor='center', x=0.5),
    font=dict(size=10)
)

fig.write_image("ai_tailoring_architecture.png")