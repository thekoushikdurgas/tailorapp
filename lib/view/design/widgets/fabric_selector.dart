import 'package:flutter/material.dart';

class FabricSelector extends StatelessWidget {
  final String selectedFabric;
  final Function(String) onFabricChanged;

  const FabricSelector({
    super.key,
    required this.selectedFabric,
    required this.onFabricChanged,
  });

  static const List<Map<String, dynamic>> fabricOptions = [
    {
      'name': 'Cotton',
      'color': Color(0xFFF5F5DC),
      'description': 'Breathable and comfortable',
      'icon': Icons.eco,
    },
    {
      'name': 'Silk',
      'color': Color(0xFFE6E6FA),
      'description': 'Luxurious and smooth',
      'icon': Icons.diamond,
    },
    {
      'name': 'Wool',
      'color': Color(0xFFDEB887),
      'description': 'Warm and durable',
      'icon': Icons.wb_sunny,
    },
    {
      'name': 'Linen',
      'color': Color(0xFFFAF0E6),
      'description': 'Light and airy',
      'icon': Icons.air,
    },
    {
      'name': 'Denim',
      'color': Color(0xFF4682B4),
      'description': 'Sturdy and casual',
      'icon': Icons.work,
    },
    {
      'name': 'Satin',
      'color': Color(0xFFFFF8DC),
      'description': 'Elegant and shiny',
      'icon': Icons.star,
    },
    {
      'name': 'Velvet',
      'color': Color(0xFF8B0000),
      'description': 'Rich and textured',
      'icon': Icons.texture,
    },
    {
      'name': 'Chiffon',
      'color': Color(0xFFF0F8FF),
      'description': 'Sheer and flowing',
      'icon': Icons.waves,
    },
    {
      'name': 'Polyester',
      'color': Color(0xFFE0E0E0),
      'description': 'Easy care synthetic',
      'icon': Icons.science,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: fabricOptions.length,
        itemBuilder: (context, index) {
          final fabric = fabricOptions[index];
          final isSelected = selectedFabric == fabric['name'];

          return GestureDetector(
            onTap: () => onFabricChanged(fabric['name'] as String),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fabric preview circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: fabric['color'] as Color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      fabric['icon'] as IconData,
                      size: 20,
                      color: _getIconColor(fabric['color'] as Color),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Fabric name
                  Text(
                    fabric['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue[700] : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),

                  // Fabric description
                  Text(
                    fabric['description'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getIconColor(Color backgroundColor) {
    // Calculate brightness to determine appropriate icon color
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.grey[700]! : Colors.white;
  }
}

class FabricDetailCard extends StatelessWidget {
  final String fabricName;
  final String description;
  final List<String> properties;
  final Color color;

  const FabricDetailCard({
    super.key,
    required this.fabricName,
    required this.description,
    required this.properties,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                fabricName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: properties.map((property) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  property,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
