import 'package:flutter/material.dart';

/// Displays a [PageView] with the specified [children].
/// Calls [onPageSelected] when the the PageView is scrolled past the midpoint
/// between two pages.
class AppPageView extends StatefulWidget {
  final List<Widget> children;
  final void Function(int page)? onPageSelected;

  AppPageView({
    Key? key,
    required this.children,
    this.onPageSelected,
  }) : super(key: key);

  @override
  _AppPageViewState createState() => _AppPageViewState();
}

class _AppPageViewState extends State<AppPageView> {
  final _controller = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round();
      if (page != null && page != _currentPage) {
        _currentPage = page;
        widget.onPageSelected?.call(page);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: widget.children,
    );
  }
}
