import 'dart:math';

import 'package:flutter/material.dart';

typedef LogChartBarTapCallback = void Function(
    BuildContext context, int column);

class LogChart extends StatelessWidget {
  static const double BAR_WIDTH = 60;
  static const Color DEFAULT_COLOR = Colors.blueAccent;

  final double height;
  final List<LogChartBar> bars;
  final LogChartBarTapCallback barTap;

  double _scale;

  LogChart(this.height, this.bars, this.barTap) {
    _scale = height * 0.8 / calcSum(bars);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          height: height + 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: bars
                .map((bar) => _buildColumn(context, bars.indexOf(bar), bar))
                .toList(),
          )),
    );
  }

  Widget _buildColumn(BuildContext context, int index, LogChartBar bar) {
    return Container(
        height: height + 50,
//        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildBar(context, index, bar.items),
            _buildTile(bar.title),
          ],
        ));
  }

  Widget _buildBar(BuildContext context, int index, List<LogChartItem> items) {
    return Stack(
      children: [
        Column(
            children: items.map((item) {
          if (item.value == 0) {
            return Container(
              width: BAR_WIDTH,
              height: height,
            );
          } else {
            return _buildBox(log(item.value) * _scale, item.color);
          }
        }).toList()),
        Positioned.fill(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => barTap(context, index),
                )))
      ],
    );
  }

  Widget _buildBox(double height, Color color) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          width: BAR_WIDTH,
          height: height,
          color: color,
        ));
  }

  Container _buildTile(String title) {
    return Container(
      width: BAR_WIDTH,
      height: 50,
      child: Center(child: Text(title)),
    );
  }

  double calcSum(List<LogChartBar> data) {
    return data
        .map((bar) {
          double sum = 0;
          for (LogChartItem item in bar.items) {
            sum += log(item.value);
          }
          return sum;
        })
        .toList()
        .reduce(max);
  }
}

class LogChartBar {
  final String title;
  final List<LogChartItem> items;

  LogChartBar(this.title, this.items);

  LogChartBar.empty(this.title)
      : items = [LogChartItem(LogChart.DEFAULT_COLOR, 0)];
}

class LogChartItem {
  final Color color;
  final double value;

  LogChartItem(this.color, this.value);

  LogChartItem.defaultColor(this.value) : color = LogChart.DEFAULT_COLOR;
}
