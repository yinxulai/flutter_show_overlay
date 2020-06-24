# flutter_show_overlay

show_overlay plugin for [Flutter](https://flutter.io).
Supports iOS, Web, Android and MacOS.

## Getting Started

In your flutter project add the dependency:

```yml
dependencies:
  ...
 show_overlay: ^0.0.4
```

For help getting started with Flutter, view the online
[documentation](https://flutter.io/).

## Usage example

Import `show_overlay.dart`

```dart
import 'package:show_overlay/show_overlay.dart';
```

### Create and display some widgets

More can view the folder [example](https://github.com/yinxulai/flutter_show_overlay/tree/master/example)

```dart
    // default
    showOverlay(
      context: context,
      builder: (_, __, close) {
        return RaisedButton(
          onPressed: close,
          child: Text('Close'),
        );
      },
    );
  }

  // with animation
  showOverlay(
  context: context,
  animationDuration: Duration(milliseconds: 300),
  barrierDismissible: false,
  builder: (_, animation, close) {
    return ScaleTransition (
      scale: animation,
      child: RaisedButton(
        onPressed: close,
        child: Text('关闭'),
      ),
    );
  },
);
```



## More
