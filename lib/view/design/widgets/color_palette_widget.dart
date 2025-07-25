import 'package:flutter/material.dart';

class ColorPaletteWidget extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;
  final Function(Color) onColorChanged;

  const ColorPaletteWidget({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = selectedColor.toARGB32() == color.toARGB32();

          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  if (isSelected) ...[
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: _getContrastColor(color),
                      size: 20,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }
}

class ColorPaletteSelector extends StatefulWidget {
  final Color selectedColor;
  final Function(Color) onColorChanged;

  const ColorPaletteSelector({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPaletteSelector> createState() => _ColorPaletteSelectorState();
}

class _ColorPaletteSelectorState extends State<ColorPaletteSelector> {
  int selectedPaletteIndex = 0;

  final List<Map<String, dynamic>> colorPalettes = [
    {
      'name': 'Professional',
      'colors': [
        const Color(0xFF1565C0), // Navy Blue
        const Color(0xFF2E2E2E), // Charcoal
        const Color(0xFF424242), // Dark Grey
        const Color(0xFF616161), // Medium Grey
        const Color(0xFF37474F), // Blue Grey
        const Color(0xFF4A148C), // Deep Purple
        const Color(0xFF006064), // Teal
        const Color(0xFF1B5E20), // Dark Green
        const Color(0xFF8D6E63), // Brown
        const Color(0xFFFFFFFF), // White
        const Color(0xFFF5F5F5), // Light Grey
        const Color(0xFFE0E0E0), // Silver
      ],
    },
    {
      'name': 'Casual',
      'colors': [
        const Color(0xFF42A5F5), // Light Blue
        const Color(0xFF66BB6A), // Light Green
        const Color(0xFFFF7043), // Orange
        const Color(0xFFEF5350), // Red
        const Color(0xFFAB47BC), // Purple
        const Color(0xFF26A69A), // Teal
        const Color(0xFFFFCA28), // Amber
        const Color(0xFF8D6E63), // Brown
        const Color(0xFF78909C), // Blue Grey
        const Color(0xFFFFA726), // Orange
        const Color(0xFF29B6F6), // Light Blue
        const Color(0xFF9CCC65), // Light Green
      ],
    },
    {
      'name': 'Elegant',
      'colors': [
        const Color(0xFF000000), // Black
        const Color(0xFF212121), // Dark Grey
        const Color(0xFF8E24AA), // Purple
        const Color(0xFF6A1B9A), // Deep Purple
        const Color(0xFF1A237E), // Indigo
        const Color(0xFF0D47A1), // Blue
        const Color(0xFF004D40), // Teal
        const Color(0xFF3E2723), // Brown
        const Color(0xFFAD1457), // Pink
        const Color(0xFFD81B60), // Deep Pink
        const Color(0xFFE91E63), // Pink
        const Color(0xFFFFFFFF), // White
      ],
    },
    {
      'name': 'Seasonal',
      'colors': [
        const Color(0xFFFF8A65), // Deep Orange
        const Color(0xFFFFB74D), // Orange
        const Color(0xFFAED581), // Light Green
        const Color(0xFF81C784), // Green
        const Color(0xFF64B5F6), // Blue
        const Color(0xFF9575CD), // Purple
        const Color(0xFFBA68C8), // Purple
        const Color(0xFFF06292), // Pink
        const Color(0xFFEF5350), // Red
        const Color(0xFFFFD54F), // Yellow
        const Color(0xFF4DB6AC), // Teal
        const Color(0xFF90A4AE), // Blue Grey
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Palette selector tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              colorPalettes.length,
              (index) => GestureDetector(
                onTap: () => setState(() => selectedPaletteIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selectedPaletteIndex == index
                        ? Colors.blue[600]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    colorPalettes[index]['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selectedPaletteIndex == index
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Color grid
        ColorPaletteWidget(
          colors: colorPalettes[selectedPaletteIndex]['colors'],
          selectedColor: widget.selectedColor,
          onColorChanged: widget.onColorChanged,
        ),

        // Custom color picker button
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCustomColorPicker(context),
            icon: Icon(
              Icons.palette,
              size: 16,
              color: Colors.grey[600],
            ),
            label: Text(
              'Custom Color',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCustomColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: const SingleChildScrollView(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Center(
                child: Text(
                  'Color Picker Coming Soon!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Apply custom color
                widget.onColorChanged(Colors.purple[700]!);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
