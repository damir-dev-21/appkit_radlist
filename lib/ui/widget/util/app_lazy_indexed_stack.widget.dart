import 'package:flutter/material.dart';

/// Same as [IndexedStack], but every item is initialized lazily the first time [index]
/// is set to the item's index.
class AppLazyIndexedStack extends StatefulWidget {
  /// The total item count.
  final int itemCount;

  /// Builder function for each item.
  final IndexedWidgetBuilder itemBuilder;

  /// The current index.
  final int index;

  const AppLazyIndexedStack({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.index,
  }) : super(key: key);

  @override
  AppLazyIndexedStackState createState() => AppLazyIndexedStackState();
}

class AppLazyIndexedStackState extends State<AppLazyIndexedStack> {
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = List.filled(widget.itemCount, SizedBox.shrink());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initChildren();
  }

  @override
  void didUpdateWidget(covariant AppLazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _initChildren();
    } else {
      _children[widget.index] = widget.itemBuilder(context, widget.index);
    }
  }

  void resetChildren() {
    setState(() {
      _initChildren();
    });
  }

  void _initChildren() {
    if (_children.length != widget.itemCount) {
      _children = List.filled(widget.itemCount, SizedBox.shrink());
    }

    for (int i = 0; i < widget.itemCount; i++) {
      if (i == widget.index) {
        _children[i] = widget.itemBuilder(context, i);
      } else {
        _children[i] = Container();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: _children,
    );
  }
}
