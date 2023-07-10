import 'dart:math';

import 'package:BARJO/libs/fluttergauge.dart';
import 'package:flutter/material.dart';


class HandPainter extends CustomPainter{
  final Paint minuteHandPaint;
  double value;
  int start;
  int end;
  Color color;
  double handSize;
  Hand hand;
  double shadowHand;

  HandPainter({
    required this.shadowHand,
    required this.hand,
    required this.value,
    required this.start,
    required this.end,
    required this.color,
    required this.handSize
  }):minuteHandPaint= Paint(){
    minuteHandPaint.color= color;
    minuteHandPaint.style= PaintingStyle.fill;

  }

  @override
  void paint(Canvas canvas, Size size) {

//      for(int i = 0;i == 2; i++){
    var radius= size.width/2;
    double gamma = ((2/3)*end);


    double downSizedValue = ((value <= (end/2))? value : value - (end/2))*(gamma/end);
    double realValue = (((value <= (end/2))? downSizedValue + gamma : downSizedValue)%end);

    canvas.save();

    canvas.translate(radius, radius);

    canvas.rotate(2*pi*((realValue)/end));


    Path path= Path();
    if(hand == Hand.short){
      path.moveTo(-1.0, -radius-handSize/8.0);
      path.lineTo(-5.0, -radius/1.8);
      path.lineTo(5.0, -radius/1.8);
      path.lineTo(1.0, -radius-handSize/8);
    }else{
      path.moveTo(-1.5, -radius-handSize/3.0);
      path.lineTo(-5.0, -radius/1.8);
      path.lineTo(-handSize/3, handSize/5);/// change 2 => 5
      path.lineTo(handSize/3, handSize/5);/// change 2 => 5
      path.lineTo(5.0, -radius/1.8);
      path.lineTo(1.5, -radius-handSize/3);
    }


    path.close();

    canvas.drawPath(path, minuteHandPaint);
    canvas.drawShadow(path, color, shadowHand, false);

    canvas.restore();
  }

//    }

  @override
  bool shouldRepaint(HandPainter oldDelegate) {
    return true;
  }
}
