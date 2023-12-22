import 'package:appkit/ui/theme/theme.dart';
import 'package:appkit/ui/widget/page_view/app_transformed_page_view.widget.dart';
import 'package:flutter/material.dart';

/// Shows multiple dialogs in a tabbed interface.
class TabbedCustomDialog extends StatefulWidget {
  final List<Widget> children;
  final EdgeInsets insetPadding;

  const TabbedCustomDialog({
    Key? key,
    required this.insetPadding,
    required this.children,
  }) : super(key: key);

  @override
  _TabbedCustomDialogState createState() => _TabbedCustomDialogState();
}

class _TabbedCustomDialogState extends State<TabbedCustomDialog> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(keepPage: true, viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(color: Colors.black.withAlpha(100)),
          GestureDetector(
            onTap: () {
              // Only pop if the page transition animation is settled.
              final page = _pageController.page;
              if (page != null && page == page.roundToDouble()) {
                Navigator.maybePop(context);
              }
            },
            child: SafeArea(
              top: false,
              child: AppTransformedPageView(
                pageController: _pageController,
                children: widget.children.map(_wrapChild).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapChild(Widget child) {
    final themeData = theme(context);

    return Dialog(
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: themeData.borderRadius,
      ),
      insetPadding: widget.insetPadding,
      child: GestureDetector(
        onTap: () {},
        child: Material(
          borderRadius: themeData.borderRadius,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: <Widget>[
              Scrollbar(
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
