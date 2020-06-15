library show_overlay;

import 'dart:ui';
import 'package:flutter/widgets.dart';

typedef Closer = Function();
typedef AnimatedBuilder = Function(
    BuildContext context, Animation<double> animation, Closer closer);

Closer showOverlay({
  @required BuildContext context,
  Duration duration,
  AnimatedBuilder builder,
  bool maintainState = false, // 保持状态

  Color barrierColor, // 屏障的颜色
  bool barrier = true, // 是否显示屏障
  bool barrierBlur = false, // 屏障是否模糊背景
  bool barrierDismissible = true, // barrier 是否可点击
}) {
  OverlayEntry entry;
  final overlayState = Overlay.of(context);

  if (duration == null) {
    // 默认 300
    duration = Duration(milliseconds: 300);
  }

  // 动画相关
  final controller =
      AnimationController(duration: duration, vsync: overlayState);
  final animation = Tween(begin: 0.0, end: 1.0).animate(controller);

  // 关闭
  close() {
    // 先触发动画 完成时删除 entry
    controller.reverse(from: 1.0).then((_) {
      entry?.remove();
    });
  }

  // 构建 entry
  entry = OverlayEntry(
    opaque: false,
    maintainState: maintainState,
    builder: (context) {
      if (!barrier) {
        return builder(context, animation, close);
      } else {
        return OverlayMask(
          closer: close,
          blur: barrierBlur,
          color: barrierColor,
          animation: animation,
          dismissible: barrierDismissible,
          child: builder(context, animation, close),
        );
      }
    },
  );

  // 插入 entry
  Overlay.of(context).insert(entry);
  // 执行动画
  controller.forward(from: 0.0);
  return close;
}

class OverlayMask extends AnimatedWidget {
  final bool blur;
  final Color color;
  final Widget child;
  final Closer closer;
  final bool dismissible;
  final Animation<double> animation;

  OverlayMask({
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
