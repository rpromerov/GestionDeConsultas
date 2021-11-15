import 'package:Cosemar/Widgets/Stepper.dart';
import 'package:Cosemar/screens/tripDetailScreen.dart';
import 'package:flutter/material.dart';

class ReceptionStepper extends StatefulWidget {
  final int intialValue;
  final Function onDecrease;
  final Function onIncrease;
  final String stepperText;

  ReceptionStepper(
      {Key key,
      @required this.intialValue,
      @required this.onDecrease,
      @required this.onIncrease,
      @required this.stepperText})
      : super(key: key);

  @override
  _ReceptionStepperState createState() => _ReceptionStepperState();
}

class _ReceptionStepperState extends State<ReceptionStepper> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DetailText(widget.stepperText),
          IncreaserDecrease(
            numberValue: widget.intialValue,
            onDecrease: widget.onDecrease,
            onIncrease: widget.onIncrease,
          )
        ],
      ),
    );
  }
}
