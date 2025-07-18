import 'package:flutter/material.dart';

class AISuggestionsPanel extends StatefulWidget {
  final String garmentType;
  final Color selectedColor;
  final String selectedFabric;
  final Function(Map<String, dynamic>) onApplySuggestion;
  final bool isGenerating;

  const AISuggestionsPanel({
    super.key,
    required this.garmentType,
    required this.selectedColor,
    required this.selectedFabric,
    required this.onApplySuggestion,
    required this.isGenerating,
  });

  @override
  State<AISuggestionsPanel> createState() => _AISuggestionsPanelState();
}

class _AISuggestionsPanelState extends State<AISuggestionsPanel> {
  List<Map<String, dynamic>> suggestions = [];

  @override
  void initState() {
    super.initState();
    _generateMockSuggestions();
  }

  void _generateMockSuggestions() {
    // Mock AI suggestions based on garment type
    suggestions = _getMockSuggestions(widget.garmentType);
  }

  List<Map<String, dynamic>> _getMockSuggestions(String garmentType) {
    switch (garmentType) {
      case 'shirt':
        return [
          {
            'title': 'Classic Business',
            'description':
                'Perfect for professional settings with clean lines and structured fit.',
            'color': 'Navy',
            'fabric': 'Cotton',
            'pattern': 'Solid',
            'confidence': 0.92,
            'features': ['Button-down collar', 'French cuffs', 'Chest pocket'],
            'occasion': 'Business',
            'price': '\$89',
          },
          {
            'title': 'Casual Oxford',
            'description': 'Relaxed fit with subtle texture for weekend wear.',
            'color': 'Light Blue',
            'fabric': 'Cotton',
            'pattern': 'Subtle Texture',
            'confidence': 0.87,
            'features': ['Button-down collar', 'Regular fit', 'Side vents'],
            'occasion': 'Casual',
            'price': '\$65',
          },
          {
            'title': 'Modern Slim',
            'description':
                'Contemporary cut with sharp tailoring for young professionals.',
            'color': 'White',
            'fabric': 'Cotton Blend',
            'pattern': 'Solid',
            'confidence': 0.84,
            'features': ['Spread collar', 'Slim fit', 'No pocket'],
            'occasion': 'Modern',
            'price': '\$72',
          },
        ];
      case 'dress':
        return [
          {
            'title': 'A-Line Elegant',
            'description': 'Timeless silhouette that flatters all body types.',
            'color': 'Navy',
            'fabric': 'Silk',
            'pattern': 'Solid',
            'confidence': 0.91,
            'features': ['A-line cut', 'Knee length', 'Short sleeves'],
            'occasion': 'Formal',
            'price': '\$145',
          },
          {
            'title': 'Wrap Style',
            'description': 'Flattering wrap design with adjustable fit.',
            'color': 'Burgundy',
            'fabric': 'Jersey',
            'pattern': 'Solid',
            'confidence': 0.88,
            'features': ['Wrap style', 'Midi length', '3/4 sleeves'],
            'occasion': 'Versatile',
            'price': '\$95',
          },
        ];
      default:
        return [
          {
            'title': 'AI Recommended',
            'description': 'Smart design optimized for your preferences.',
            'color': 'Blue',
            'fabric': widget.selectedFabric,
            'pattern': 'Solid',
            'confidence': 0.85,
            'features': ['Modern cut', 'Comfortable fit'],
            'occasion': 'Versatile',
            'price': '\$89',
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Loading state
          if (widget.isGenerating) ...[
            _buildLoadingState(),
          ] else ...[
            // Suggestions list
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return _buildSuggestionCard(suggestions[index]);
                },
              ),
            ),
          ],

          // Generate more button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.isGenerating ? null : _generateMore,
              icon: widget.isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label:
                  Text(widget.isGenerating ? 'Generating...' : 'Generate More'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.blue[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.blue[600],
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI is analyzing your preferences...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Creating personalized ${widget.garmentType} suggestions',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header with confidence
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestion['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(suggestion['confidence'] * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            suggestion['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Properties
          _buildPropertyRow('Color', suggestion['color']),
          _buildPropertyRow('Fabric', suggestion['fabric']),
          _buildPropertyRow('Pattern', suggestion['pattern']),
          _buildPropertyRow('Occasion', suggestion['occasion']),
          const SizedBox(height: 12),

          // Features
          if (suggestion['features'] != null) ...[
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (suggestion['features'] as List<String>).map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[700],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Price and apply button
          Row(
            children: [
              Text(
                suggestion['price'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => widget.onApplySuggestion(suggestion),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _generateMore() {
    setState(() {
      _generateMockSuggestions();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generated new AI suggestions'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
