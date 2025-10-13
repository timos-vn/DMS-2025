import 'package:flutter/material.dart';

/// Custom Shimmer Effect - không cần package bên ngoài
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration period;

  const Shimmer({
    Key? key,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFF4F4F4),
                Color(0xFFEBEBF4),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Skeleton Box - placeholder cho text, image, etc
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    Key? key,
    this.width,
    this.height = 16,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton cho Master Info Card
class SkeletonMasterInfo extends StatelessWidget {
  const SkeletonMasterInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              SkeletonBox(width: 30, height: 30, borderRadius: BorderRadius.circular(6)),
              const SizedBox(width: 8),
              const SkeletonBox(width: 120, height: 16),
              const Spacer(),
              SkeletonBox(width: 70, height: 24, borderRadius: BorderRadius.circular(12)),
            ],
          ),
          const SizedBox(height: 10),
          // Customer info
          Row(
            children: [
              SkeletonBox(width: 16, height: 16, borderRadius: BorderRadius.circular(8)),
              const SizedBox(width: 6),
              const Expanded(child: SkeletonBox(height: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton cho Material Card
class SkeletonMaterialCard extends StatelessWidget {
  const SkeletonMaterialCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              SkeletonBox(width: 36, height: 36, borderRadius: BorderRadius.circular(8)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 80, height: 12),
                    SizedBox(height: 4),
                    SkeletonBox(height: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          // Details
          _buildSkeletonRow(),
          const SizedBox(height: 8),
          _buildSkeletonRow(),
          const SizedBox(height: 8),
          _buildSkeletonRow(),
        ],
      ),
    );
  }

  Widget _buildSkeletonRow() {
    return Row(
      children: [
        SkeletonBox(width: 16, height: 16, borderRadius: BorderRadius.circular(8)),
        const SizedBox(width: 8),
        const SkeletonBox(width: 80, height: 13),
        const Spacer(),
        const SkeletonBox(width: 100, height: 13),
      ],
    );
  }
}

/// Skeleton Loading cho danh sách vật tư
class SkeletonMaterialList extends StatelessWidget {
  final bool showMasterInfo;

  const SkeletonMaterialList({
    Key? key,
    this.showMasterInfo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            if (showMasterInfo) const SkeletonMasterInfo(),
            if (showMasterInfo) const SizedBox(height: 8),
            ...List.generate(5, (index) => const SkeletonMaterialCard()),
          ],
        ),
      ),
    );
  }
}

/// Skeleton cho Contract Card (danh sách hợp đồng)
class SkeletonContractCard extends StatelessWidget {
  const SkeletonContractCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Contract number & status
          Row(
            children: [
              SkeletonBox(width: 28, height: 28, borderRadius: BorderRadius.circular(8)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 80, height: 12),
                    SizedBox(height: 4),
                    SkeletonBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SkeletonBox(width: 80, height: 28, borderRadius: BorderRadius.circular(20)),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          
          // Customer info
          Row(
            children: [
              SkeletonBox(width: 18, height: 18, borderRadius: BorderRadius.circular(4)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 60, height: 12),
                    SizedBox(height: 4),
                    SkeletonBox(height: 14),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Date info
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SkeletonBox(width: 14, height: 14, borderRadius: BorderRadius.circular(4)),
                          const SizedBox(width: 6),
                          const SkeletonBox(width: 50, height: 11),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const SkeletonBox(width: 80, height: 13),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SkeletonBox(width: 14, height: 14, borderRadius: BorderRadius.circular(4)),
                          const SizedBox(width: 6),
                          const SkeletonBox(width: 50, height: 11),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const SkeletonBox(width: 80, height: 13),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          
          // Action button area
          Align(
            alignment: Alignment.centerRight,
            child: SkeletonBox(width: 100, height: 32, borderRadius: BorderRadius.circular(8)),
          ),
        ],
      ),
    );
  }
}

/// Skeleton Loading cho danh sách hợp đồng
class SkeletonContractList extends StatelessWidget {
  const SkeletonContractList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: List.generate(5, (index) => const SkeletonContractCard()),
        ),
      ),
    );
  }
}

/// Shimmer Overlay - hiển thị lớp shimmer mờ phía trên content
/// Dùng cho pagination và refresh loading
class ShimmerOverlay extends StatelessWidget {
  final bool showMasterInfo;

  const ShimmerOverlay({
    Key? key,
    this.showMasterInfo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lớp mờ trắng
        Container(
          color: Colors.white.withOpacity(0.7),
        ),
        // Shimmer skeleton bên trên
        Shimmer(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                if (showMasterInfo) const SkeletonMasterInfo(),
                if (showMasterInfo) const SizedBox(height: 8),
                ...List.generate(3, (index) => const SkeletonMaterialCard()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shimmer Overlay cho Contract List
class ShimmerOverlayContractList extends StatelessWidget {
  const ShimmerOverlayContractList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lớp mờ trắng
        Container(
          color: Colors.white.withOpacity(0.7),
        ),
        // Shimmer skeleton bên trên
        Shimmer(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: List.generate(3, (index) => const SkeletonContractCard()),
            ),
          ),
        ),
      ],
    );
  }
}

