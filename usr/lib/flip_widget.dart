import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that animates a flip effect when its [value] changes.
class FlipWidget<T> extends StatefulWidget {
  final T value;
  final Widget Function(BuildContext context, T value) itemBuilder;
  final Duration duration;
  final double perspective;

  const FlipWidget({
    super.key,
    required this.value,
    required this.itemBuilder,
    this.duration = const Duration(milliseconds: 450),
    this.perspective = 0.006,
  });

  @override
  State<FlipWidget<T>> createState() => _FlipWidgetState<T>();
}

class _FlipWidgetState<T> extends State<FlipWidget<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  T? _oldValue;
  T? _newValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _newValue = widget.value;
  }

  @override
  void didUpdateWidget(FlipWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _oldValue = oldWidget.value;
      _newValue = widget.value;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // If not animating or just initialized, show the current value
        if (!_controller.isAnimating && _oldValue == null) {
          return widget.itemBuilder(context, widget.value);
        }

        // If animation finished, show the new value directly
        if (_controller.isCompleted) {
          return widget.itemBuilder(context, widget.value);
        }

        // During animation
        final oldValue = _oldValue ?? widget.value;
        final newValue = _newValue ?? widget.value;

        // We need to render the "halves"
        // 1. Top half of New Value (Background Top)
        // 2. Bottom half of Old Value (Background Bottom)
        // 3. The Flap:
        //    - Front: Top half of Old Value
        //    - Back: Bottom half of New Value

        return Stack(
          fit: StackFit.loose,
          children: [
            // Static Background
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Half of New Value
                _buildHalf(context, newValue, Alignment.topCenter),
                // Bottom Half of Old Value
                _buildHalf(context, oldValue, Alignment.bottomCenter),
              ],
            ),

            // The Flap
            // We position it to cover the whole area, but we will manipulate transforms
            Positioned.fill(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The flipping part
                  Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, widget.perspective)
                      ..rotateX(_animation.value),
                    alignment: Alignment.bottomCenter,
                    child: _animation.value < (math.pi / 2)
                        ? _buildHalf(context, oldValue, Alignment.topCenter)
                        : Transform(
                            transform: Matrix4.identity()..rotateX(math.pi),
                            alignment: Alignment.center,
                            child: _buildHalf(
                                context, newValue, Alignment.bottomCenter),
                          ),
                  ),
                  // Spacer to fill the bottom half space so the column matches size
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHalf(BuildContext context, T value, Alignment alignment) {
    return ClipRect(
      child: Align(
        alignment: alignment,
        heightFactor: 0.5,
        child: widget.itemBuilder(context, value),
      ),
    );
  }
}
