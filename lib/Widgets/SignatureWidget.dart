import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:ui' as ui;

class SignatureWidget extends StatefulWidget {
  final double signatureBoardOffsetX;
  final double signatureBoardOffsetY;
  final Function onFinish;

  const SignatureWidget(
      {Key key,
      this.signatureBoardOffsetX,
      this.signatureBoardOffsetY,
      this.onFinish})
      : super(key: key);

  static _SignatureWidgetState of(BuildContext context, {bool root = false}) =>
      root
          ? context.findRootAncestorStateOfType<_SignatureWidgetState>()
          : context.findAncestorStateOfType<_SignatureWidgetState>();

  @override
  _SignatureWidgetState createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends State<SignatureWidget> {
  List<DrawingPoints> points = List();
  final double strokeWidth = 1;
  final StrokeCap strokeCap = StrokeCap.butt;

  static const double _overSampleScale = 4;
  Future<ui.Image> get renderedSignatureImage async {
    final recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    final size = Size(200 * _overSampleScale, 200 * _overSampleScale);
    final painter = DrawingPainter(pointsList: points);
    canvas.save();
    canvas.scale(_overSampleScale);
    painter.paint(canvas, size);
    canvas.restore();
    final data = await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());

    print(await data.toByteData(format: ui.ImageByteFormat.png));

    return data;
  }

  Future<String> imageAsData() async {
    final ui.Image image = await renderedSignatureImage;

    final byteData = await image.toByteData();
    final intList = Int8List(byteData.getInt8(0));
    final encodedImage = base64Encode(intList);
    return encodedImage;
  }

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

            if (details.globalPosition.dx < widget.signatureBoardOffsetX ||
                details.globalPosition.dx >
                    renderBox.constraints.maxWidth +
                        widget.signatureBoardOffsetX ||
                details.globalPosition.dy < widget.signatureBoardOffsetY + 67 ||
                details.globalPosition.dy >
                    renderBox.constraints.minHeight +
                        67 +
                        widget.signatureBoardOffsetY) {
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
          widget.onFinish(imageAsData());
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
        canvas.drawPoints(
            ui.PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
