import plotly.graph_objects as go

# Brand colors by layer
layer_colors = {
    'Presentation': '#1FB8CD',  # Strong cyan
    'Domain': '#FFC185',        # Light orange
    'Data': '#ECEBD5',          # Light green
    'External': '#5D878F'       # Cyan
}

# Node labels (<=15 chars each)
nodes = [
    # External (6)
    'OpenAIGemini', 'Firebase', 'CameraAPI', 'CanvasAPI', 'PaySys', 'CloudStore',
    # Data Src (3)
    'AIDataSrc', 'LocalDataSrc', 'APIDataSrc',
    # Repo Impl (3)
    'GarmentImpl', 'CustomerImpl', 'OrderImpl',
    # Domain Repo (3)
    'GarmentRepo', 'CustomerRepo', 'OrderRepo',
    # UseCase (3)
    'GenDesignUC', 'ProcessFitUC', 'CreateOrderUC',
    # Entities (1)
    'Entities',
    # ViewModel (4)
    'HomeVM', 'DesignVM', 'FittingVM', 'OrderVM',
    # View (4)
    'HomeView', 'DesignCanvas', 'VirtualFit', 'OrdersView',
    # Widgets (1)
    'Widgets'
]

# Layer assignment for colors
node_layers = [
    'External']*6 + ['Data']*3 + ['Data']*3 + ['Domain']*3 + ['Domain']*3 + ['Domain']*1 + ['Presentation']*4 + ['Presentation']*4 + ['Presentation']*1

node_colors = [layer_colors[layer] for layer in node_layers]

# Helper to get index
idx = {name: i for i, name in enumerate(nodes)}

links = []
vals = []

# External -> Data Src
for src in ['OpenAIGemini']:
    links.append((src, 'AIDataSrc'))
for src in ['Firebase', 'CloudStore']:
    links.append((src, 'LocalDataSrc'))
for src in ['CameraAPI', 'CanvasAPI', 'PaySys']:
    links.append((src, 'APIDataSrc'))

# Data Src -> Repo Impl
for ds in ['AIDataSrc', 'LocalDataSrc', 'APIDataSrc']:
    for impl in ['GarmentImpl', 'CustomerImpl', 'OrderImpl']:
        links.append((ds, impl))

# Repo Impl -> Domain Repo
repo_pairs = [
    ('GarmentImpl', 'GarmentRepo'),
    ('CustomerImpl', 'CustomerRepo'),
    ('OrderImpl', 'OrderRepo')
]
links.extend(repo_pairs)

# Domain Repo -> UseCases
for repo in ['GarmentRepo', 'CustomerRepo', 'OrderRepo']:
    for uc in ['GenDesignUC', 'ProcessFitUC', 'CreateOrderUC']:
        links.append((repo, uc))

# UseCases -> Entities
for uc in ['GenDesignUC', 'ProcessFitUC', 'CreateOrderUC']:
    links.append((uc, 'Entities'))

# UseCases -> ViewModels
vm_map = {
    'GenDesignUC': 'DesignVM',
    'ProcessFitUC': 'FittingVM',
    'CreateOrderUC': 'OrderVM'
}
for uc, vm in vm_map.items():
    links.append((uc, vm))

# ViewModel -> View
view_pairs = [
    ('HomeVM', 'HomeView'),
    ('DesignVM', 'DesignCanvas'),
    ('FittingVM', 'VirtualFit'),
    ('OrderVM', 'OrdersView')
]
links.extend(view_pairs)

# View -> Widgets
for view in ['HomeView', 'DesignCanvas', 'VirtualFit', 'OrdersView']:
    links.append((view, 'Widgets'))

# Build link dicts
source_indices = [idx[s] for s, t in links]
target_indices = [idx[t] for s, t in links]
values = [1]*len(links)

fig = go.Figure(data=go.Sankey(
    valueformat="d",
    arrangement='snap',
    node=dict(
        pad=10,
        thickness=15,
        line=dict(width=1, color='black'),
        label=nodes,
        color=node_colors
    ),
    link=dict(
        source=source_indices,
        target=target_indices,
        value=values,
        color='rgba(0,0,0,0.2)'
    )
))

# Title and legend (legend via dummy scatter)  
fig.update_layout(title_text='Flutter AI Tailor Arch',
                  legend=dict(orientation='h', yanchor='bottom', y=1.05, xanchor='center', x=0.5))

# Add custom legend
legend_x = [0.1, 0.3, 0.5, 0.7]
legend_y = [1.12]*4
legend_names = ['Presentation', 'Domain', 'Data', 'External']
legend_colors = [layer_colors[n] for n in legend_names]
fig.add_trace(go.Scatter(x=legend_x, y=legend_y,
                         mode='markers',
                         marker=dict(size=15, color=legend_colors),
                         text=legend_names,
                         showlegend=False,
                         hoverinfo='text'))

fig.write_image('flutter_architecture.png')