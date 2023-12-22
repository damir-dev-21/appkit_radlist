import 'package:appkit/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppSwitch extends StatefulWidget {
  final bool isSwitched;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Duration duration;
  final bool disabled;

  const AppSwitch({
    Key? key,
    required this.isSwitched,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.duration = const Duration(milliseconds: 150),
    this.disabled = false,
  }) : super(key: key);

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> with SingleTickerProviderStateMixin {
  late Animation _toggleAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: widget.isSwitched ? 1.0 : 0.0,
      duration: widget.duration,
    );
    _toggleAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSwitched == widget.isSwitched) return;

    if (widget.isSwitched)
      _animationController.forward();
    else
      _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Color _toggleColor = Colors.white;
    Color _switchColor = Colors.white;
    final themeData = theme(context);

    if (widget.isSwitched) {
      _switchColor = widget.activeColor ?? themeData.accentColor;
    } else {
      _switchColor = widget.inactiveColor ?? themeData.hintColor;
    }

    return Opacity(
      opacity: widget.disabled ? 0.5 : 1,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Align(
            child: GestureDetector(
              onTap: widget.disabled
                  ? null
                  : () {
                      if (widget.isSwitched)
                        _animationController.forward();
                      else
                        _animationController.reverse();

                      widget.onChanged(!widget.isSwitched);
                    },
              child: Container(
                width: 42,
                height: 24,
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(52),
                  color: _switchColor,
                ),
                child: Container(
                  child: Align(
                    alignment: _toggleAnimation.value,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _toggleColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
