import 'package:flutter/material.dart';

class PracticeAreaSelector extends StatefulWidget {
  const PracticeAreaSelector({super.key});

  @override
  _PracticeAreaSelectorState createState() => _PracticeAreaSelectorState();
}

class _PracticeAreaSelectorState extends State<PracticeAreaSelector> {
  final TextEditingController specializationController = TextEditingController();

  // List of practice areas
  final List<String> practiceAreas = [
    'Consumer Protection',
    'Criminal Matters',
    'Cyber Crime',
    'Drugs and Narcotics',
    'Environmental Protection',
    'Human Rights',
    'IP and Trademarks',
    'Service Matters',
    'Suits and Recovery',
    'Tax and Taxation',
    'Trust and Charity',
    'Companies and Securities',
    'Family and Inheritance',
    'Property and Real Estate',
    'Anti-Corruption',
    'Banking and Finance',
    'Others',
  ];

  // To hold selected practice areas
  List<String> selectedPracticeAreas = [];

  // Display dialog to select practice areas
  Future<void> _selectPracticeAreas() async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          options: practiceAreas,
          initialSelected: selectedPracticeAreas,
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedPracticeAreas = selected;
        specializationController.text = selectedPracticeAreas.join(', ');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _selectPracticeAreas,
          child: AbsorbPointer(
            child: TextFormField(
              controller: specializationController,
              decoration: const InputDecoration(
                hintText: 'Select Practice Area(s) *',
                icon: Icon(Icons.library_books),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<String> options;
  final List<String> initialSelected;

  const MultiSelectDialog({super.key, required this.options, required this.initialSelected});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> selectedValues;

  @override
  void initState() {
    super.initState();
    selectedValues = List.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Practice Area(s)"),
      content: SingleChildScrollView(
        child: Column(
          children: widget.options.map((option) {
            final isSelected = selectedValues.contains(option);
            return CheckboxListTile(
              title: Text(option),
              value: isSelected,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    selectedValues.add(option);
                  } else {
                    selectedValues.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedValues);
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
