import 'dart:async';
import 'package:flutter/material.dart';
import 'flip_widget.dart';

class FlipClockPage extends StatefulWidget {
  const FlipClockPage({super.key});

  @override
  State<FlipClockPage> createState() => _FlipClockPageState();
}

class _FlipClockPageState extends State<FlipClockPage> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dark theme for the clock page
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Flip Clock'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDigitGroup(_currentTime.hour, 'HOURS'),
              _buildSeparator(),
              _buildDigitGroup(_currentTime.minute, 'MINUTES'),
              _buildSeparator(),
              _buildDigitGroup(_currentTime.second, 'SECONDS'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(),
          const SizedBox(height: 20),
          _buildDot(),
          const SizedBox(height: 20), // Space for label
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.white38,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDigitGroup(int value, String label) {
    // Split value into tens and ones
    final tens = value ~/ 10;
    final ones = value % 10;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildFlipDigit(tens),
            const SizedBox(width: 4),
            _buildFlipDigit(ones),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFlipDigit(int digit) {
    return FlipWidget<int>(
      value: digit,
      itemBuilder: (context, value) => _buildDigitCard(value),
    );
  }

  Widget _buildDigitCard(int value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      width: 80, // Fixed width for consistency
      height: 120, // Fixed height
      alignment: Alignment.center,
      child: Text(
        value.toString(),
        style: const TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE0E0E0),
          height: 1.0, // Tight line height
        ),
      ),
    );
  }
}
