import 'dart:async';
import 'dart:ui';

import 'package:BARJO/libs/handpainter.dart';
import 'package:BARJO/libs/linepainter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'gaugetextpainter.dart';

enum SecondsMarker {
  minutes,
  secondsAndMinute,
  all,
  none,
  seconds
}

enum Number {
  all,
  endAndStart,
  endAndCenterAndStart,
  none,

}

enum NumberInAndOut {
  inside,
  outside
}


enum CounterAlign{
  none,
  center,
  top,
  bottom,
}


enum Hand{
  none,
  long,
  short
}


enum Animate{
  none,
  knock,
  forget
}

class FlutterGaugeMain extends StatefulWidget {

  final int start;
  final int end;
  final double index;
  final double highlightStart;
  final double highlightEnd;
  final String fontFamily;
  final double widthCircle;
  final PublishSubject<double> eventObservable = PublishSubject();
  final Number number;
  final CounterAlign counterAlign;
  final Hand hand;
  final bool isCircle;
  final double handSize;
  final SecondsMarker secondsMarker;
  final double shadowHand;
  final Color circleColor;
  final Color handColor;
  final Color backgroundColor;
  final Color indicatorColor;
  final double paddingHand;
  final double width;
  final NumberInAndOut numberInAndOut;
  final TextStyle counterStyle;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final Color inactiveColor;
  final Color activeColor;
  final bool isDecimal;


  FlutterGaugeMain({
    super.key,
    this.isDecimal = false,
    this.inactiveColor = const Color.fromARGB(255, 255, 150, 150),
    this.activeColor = Colors.red,
    this.textStyle = const TextStyle(color: Colors.black54,fontSize: 18),
    this.counterStyle= const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
    this.numberInAndOut = NumberInAndOut.outside,
    this.width = 300,
    this.paddingHand = 20.0,
    this.circleColor = Colors.black,
    this.handColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.indicatorColor = Colors.black,
    this.shadowHand = 0,
    this.counterAlign = CounterAlign.bottom,
    this.number = Number.none,
    this.isCircle = false,
    required this.padding,
    this.hand = Hand.long,
    this.secondsMarker = SecondsMarker.seconds,
    this.handSize = 20,
    this.start = 0,
    this.end = 100,
    required this.highlightStart,
    required this.highlightEnd,
    required this.index,
    this.fontFamily = "",
    this.widthCircle = 15
  });

  @override
  _FlutterGaugeMainState createState() => _FlutterGaugeMainState(start,end,highlightStart,highlightEnd,eventObservable);
}

class _FlutterGaugeMainState extends State<FlutterGaugeMain>  with TickerProviderStateMixin{

  PublishSubject<double> eventObservable = PublishSubject();
  int start;
  int end;
  double highlightStart;
  double highlightEnd;
  double val = 0.0;
  late double newVal;
  late AnimationController percentageAnimationController;
  late StreamSubscription<double> subscription;


  _FlutterGaugeMainState(this.start, this.end, this.highlightStart, this.highlightEnd, this.eventObservable);

  @override
  void initState() {
    super.initState();

    percentageAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 0)
    )..addListener((){
      if(mounted) {
        setState(() {
          val = lerpDouble(val, newVal, percentageAnimationController.value)!;
        });
      }
    });

    subscription = eventObservable.listen((value) {
      (value >= end) ? reloadData(end.toDouble()) : reloadData(value);
    });
  }

  @override
  void dispose() {
    percentageAnimationController.dispose();
    subscription.cancel();
    super.dispose();
  }

  reloadData(double value) {
    if (mounted) {
      newVal = value;
      percentageAnimationController.forward(from: 0.0);
    }
  }


  @override
  Widget build(BuildContext context) {
    eventObservable.add(widget.index);
    return Center(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              height: widget.width,
              width: widget.width,
              child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    widget.isCircle == true ? SizedBox(
                      height: constraints.maxWidth,
                      width: constraints.maxWidth,
                      child: CustomPaint(
                          foregroundPainter: LinePainter(
                              lineColor: widget.backgroundColor,
                              completeColor: widget.circleColor,
                              startValue: start,
                              endValue: end,
                              startPercent: widget.highlightStart,
                              endPercent: widget.highlightEnd,
                              width: widget.widthCircle,
                              value: val
                          )
                      ),
                    ) :const SizedBox(),



                    widget.hand == Hand.none || widget.hand == Hand.short
                    ?const SizedBox()
                    :Center(
                      child: Container(
                        width: widget.handSize,
                        height: widget.handSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.indicatorColor,
                        ),
                      ),
                    ),

                    Container(
                      height: constraints.maxWidth,
                      width: constraints.maxWidth,
                      padding: EdgeInsets.only(top: widget.widthCircle+(widget.widthCircle/3.5),bottom: widget.widthCircle+(widget.widthCircle/6),left: widget.widthCircle+(widget.widthCircle/6),right: widget.widthCircle+(widget.widthCircle/6)),
                      child: CustomPaint(
                          painter: GaugeTextPainter(
                              numberInAndOut: widget.numberInAndOut,
                              secondsMarker: widget.secondsMarker,
                              number: widget.number,
                              inactiveColor : widget.inactiveColor,
                              activeColor : widget.activeColor,
                              start: start,
                              end: end,
                              value: val,
                              fontFamily: widget.fontFamily,
//                              color: this.widget.colorHourHand,
                              widthCircle: widget.widthCircle,
                              textStyle:widget.textStyle
                          )),
                    ),

                    widget.hand != Hand.none
                        ?Center(
                        child: Container(
                          height: constraints.maxWidth,
                          width: constraints.maxWidth,
                          padding: EdgeInsets.all(widget.hand == Hand.short ?widget.widthCircle/1.5 :widget.paddingHand),
                          child: CustomPaint(
                            painter: HandPainter(
                                shadowHand: widget.shadowHand,
                                hand: widget.hand,
                                value: val,
                                start: start,
                                end: end,
                                color: widget.handColor,
                                handSize: widget.handSize
                            ),
                          ),
                        )
                    )
                        :const SizedBox(),

                    Container(
                      child: widget.counterAlign != CounterAlign.none
                      ?CustomPaint(
                          painter: GaugeTextCounter(
                              isDecimal: widget.isDecimal,
                              start: start,
                              width: widget.widthCircle,
                              counterAlign: widget.counterAlign,
                              end: end,
                              value: val,
                              fontFamily: widget.fontFamily,
                              textStyle:widget.counterStyle
                          )
                      )
                      :const SizedBox(),
                    )
                  ]
              ),
            );
          }),
    );
  }
}