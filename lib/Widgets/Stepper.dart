import 'package:flutter/material.dart';

class IncreaserDecrease extends StatefulWidget {
  final Function onDecrease;
  final Function onIncrease;
  final int numberValue;

  IncreaserDecrease({this.onDecrease, this.onIncrease, this.numberValue});

  @override
  State<IncreaserDecrease> createState() =>
      _IncreaserDecreaseState(this.numberValue);
}

class _IncreaserDecreaseState extends State<IncreaserDecrease> {
  var numbervalue = 0;

  _IncreaserDecreaseState(this.numbervalue);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              backgroundColor: this.numbervalue == 0
                  ? Colors.green.withOpacity(0.5)
                  : Colors.green,
              shape: CircleBorder()),
          onPressed: () {
            setState(() {
              if (numbervalue > 0) {
                widget.onDecrease();
                numbervalue -= 1;
              }
            });
          },
          child: Text(
            "-",
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Text(
          "${this.numbervalue}",
          style: TextStyle(fontSize: 25),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              backgroundColor: Colors.green, shape: CircleBorder()),
          onPressed: () {
            setState(() {
              widget.onIncrease();
              numbervalue += 1;
            });
          },
          child: Text(
            "+",
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        )
      ],
    );
  }
}
