import plotly.graph_objects as go
import plotly.io as pio

# Data from the provided JSON
workflow_data = {
    "workflow": [
        {"phase": "User Input", "steps": ["Body Measurements", "Style Preferences", "Fabric Choice", "Design Inspiration"]}, 
        {"phase": "AI Processing", "steps": ["Analyze Input", "Generate Suggestions", "Create Patterns", "Calculate Fit"]}, 
        {"phase": "Interactive Design", "steps": ["Review Suggestions", "Customize Design", "Adjust Colors", "Virtual Fitting"]}, 
        {"phase": "Finalization", "steps": ["Final Approval", "Technical Drawings", "Calculate Pricing", "Create Order"]}
    ], 
    "decision_points": ["User Satisfied?", "Design Approved?", "Fit Acceptable?"]
}

# Brand colors to use
brand_colors = ["#1FB8CD", "#FFC185", "#ECEBD5", "#5D878F"]

# Create figure
fig = go.Figure()

# Abbreviate step names to fit 15 char limit
step_abbreviations = [
    ["Body Measure", "Style Pref", "Fabric Choice", "Design Inspir"],
    ["Analyze Input", "Gen Suggest", "Create Pattern", "Calc Fit"],
    ["Review Suggest", "Custom Design", "Adjust Color", "Virtual Fit"],
    ["Final Approve", "Tech Drawing", "Calc Price", "Create Order"]
]

# Abbreviate phase names to fit 15 char limit
phase_abbreviations = ["User Input", "AI Process", "Interactive", "Finalization"]

# Define positions for each phase - spread out more horizontally
phase_x_positions = [1, 4, 7, 10]
phase_y = 8

# Add phase headers as rectangles
for i, (phase, x_pos) in enumerate(zip(phase_abbreviations, phase_x_positions)):
    # Phase header rectangle
    fig.add_shape(
        type="rect",
        x0=x_pos-0.8, y0=phase_y-0.3,
        x1=x_pos+0.8, y1=phase_y+0.3,
        fillcolor=brand_colors[i],
        opacity=0.8,
        line=dict(width=2, color=brand_colors[i])
    )
    
    # Phase header text
    fig.add_trace(go.Scatter(
        x=[x_pos], y=[phase_y],
        mode='text',
        text=phase,
        textfont=dict(size=14, color='white'),
        showlegend=False,
        hoverinfo='skip',
        cliponaxis=False
    ))

# Add steps for each phase in vertical layout
for phase_idx, (steps, x_pos) in enumerate(zip(step_abbreviations, phase_x_positions)):
    step_y_positions = [6.5, 5.5, 4.5, 3.5]
    
    for step_idx, (step, y_pos) in enumerate(zip(steps, step_y_positions)):
        # Step rectangle
        fig.add_shape(
            type="rect",
            x0=x_pos-0.7, y0=y_pos-0.25,
            x1=x_pos+0.7, y1=y_pos+0.25,
            fillcolor=brand_colors[phase_idx],
            opacity=0.4,
            line=dict(width=1, color=brand_colors[phase_idx])
        )
        
        # Step text
        fig.add_trace(go.Scatter(
            x=[x_pos], y=[y_pos],
            mode='text',
            text=step,
            textfont=dict(size=11, color='black'),
            showlegend=False,
            hoverinfo='text',
            hovertext=f"Phase: {phase_abbreviations[phase_idx]}<br>Step: {step}",
            cliponaxis=False
        ))

# Add arrows between phases
arrow_x_positions = [2.5, 5.5, 8.5]
arrow_y = 6

for x_pos in arrow_x_positions:
    fig.add_trace(go.Scatter(
        x=[x_pos], y=[arrow_y],
        mode='markers',
        marker=dict(size=25, color='#13343B', symbol='triangle-right'),
        showlegend=False,
        hoverinfo='skip',
        cliponaxis=False
    ))

# Add decision points
decision_x_positions = [2.5, 5.5, 8.5]
decision_y = 2
decision_abbrev = ["User OK?", "Design OK?", "Fit OK?"]

for i, (x_pos, decision) in enumerate(zip(decision_x_positions, decision_abbrev)):
    # Decision diamond shape
    fig.add_shape(
        type="rect",
        x0=x_pos-0.6, y0=decision_y-0.3,
        x1=x_pos+0.6, y1=decision_y+0.3,
        fillcolor='#DB4545',
        opacity=0.7,
        line=dict(width=2, color='#DB4545')
    )
    
    # Decision text
    fig.add_trace(go.Scatter(
        x=[x_pos], y=[decision_y],
        mode='text',
        text=decision,
        textfont=dict(size=12, color='white'),
        showlegend=False,
        hoverinfo='text',
        hovertext=f"Decision: {decision}",
        cliponaxis=False
    ))

# Add feedback arrows (iteration loops)
feedback_x_positions = [1.8, 4.8, 7.8]
feedback_y = 2.8

for x_pos in feedback_x_positions:
    fig.add_trace(go.Scatter(
        x=[x_pos], y=[feedback_y],
        mode='markers',
        marker=dict(size=20, color='#B4413C', symbol='triangle-up'),
        showlegend=False,
        hoverinfo='skip',
        cliponaxis=False
    ))

# Add vertical arrows from phases to decision points
for x_pos in phase_x_positions[:-1]:  # Exclude last phase
    fig.add_trace(go.Scatter(
        x=[x_pos], y=[3],
        mode='markers',
        marker=dict(size=20, color='#13343B', symbol='triangle-down'),
        showlegend=False,
        hoverinfo='skip',
        cliponaxis=False
    ))

# Update layout
fig.update_layout(
    title="AI Garment Design Workflow",
    xaxis=dict(showgrid=False, showticklabels=False, zeroline=False),
    yaxis=dict(showgrid=False, showticklabels=False, zeroline=False),
    plot_bgcolor='white',
    showlegend=False
)

fig.update_xaxes(range=[0, 11])
fig.update_yaxes(range=[1, 9])

# Save the chart
fig.write_image("ai_garment_workflow.png")