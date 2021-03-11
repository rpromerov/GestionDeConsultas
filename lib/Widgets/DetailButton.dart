import 'package:flutter/material.dart';

class DetailButton extends StatelessWidget {
  final Color color;
  final String text;
  final IconData icon;
  final Function function;

  const DetailButton({Key key, this.color, this.text, this.icon, this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color,
      onPressed: function,
      child: Container(
        padding: EdgeInsets.all(10),
        width: mediaQuery.size.width * 0.8,
        height: mediaQuery.size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(fontSize: 25, color: Colors.white),
            ),
            Icon(icon, size: 25, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
