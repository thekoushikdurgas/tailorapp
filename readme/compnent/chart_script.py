import plotly.graph_objects as go
import pandas as pd

# Load the data
data = {"screens": [{"name": "Splash Screen", "category": "Authentication", "x": 50, "y": 50}, {"name": "Onboarding Screen", "category": "Authentication", "x": 50, "y": 150}, {"name": "Login Screen", "category": "Authentication", "x": 50, "y": 250}, {"name": "Registration Screen", "category": "Authentication", "x": 200, "y": 250}, {"name": "Email Verification Screen", "category": "Authentication", "x": 200, "y": 350}, {"name": "Profile Setup Screen", "category": "Authentication", "x": 200, "y": 450}, {"name": "Home Screen", "category": "Main", "x": 400, "y": 300}, {"name": "Design Studio Screen", "category": "Design", "x": 600, "y": 100}, {"name": "AI Design Assistant Screen", "category": "AI", "x": 800, "y": 100}, {"name": "Virtual Fitting Screen", "category": "AR/VR", "x": 600, "y": 200}, {"name": "Body Measurement Screen", "category": "Measurement", "x": 600, "y": 300}, {"name": "Size Recommendation Screen", "category": "Measurement", "x": 600, "y": 400}, {"name": "Order Summary Screen", "category": "Orders", "x": 600, "y": 500}, {"name": "Payment Screen", "category": "Payment", "x": 600, "y": 600}, {"name": "Order Confirmation Screen", "category": "Orders", "x": 600, "y": 700}, {"name": "Order Tracking Screen", "category": "Orders", "x": 800, "y": 700}, {"name": "Orders History Screen", "category": "Orders", "x": 200, "y": 500}, {"name": "Profile Screen", "category": "Profile", "x": 200, "y": 300}, {"name": "Settings Screen", "category": "Settings", "x": 50, "y": 300}, {"name": "My Designs Screen", "category": "Design", "x": 200, "y": 200}, {"name": "Support Screen", "category": "Support", "x": 400, "y": 500}]}

# Create DataFrame
df = pd.DataFrame(data['screens'])

# Map categories to colors as specified in instructions
# Authentication: Blue, Main: Green, Design: Purple, Orders: Orange, Profile: Red, Support: Gray
category_mapping = {
    'Authentication': ('Auth', '#2E86C1'),  # Blue
    'Main': ('Main', '#28B463'),           # Green  
    'Design': ('Design', '#8E44AD'),       # Purple
    'AI': ('Design', '#8E44AD'),           # Purple (part of Design)
    'AR/VR': ('Design', '#8E44AD'),        # Purple (part of Design)
    'Measurement': ('Design', '#8E44AD'),   # Purple (part of Design)
    'Orders': ('Orders', '#F39C12'),       # Orange
    'Payment': ('Orders', '#F39C12'),      # Orange (part of Orders)
    'Profile': ('Profile', '#E74C3C'),     # Red
    'Settings': ('Profile', '#E74C3C'),    # Red (part of Profile)
    'Support': ('Support', '#85929E')      # Gray
}

# Add mapped categories and colors
df['main_category'] = df['category'].map(lambda x: category_mapping[x][0])
df['color'] = df['category'].map(lambda x: category_mapping[x][1])

# Shorten screen names to fit 15 character limit
df['short_name'] = df['name'].str.replace(' Screen', '').str.replace('Screen', '')
df['short_name'] = df['short_name'].str[:13]  # Even shorter to fit better

# Create the figure
fig = go.Figure()

# Add screens as scatter points with larger size
for category in df['main_category'].unique():
    cat_data = df[df['main_category'] == category]
    fig.add_trace(go.Scatter(
        x=cat_data['x'],
        y=cat_data['y'],
        mode='markers+text',
        marker=dict(
            size=35,  # Larger nodes
            color=cat_data['color'].iloc[0],
            line=dict(width=3, color='white'),
            symbol='circle'
        ),
        text=cat_data['short_name'],
        textposition='middle center',
        textfont=dict(size=9, color='white', family='Arial Black'),
        name=category,
        hovertemplate='<b>%{text}</b><br>Category: ' + category + '<extra></extra>',
        cliponaxis=False
    ))

# Define navigation flows as arrows with better styling
flows = [
    # Authentication Flow
    (50, 50, 50, 150),    # Splash → Onboarding
    (50, 150, 50, 250),   # Onboarding → Login
    (50, 250, 200, 250),  # Login → Registration
    (200, 250, 200, 350), # Registration → Email Verification
    (200, 350, 200, 450), # Email Verification → Profile Setup
    (200, 450, 400, 300), # Profile Setup → Home
    
    # Design Flow
    (400, 300, 600, 100), # Home → Design Studio
    (600, 100, 800, 100), # Design Studio → AI Assistant
    (600, 100, 600, 200), # Design Studio → Virtual Fitting
    (600, 200, 600, 300), # Virtual Fitting → Body Measurement
    (600, 300, 600, 400), # Body Measurement → Size Recommendation
    
    # Order Flow
    (600, 400, 600, 500), # Size Recommendation → Order Summary
    (600, 500, 600, 600), # Order Summary → Payment
    (600, 600, 600, 700), # Payment → Order Confirmation
    (600, 700, 800, 700), # Order Confirmation → Order Tracking
    
    # Profile Flow
    (400, 300, 200, 300), # Home → Profile
    (200, 300, 50, 300),  # Profile → Settings
    (200, 300, 200, 500), # Profile → Orders History
    (200, 300, 200, 200), # Profile → My Designs
    
    # Support Flow
    (400, 300, 400, 500), # Home → Support
]

# Add arrows for flows with better visibility
for x0, y0, x1, y1 in flows:
    fig.add_annotation(
        x=x1, y=y1,
        ax=x0, ay=y0,
        xref='x', yref='y',
        axref='x', ayref='y',
        arrowhead=3,       # Larger arrowhead
        arrowsize=1.5,     # Bigger arrow
        arrowwidth=3,      # Thicker arrow
        arrowcolor='#34495E',  # Darker gray for better visibility
        opacity=0.8
    )

# Update axes to hide grid and labels but set proper range
fig.update_xaxes(
    showgrid=False, 
    zeroline=False, 
    showticklabels=False,
    range=[-20, 880]  # Proper range to show all nodes
)

fig.update_yaxes(
    showgrid=False, 
    zeroline=False, 
    showticklabels=False,
    range=[0, 750]  # Proper range to show all nodes
)

# Update layout
fig.update_layout(
    title='App Navigation Flow',
    showlegend=True,
    legend=dict(orientation='h', yanchor='bottom', y=1.05, xanchor='center', x=0.5),
    plot_bgcolor='white',
    paper_bgcolor='white'
)

# Save the chart
fig.write_image('navigation_flowchart.png')