import 'package:flutter/material.dart';
import 'package:tailorapp/view/design/widgets/ai_suggestions_panel.dart';

class AISuggestionsPage extends StatelessWidget {
  const AISuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Suggestions')),
      body: AISuggestionsPanel(
        garmentType: 'shirt',
        selectedColor: Colors.blue,
        selectedFabric: 'Cotton',
        onApplySuggestion: (suggestion) {
          // Handle suggestion application
          Navigator.of(context).pop();
        },
        isGenerating: false,
      ),
    );
  }
}
