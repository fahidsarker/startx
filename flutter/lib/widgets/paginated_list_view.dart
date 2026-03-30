import 'package:flutter/material.dart';

class PaginatedListView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueNotifier<bool>? isLoadingMore;
  final ValueNotifier<bool>? hasMore;
  final void Function()? onLoadMore;
  final ScrollController? scrollController;
  const PaginatedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.isLoadingMore,
    this.hasMore,
    this.onLoadMore,
    this.scrollController,
  });

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  late final scrollController = widget.scrollController ?? ScrollController();
  late final hasMore = widget.hasMore ?? ValueNotifier<bool>(false);
  late final isLoadingMore = widget.isLoadingMore ?? ValueNotifier<bool>(false);

  @override
  void initState() {
    if (widget.onLoadMore != null) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
                scrollController.position.maxScrollExtent - 200 &&
            hasMore.value &&
            !isLoadingMore.value) {
          widget.onLoadMore!();
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: widget.itemCount + 1,
      itemBuilder: (context, i) {
        if (i < widget.itemCount) {
          return widget.itemBuilder(context, i);
        } else {
          return ValueListenableBuilder(
            valueListenable: hasMore,
            builder: (_, hasMore, __) {
              if (!hasMore) {
                return SizedBox.shrink();
              }
              return ValueListenableBuilder(
                valueListenable: isLoadingMore,
                builder: (_, isLoadingMore, __) {
                  if (isLoadingMore) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (widget.onLoadMore != null) {
                    return ElevatedButton(
                      onPressed: widget.onLoadMore,
                      child: Text('Load More'),
                    );
                  }
                  return SizedBox.shrink();
                },
              );
            },
          );
        }
      },
    );
  }
}
