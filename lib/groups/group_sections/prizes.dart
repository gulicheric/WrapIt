import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tefillin/models/prizes_model.dart';
import 'package:tefillin/widgets/custom_table.dart';

class PrizeTab extends StatefulWidget {
  const PrizeTab({super.key});

  @override
  State<PrizeTab> createState() => _PrizeTabState();
}

class _PrizeTabState extends State<PrizeTab> {
  List<PrizesModel> prizes = [
    PrizesModel(prize: "\$5 Gift Card", days: 5),
    PrizesModel(prize: "WrapIt Kippah", days: 10),
    PrizesModel(prize: "Siddur", days: 15),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text.rich(
                  TextSpan(
                    text: 'You are ',
                    children: <TextSpan>[
                      TextSpan(
                        text: ' 3 ',
                        style: TextStyle(
                            color: Theme.of(context).accentColor, fontSize: 18),
                      ),
                      const TextSpan(
                        text: ' days away from your next prize!',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              CustomTable(
                rows: [
                  const TableRow(
                    children: [
                      TableCell(
                        child: Text(
                          'Prize',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          'Days',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const TableRow(
                      children: [SizedBox(height: 15), SizedBox(height: 15)]),
                  ...List.generate(prizes.length, (index) {
                    return TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Text(prizes[index].prize)),
                        ),
                        TableCell(
                          child: Text(prizes[index].days.toString()),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
