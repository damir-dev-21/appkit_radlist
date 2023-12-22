import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'speed_dial.widget.dart';

/// A speed dial that initially renders a FAB with a plus icon, which animates to
/// a close icon when opened. The color of the FAB also changes to red when the speed
/// dial is opened.
class PlusSpeedDial extends StatefulWidget {
  final List<SpeedDialChild> children;
  final String? heroTag;

  PlusSpeedDial({
    Key? key,
    required this.children,
    this.heroTag,
  }) : super(key: key);

  @override
  _PlusSpeedDialState createState() => _PlusSpeedDialState();
}

class _PlusSpeedDialState extends State<PlusSpeedDial> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _rotationAnimation = Tween(begin: 0.0, end: 0.375)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = theme(context);
    return SpeedDial(
      heroTag: widget.heroTag ?? '',
      overlayOpacity: 0.4,
      overlayBlurRadius: 3,
      backgroundColor: _isOpen ? _theme.errorColor : _theme.accentColor,
      elevation: 4,
      animationSpeed: 100,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Icon(Icons.add),
      ),
      onOpen: () {
        setState(() {
          _isOpen = true;
          _controller.forward();
        });
      },
      onClose: () {
        setState(() {
          _isOpen = false;
          _controller.reverse();
        });
      },
      children: widget.children,
    );
  }
}
