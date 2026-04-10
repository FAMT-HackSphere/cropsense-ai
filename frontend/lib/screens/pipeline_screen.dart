import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_plan_provider.dart';
import 'soil_input_screen.dart';
import 'crop_result_screen.dart';
import 'explanation_screen.dart';
import 'fertilizer_screen.dart';
import 'rotation_screen.dart';
import 'economic_screen.dart';
import 'final_report_screen.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  final PageController _pageController = PageController();

  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent manual swipe if data is missing
        children: [
          SoilInputScreen(onNext: _nextPage),
          CropResultScreen(onNext: _nextPage),
          ExplanationScreen(onNext: _nextPage),
          FertilizerScreen(onNext: _nextPage),
          RotationScreen(onNext: _nextPage),
          EconomicScreen(onNext: _nextPage),
          FinalReportScreen(onReset: () {
            context.read<CropPlanProvider>().reset();
            Navigator.pop(context); // Go back to Home
          }),
        ],
      ),
    );
  }
}
