import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  final List<TableRow> rows;

  const CustomTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(28, 255, 255, 255),
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.only(left: 15.0, top: 15, bottom: 0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
        },
        children: rows,
      ),
    );
  }
}
