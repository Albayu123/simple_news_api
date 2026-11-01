import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

class NewsListSkeleton extends StatelessWidget {
  const NewsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Hero Skeleton
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(width: double.infinity, height: 210, borderRadius: 16),
              const SizedBox(height: 12),
              const ShimmerBox(width: 120, height: 16, borderRadius: 4),
              const SizedBox(height: 8),
              const ShimmerBox(width: double.infinity, height: 22, borderRadius: 4),
              const SizedBox(height: 6),
              ShimmerBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 22,
                borderRadius: 4,
              ),
            ],
          ),
        ),
        // List Item Skeletons
        ...List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 90, height: 90, borderRadius: 12),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 80, height: 14, borderRadius: 4),
                      SizedBox(height: 8),
                      ShimmerBox(width: double.infinity, height: 16, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerBox(width: 180, height: 16, borderRadius: 4),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          ShimmerBox(width: 60, height: 12, borderRadius: 4),
                          SizedBox(width: 12),
                          ShimmerBox(width: 60, height: 12, borderRadius: 4),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
