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
      showPerformanceOverlay: true,
      home: Scaffold(body: Body()),
    );
  }
}

class OverlayBox extends StatelessWidget {
  final Widget child;
  OverlayBox({this.child});

  @override
  Widget build(Object context) {
    return Container(
      color: Colors.grey[200],
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (_) => child,
          ),
        ],
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Test(
              title: "Global",
            ),
          ),
          Expanded(
            child: OverlayBox(
              child: Test(
                title: "Local",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Test extends StatelessWidget {
  final String title;
  Test({this.title});

  showOverlayDefault(BuildContext context) {
    showOverlay(
      context: context,
      barrierDismissible: false,
      builder: (_, __, close) {
        return Center(
          child: RaisedButton(
            onPressed: close,
            child: Text('close'),
          ),
        );
      },
    );
  }

  showOverlayWithBarrier(BuildContext context) {
    showOverlay(
      barrierBlur: 20,
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_, __, close) {
        return Center(
          child: RaisedButton(
            onPressed: close,
            child: Text('close'),
          ),
        );
      },
    );
  }

  showOverlayWithAnimation(BuildContext context) {
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
              child: Text('close'),
            ),
          ),
        );
      },
    );
  }

  showOverlayNotWithBarrier(BuildContext context) {
    showOverlay(
      barrier: false,
      context: context,
      barrierDismissible: false,
      builder: (_, __, close) {
        return Center(
          child: RaisedButton(
            onPressed: close,
            child: Text('close'),
          ),
        );
      },
    );
  }

  showOverlayWithUseRootOverlay(BuildContext context) {
    showOverlay(
      context: context,
      useRootOverlay: true,
      builder: (_, __, close) {
        return Center(
          child: RaisedButton(
            onPressed: close,
            child: Text('close'),
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
          Text(title),
          RaisedButton(
            onPressed: () => showOverlayDefault(context),
            child: Text('Default'),
          ),
          RaisedButton(
            onPressed: () => showOverlayNotWithBarrier(context),
            child: Text('Not Barrier'),
          ),
          RaisedButton(
            onPressed: () => showOverlayWithBarrier(context),
            child: Text('With Barrier'),
          ),
          RaisedButton(
            onPressed: () => showOverlayWithAnimation(context),
            child: Text('With Animation'),
          ),
          RaisedButton(
            onPressed: () => showOverlayWithUseRootOverlay(context),
            child: Text('With useRootOverlay'),
          )
        ],
      ),
    );
  }
}
