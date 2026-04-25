import 'package:flutter/material.dart';

class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final int staggerDelayMs;
  final int itemDurationMs;
  final double startScale;
  final double endScale;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.staggerDelayMs = 50,
    this.itemDurationMs = 350,
    this.startScale = 0.95,
    this.endScale = 1.0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = <AnimationController>[];
  final List<Animation<double>> _fadeAnimations = <Animation<double>>[];
  final List<Animation<double>> _scaleAnimations = <Animation<double>>[];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(covariant StaggeredListAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  void _initAnimations() {
    for (int i = 0; i < widget.children.length; i++) {
      final AnimationController controller = AnimationController(
        duration: Duration(milliseconds: widget.itemDurationMs),
        vsync: this,
      );

      _controllers.add(controller);
      _fadeAnimations.add(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
      _scaleAnimations.add(
        Tween<double>(begin: widget.startScale, end: widget.endScale).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
        ),
      );
    }

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      if (!mounted) {
        return;
      }
      if (i > 0) {
        await Future<void>.delayed(Duration(milliseconds: widget.staggerDelayMs));
      }
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  void _disposeAnimations() {
    for (final AnimationController controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _fadeAnimations.clear();
    _scaleAnimations.clear();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: List<Widget>.generate(widget.children.length, (int index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          child: widget.children[index],
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: _fadeAnimations[index].value,
              child: Transform.scale(
                scale: _scaleAnimations[index].value,
                child: child,
              ),
            );
          },
        );
      }),
    );
  }
}

class StaggeredGridAnimation extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int staggerDelayMs;
  final int itemDurationMs;
  final double startScale;
  final double endScale;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double mainAxisExtent;

  const StaggeredGridAnimation({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDelayMs = 50,
    this.itemDurationMs = 350,
    this.startScale = 0.95,
    this.endScale = 1.0,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.mainAxisExtent = 240,
  });

  @override
  State<StaggeredGridAnimation> createState() => _StaggeredGridAnimationState();
}

class _StaggeredGridAnimationState extends State<StaggeredGridAnimation>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = <AnimationController>[];
  final List<Animation<double>> _fadeAnimations = <Animation<double>>[];
  final List<Animation<double>> _scaleAnimations = <Animation<double>>[];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(covariant StaggeredGridAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  void _initAnimations() {
    for (int i = 0; i < widget.itemCount; i++) {
      final AnimationController controller = AnimationController(
        duration: Duration(milliseconds: widget.itemDurationMs),
        vsync: this,
      );

      _controllers.add(controller);
      _fadeAnimations.add(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
      _scaleAnimations.add(
        Tween<double>(begin: widget.startScale, end: widget.endScale).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
        ),
      );
    }

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      if (!mounted) {
        return;
      }
      if (i > 0) {
        await Future<void>.delayed(Duration(milliseconds: widget.staggerDelayMs));
      }
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  void _disposeAnimations() {
    for (final AnimationController controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _fadeAnimations.clear();
    _scaleAnimations.clear();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        mainAxisExtent: widget.mainAxisExtent,
      ),
      itemBuilder: (BuildContext context, int index) {
        if (_controllers.isEmpty || index >= _controllers.length) {
          return widget.itemBuilder(context, index);
        }

        return AnimatedBuilder(
          animation: _controllers[index],
          child: widget.itemBuilder(context, index),
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: _fadeAnimations[index].value,
              child: Transform.scale(
                scale: _scaleAnimations[index].value,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
