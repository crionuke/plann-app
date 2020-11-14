import 'dart:math';

import 'package:flutter/material.dart';

typedef ChartBarTapCallback = void Function(BuildContext context, int column);

class ChartWidget extends StatelessWidget {
  static const Color DEFAULT_COLOR = Colors.blueAccent;

  final double height;
  final double barWidth;
  final List<ChartBar> bars;
  final int currentColumn;
  final ChartBarTapCallback barTap;

  final double _scale;

  ChartWidget(this.height, this.barWidth, this.bars, this.currentColumn, this.barTap)
      : _scale = height *
            0.8 /
            bars
                .map((bar) {
                  double sum = 0;
                  for (ChartItem item in bar.items) {
                    sum += item.value;
                  }
                  return sum;
                })
                .toList()
                .reduce(max);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          height: height + 50,
          child: ListView(
            controller:
                ScrollController(initialScrollOffset: currentColumn * barWidth),
            scrollDirection: Axis.horizontal,
            children: bars
                .map((bar) => _buildColumn(context, bars.indexOf(bar), bar))
                .toList(),
          )),
    );
  }

  Widget _buildColumn(BuildContext context, int index, ChartBar bar) {
    return Container(
        height: height + 50,
//        padding: const EdgeInsets.all(2),
        child: InkWell(
            onTap: () => barTap(context, index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildBar(context, index, bar.items),
                _buildTile(bar.title, underlined: index == currentColumn),
              ],
            )));
  }

  Widget _buildBar(BuildContext context, int index, List<ChartItem> items) {
    return Column(
        children: items.map((item) {
      if (item.value == 0) {
        return Container(
          width: barWidth,
          height: height,
        );
      } else {
        return _buildBox(max(item.value * _scale, 6), item.color);
      }
    }).toList());
  }

  Widget _buildBox(double height, Color color) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          width: barWidth,
          height: height,
          color: color,
        ));
  }

  Container _buildTile(String title, {bool underlined}) {
    Text text;
    if (underlined) {
      text = Text(
        title,
        style: TextStyle(decoration: TextDecoration.underline),
      );
    } else {
      text = Text(title);
    }

    return Container(
      width: barWidth,
      height: 50,
      child: Center(child: text),
    );
  }
}

class ChartBar {
  final String title;
  final List<ChartItem> items;

  ChartBar(this.title, this.items);

  ChartBar.empty(this.title) : items = [ChartItem(ChartWidget.DEFAULT_COLOR, 0)];
}

class ChartItem {
  final Color color;
  final double value;

  ChartItem(this.color, this.value);

  ChartItem.defaultColor(this.value) : color = ChartWidget.DEFAULT_COLOR;
}
