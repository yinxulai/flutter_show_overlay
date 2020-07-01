import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:show_overlay/show_overlay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'showOverlay example',
      home: Scaffold(body: Body()),
    );
  }
}

class Body extends StatelessWidget {
  showOverlayByNotBarrier(BuildContext context) {
    showOverlay(
      barrier: false,
      context: context,
      builder: (_, __, close) {
        return Center(
          child: RaisedButton(
            onPressed: close,
            child: Text('关闭'),
          ),
        );
      },
    );
  }

  showOverlayByDefault(BuildContext context) {
    showOverlay(
      context: context,
      barrierDismissible: false,
      builder: (_, __, close) {
        return Center(
          child: RaisedButton(
            onPressed: close,
            child: Text('关闭'),
          ),
        );
      },
    );
  }

  showOverlayByWithBarrier(BuildContext context) {
    showOverlay(
      barrierBlur: 20,
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_, __, close) {
        return Center(
          child: RaisedButton(
            onPressed: close,
            child: Text('关闭'),
          ),
        );
      },
    );
  }

  showOverlayByWithAnimation(BuildContext context) {
    showOverlay(
      barrierBlur: 2,
      context: context,
      barrierDismissible: false,
      animationDuration: Duration(milliseconds: 200),
      builder: (_, animation, close) {
        return Center(
          child: ScaleTransition(
            scale: animation,
            child: RaisedButton(
              onPressed: close,
              child: Text('关闭'),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () => showOverlayByDefault(context),
            child: Text('Default'),
          ),
          RaisedButton(
            onPressed: () => showOverlayByWithBarrier(context),
            child: Text('Default With Barrier'),
          ),
          RaisedButton(
            onPressed: () => showOverlayByWithAnimation(context),
            child: Text('Default With Animation'),
          ),
          RaisedButton(
            onPressed: () => showOverlayByNotBarrier(context),
            child: Text('Default Not Barrier'),
          )
        ],
      ),
    );
  }
}
