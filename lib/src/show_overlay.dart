library show_overlay;

import 'dart:ui';
import 'package:flutter/widgets.dart';

/// [OverlayBuilder] 包含三个参数，第一个为 [BuildContext], 第二个为 [Animation<double>]
/// 第三个为 [Function], 执行 [Function] 可以移除当前的 [OverlayEntry]
typedef OverlayBuilder = Widget Function(
    BuildContext,
    Animation<double>,
    Function,
    );

/// [showOverlay] 是对 [Overlay] 的使用的一个形式包装，可以快速的创建并插入一个 [OverlayEntry]
/// 你可以很轻松的使用 [builder] 来构建一个包含动画的 [Widget] 来作为 [OverlayEntry] 的 [child] 插入
/// 它依赖于当前的 [element tree] 中包含一个可用的 [Overlay] 实例
Function showOverlay({
  required BuildContext context,
  required OverlayBuilder builder,

  /// 是否使用最根处的 [Overlay] 来展示
  bool useRootOverlay = false,

  /// [animationDuration] 如果你使用动画，可以通过这个指定动画的执行时间
  Duration? animationDuration,

  /// [opaque] 为 true，则意味着这个弹窗是完全不透明的，flutter 将会为性能考虑忽略本 [OverlayEntry] 下方所有的有状态的 [Widget] 的渲染
  /// 如果你想要强制渲染下方的元素，可以设置 [maintainState] 为 true，小心，这样做可能成本很高
  bool opaque: false,
  bool maintainState = true,

  // 可以为你的 Overlay 添加一个位于背景的遮罩层
  /// [barrier] 设置为 false 则不实用 barrier
  /// [barrierBlur] 指定 barrier 的背景模糊效果
  /// [barrierColor] 为你的 barrier 指定背景颜色
  /// [barrierDismissible] 指定是否可以通过点击 barrier 移除本 [OverlayEntry]
  double? barrierBlur,
  Color? barrierColor,
  bool barrier = true,
  bool barrierDismissible = true,
}) {
  animationDuration = animationDuration ?? Duration(milliseconds: 100);

  final overlayState = Overlay.of(context, rootOverlay: useRootOverlay);
  assert(overlayState != null);

  // 创建 animationController 对象
  final controller = AnimationController(
    duration: animationDuration,
    vsync: overlayState as TickerProvider,
  );

  // 创建 animation 对象
  final animation = Tween(
    end: 1.0,
    begin: 0.0,
  ).animate(controller);

  OverlayEntry? entry;

  removeEntry() {
    // 先触发动画 完成时删除 entry
    controller.reverse().then((_) {
      entry?.remove();
    });
  }

  // 构建 entry
  entry = OverlayEntry(
      opaque: opaque,
      maintainState: maintainState,
      builder: (BuildContext context) {
        return _OverlayBarrier(
          barrier: barrier,
          blur: barrierBlur,
          color: barrierColor,
          animation: animation,
          onTap: barrierDismissible ? removeEntry : null,
          child: builder(context, animation, removeEntry),
        );
      });

  // 插入 entry
  overlayState!.insert(entry!);
  // 执行动画
  controller.forward();
  return removeEntry;
}

// 遮罩层
class _OverlayBarrier extends AnimatedWidget {
  final double blur;
  final Color color;
  final Widget child;
  final bool? barrier;
  final VoidCallback? onTap;
  final Animation<double> animation;

  _OverlayBarrier({
    Key? key,
    this.onTap,
    required this.child,
    Color? color,
    double? blur,
    this.barrier,
    required this.animation,
  })  : assert(child != null),
        this.blur = blur ?? 1.0,
        this.color = color ?? Color.fromARGB(200, 0, 0, 0),
        super(key: key, listenable: animation as Listenable);

  get animationColor {
    return Color.lerp(
      Color.fromRGBO(0, 0, 0, 0),
      color,
      animation.value,
    );
  }

  get animationImageFilter {
    return ImageFilter.blur(
      sigmaX: blur * animation.value,
      sigmaY: blur * animation.value,
    );
  }

  get background {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        child: BackdropFilter(
          filter: animationImageFilter,
          child: FadeTransition(
            opacity: animation,
            child: Container(
              color: animationColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (barrier != null && barrier!) {
      children.add(background);
    }

    children.add(child);

    return Stack(children: children);
  }
}