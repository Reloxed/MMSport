import 'package:flutter/material.dart';

class GradientFab extends StatelessWidget {
  const GradientFab({
    Key key,
    @required this.animation,
    @required this.vsync,
    @required this.elevation,
    @required this.child,
    @required this.onPressed,
  }) : super(key: key);

  final Animation<double> animation;
  final TickerProvider vsync;
  final int elevation;
  final Icon child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        duration: Duration(milliseconds: 1000),
        curve: Curves.linear,
        vsync: vsync,
        child: ScaleTransition(
            scale: animation,
            child: FloatingActionButton(
                child: Container(
                  constraints: BoxConstraints.expand(),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue[100], Colors.blue[900]])),
                  child: this.child,
                ),
                onPressed: () => this.onPressed)));
  }
}
