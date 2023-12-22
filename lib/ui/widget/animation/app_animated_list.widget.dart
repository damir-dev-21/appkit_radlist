import 'package:appkit/common/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:appkit/common/model/has_id.dart';

const _ANIMATION_DURATION = const Duration(milliseconds: 150);

class AppAnimatedList<T extends HasId> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T? item) itemBuilder;
  final EdgeInsets? padding;

  const AppAnimatedList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.padding,
  }) : super(key: key);

  @override
  _AppAnimatedListState createState() => _AppAnimatedListState();
}

class _AppAnimatedListState<T extends HasId> extends State<AppAnimatedList<T>> {
  final _listKey = GlobalKey<AnimatedListState>();

  late int _initialItemCount;

  final _logger = Logger('AppAnimatedList');

  @override
  void initState() {
    super.initState();
    _initialItemCount = widget.items.length;
    _logger.log('Initial item count = $_initialItemCount');
  }

  @override
  void didUpdateWidget(AppAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _updateList(oldWidget.items, widget.items);
    }
  }

  void _updateList(List<T> oldItems, List<T> newItems) {
    for (int i = oldItems.length - 1; i >= 0; i--) {
      final item = oldItems[i];
      final id = item.id;
      final newItemsIndex = newItems.indexWhere((it) => it.id == id);
      if (newItemsIndex < 0) {
        _removeItem(item, i);
      }
    }

    for (int i = 0; i < newItems.length; i++) {
      final item = newItems[i];
      final id = item.id;
      final oldItemsIndex = oldItems.indexWhere((it) => it.id == id);
      if (oldItemsIndex < 0) {
        _insertItem(i);
      }
    }
  }

  void _removeItem(T item, int index) {
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildAnimationWrapper(context, item, animation),
      duration: _ANIMATION_DURATION,
    );
  }

  void _insertItem(int index) {
    _listKey.currentState?.insertItem(index, duration: _ANIMATION_DURATION);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      padding: widget.padding,
      itemBuilder: (context, index, animation) => _buildAnimationWrapper(
          context, index < widget.items.length ? widget.items[index] : null, animation),
      initialItemCount: _initialItemCount,
    );
  }

  Widget _buildAnimationWrapper(BuildContext context, T? item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation.drive(Tween<double>(begin: 0, end: 1.02)),
      axis: Axis.vertical,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: animation,
        child: widget.itemBuilder(context, item),
      ),
    );
  }
}
