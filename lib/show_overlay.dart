library show_overlay;

import 'dart:ui';
import 'package:flutter/widgets.dart';

/// [Builder] 包含三个参数，第一个为 [BuildContext], 第二个为 [Animation<double>]
/// 第三个为 [Function], 执行 [Function] 可以移除当前的 [OverlayEntry]
typedef Builder = Function(BuildContext, Animation<double>, Function);

/// [showOverlay] 是对 [Overlay] 的使用的一个形式包装，可以快速的创建并插入一个 [OverlayEntry]
/// 你可以很轻松的使用 [builder] 来构建一个包含动画的 [Widget] 来作为 [OverlayEntry] 的 [child] 插入
/// 它依赖于当前的 [element tree] 中包含一个可用的 [Overlay] 实例
Function showOverlay({
  @required BuildContext context,
  Builder builder,

  /// [animationDuration] 如果你使用动画，可以通过这个指定动画的执行时间
  Duration animationDuration,

  /// 关于 [opaque]、[maintainState] 可以查看 [OverlayEntry] 对其的解释
  bool opaque: false,
  bool maintainState = false,

  /// [barrier] 系列参数用来配置在的 [OverlayEntry] 与 [builder] 构建的组件之间
  /// 的一层遮罩层，默认它是充满整个 [OverlayEntry] 
  /// 
  /// [barrier] 决定是否启用遮罩，[barrierColor] 指定遮罩的颜色，[barrierBlur] 
  /// 指定遮罩的模糊效果，[barrierDismissible] 指定是否可以通过点击遮罩来移除当前的 
  /// [OverlayEntry]
  Color barrierColor,
  bool barrier = true,
  bool barrierBlur = false,
  bool barrierDismissible = true,
}) {
  assert(builder != null);
  assert(Overlay.of(context) != null);

  final overlayState = Overlay.of(context);
  if (animationDuration == null) {
    animationDuration = Duration(milliseconds: 0);
  }

  final controller = AnimationController(
    duration: animationDuration,
    vsync: overlayState,
  );
  final animation = Tween(begin: 0.0, end: 1.0).animate(controller);

  OverlayEntry entry;

  // 关闭
  removeEntry() {
    // 先触发动画 完成时删除 entry
    controller.reverse(from: 1.0).then((_) {
      entry?.remove();
    });
  }

  // 构建 entry
  entry = OverlayEntry(
    opaque: false,
    maintainState: maintainState,
    builder: (BuildContext context) {
      if (!barrier) {
        return builder(context, animation, removeEntry);
      } else {
        return _Barrier(
          closer: removeEntry,
          blur: barrierBlur,
          color: barrierColor,
          animation: animation,
          dismissible: barrierDismissible,
          child: builder(context, animation, removeEntry),
        );
      }
    },
  );

  // 插入 entry
  Overlay.of(context).insert(entry);
  // 执行动画
  controller.forward(from: 0.0);
  return removeEntry;
}

class _Barrier extends AnimatedWidget {
  final bool blur;
  final Color color;
  final Widget child;
  final Function closer;
  final bool dismissible;
  final Animation<double> animation;

  _Barrier({
    Key key,
    this.blur,
    this.color,
    this.child,
    this.closer,
    this.animation,
    this.dismissible,
  }) : super(key: key, listenable: animation);

  get barrier {
    var barrier = Container(
      color: color != null ? color : Color.fromARGB(50, 0, 0, 0),
    );
    if (blur) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: animation.value * 2,
          sigmaY: animation.value * 2,
        ),
        child: barrier,
      );
    }
    return barrier;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FadeTransition(
          opacity: animation,
          child: GestureDetector(
            onTap: () {
              if (dismissible) {
                closer();
              }
            },
            child: barrier,
          ),
        ),
        this.child,
      ],
    );
  }
}
