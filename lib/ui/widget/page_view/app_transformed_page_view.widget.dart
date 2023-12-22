import 'dart:math' as Math;
import 'dart:ui';
import 'package:flutter/material.dart';

import '../app_dot_indicator.widget.dart';

/// Displays a [PageView] where the neighboring pages of the current page are scaled down.
class AppTransformedPageView extends StatefulWidget {
  /// List of pages.
  final List<Widget> children;

  /// Optional controller
  final PageController? pageController;

  /// The color of the active dot in the dot indicator.
  final Color? activeDotColor;

  /// The color of the inactive dot in the dot indicator.
  final Color? inactiveDotColor;

  /// The fraction of the viewport width taken up by the current page. Must be less than 1
  /// in order to be able to see the transformation effect.
  final double viewportFraction;

  /// Function to be called when a page with the specified index is selected.
  final void Function(int page)? onPageSelected;

  /// If true, then the neighboring pages are faded out.
  final bool fadeOffscreenChildren;

  /// If true, then scale page on change
  final bool scalable;

  /// Custom page height
  final double? pageHeight;

  /// If true, then dots will be shown
  final bool showDots;

  const AppTransformedPageView({
    Key? key,
    required this.children,
    this.pageController,
    this.activeDotColor,
    this.inactiveDotColor,
    this.viewportFraction = 0.9,
    this.onPageSelected,
    this.fadeOffscreenChildren = false,
    this.scalable = true,
    this.pageHeight,
    this.showDots = true,
  }) : super(key: key);

  @override
  _AppTransformedPageViewState createState() => _AppTransformedPageViewState();
}

class _AppTransformedPageViewState extends State<AppTransformedPageView> {
  late PageController _pageController;

  double _currentPageValue = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = widget.pageController ??
        PageController(
          keepPage: true,
          viewportFraction: widget.viewportFraction,
        );

    _pageController.addListener(_onPageControllerChanged);
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      _pageController.dispose();
    } else {
      _pageController.removeListener(_onPageControllerChanged);
    }
    super.dispose();
  }

  void _onPageControllerChanged() {
    if (_pageController.page != _currentPageValue) {
      setState(() {
        _currentPageValue = _pageController.page ?? 0;
      });
      final onPageSelected = widget.onPageSelected;
      if (onPageSelected != null) {
        final page = _pageController.page?.round();
        if (page != null && page != _currentPage) {
          _currentPage = page;
          onPageSelected(page);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 16, bottom: 48),
          constraints: BoxConstraints(
            maxHeight: widget.pageHeight ?? MediaQuery.of(context).size.height - 200,
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.children.length,
            itemBuilder: _buildPage,
          ),
        ),
        if (widget.showDots && widget.children.length > 1) _buildDotIndicator(),
      ],
    );
  }

  Transform _buildPage(BuildContext context, int position) {
    Widget child = widget.children[position];

    final Matrix4 transform = Matrix4.identity();
    final offset = Math.max(Math.min(position - _currentPageValue, 1.0), -1.0);
    final scale = lerpDouble(1.0, 0.9, offset.abs());
    if (offset != 0) {
      transform.translate(lerpDouble(0.0, -32.0, offset));
    }

    if (widget.fadeOffscreenChildren) {
      child = Opacity(
        opacity: lerpDouble(1, 0.5, offset.abs()) ?? 0,
        child: child,
      );
    }

    return Transform(
      transform: transform,
      child: widget.scalable
          ? Transform.scale(
              scale: scale,
              origin: Offset(0.5, 0.5),
              child: child,
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: child,
            ),
    );
  }

  Positioned _buildDotIndicator() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: AppDotIndicator(
          itemCount: widget.children.length,
          index: _currentPageValue.round(),
          activeColor: widget.activeDotColor,
          inactiveColor: widget.inactiveDotColor,
          scalable: widget.scalable,
        ),
      ),
    );
  }
}
