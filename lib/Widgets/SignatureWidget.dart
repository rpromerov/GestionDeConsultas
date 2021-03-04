import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:ui';

class SignatureWidget extends StatefulWidget {
  final double signatureBoardOffset;

  const SignatureWidget({Key key, this.signatureBoardOffset}) : super(key: key);

  @override
  _SignatureWidgetState createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends State<SignatureWidget> {
  List<DrawingPoints> points = List();
  final double strokeWidth = 1;
  final StrokeCap strokeCap = StrokeCap.butt;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(pointsList: points),
        ),
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();

            if (details.globalPosition.dx < widget.signatureBoardOffset ||
                details.globalPosition.dx >
                    renderBox.constraints.maxWidth +
                        widget.signatureBoardOffset ||
                details.globalPosition.dy < widget.signatureBoardOffset + 67 ||
                details.globalPosition.dy >
                    renderBox.constraints.minHeight +
                        67 +
                        widget.signatureBoardOffset) {
              points.add(null);
            } else {
              points.add(DrawingPoints(
                  points: renderBox.globalToLocal(details.globalPosition),
                  paint: Paint()
                    ..strokeCap = strokeCap
                    ..isAntiAlias = true
                    ..color = Colors.black
                    ..strokeWidth = strokeWidth));
            }
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            points.add(DrawingPoints(
                points: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = Colors.black
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },
      ),
    );
  }
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
