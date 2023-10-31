// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class WrappingGuideScreen extends StatefulWidget {
  const WrappingGuideScreen({super.key});

  @override
  State<WrappingGuideScreen> createState() => _WrappingGuideScreenState();
}

class _WrappingGuideScreenState extends State<WrappingGuideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How to wrap"),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GuideNumber(number: "1"),
                    SizedBox(width: 10),
                    const Text(
                      "Place on arm",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                    "You have two black leather boxes with straps in your tefillin bag. One is for the arm, the other for the head. Take out the arm one first—that’s the one that’s one smooth box, rather than four compartments.\n\nRemove the tefillin from the plastic case.\n\nThe arm-tefillin goes on the weaker arm: right-handed people do the left arm, lefties do the right arm.\n\nRoll up your sleeve so that the tefillin is in direct contact with your arm. Put your arm through the loop formed by the knotted strap. Place the black box up on your bicep, just below the halfway point between the shoulder and the elbow, right across from your heart "),
                const SizedBox(height: 25),
                Image.asset("assets/images/place_on_arm.webp"),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GuideNumber(number: "2"),
                    SizedBox(width: 10),
                    const Text(
                      "Say the Blessing",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                    "Recite the blessing. If you can read and understand the original Hebrew, say it in Hebrew. Otherwise, you can say it in any language you understand."),
                SizedBox(height: 20),
                Text(
                  "בָּרוּךְ אַתָּה ה’ אֱלֹהֵינוּ מֶלֶךְ הָעוֹלָם אֲשֶׁר קִדְּשָׁנוּ בְּמִצְוֹתָיו וְצִוָּנוּ לְהָנִיחַ תְּפִלִּין",
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 25),
                Text(
                  'Baruch atah Ado-nai, Elo-heinu melech ha’olam, asher kideshanu b’mitzvotav, v’tzivanu l’haniach tefillin.',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GuideNumber(number: "3"),
                    SizedBox(width: 10),
                    const Text(
                      "Bind the Arm-Tefillin",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                    "Tighten the strap around your arm, mindful that the knot stays in direct contact with the box.\n\nContinue to wrap: two more times over the strap-socket of the black box and around the biceps, then seven times around your arm and once around your palm. Leave the remainder of the strap loose."),
                SizedBox(height: 20),
                Image.asset("assets/images/guide_binding.webp"),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GuideNumber(number: "4"),
                    SizedBox(width: 10),
                    const Text(
                      "Place the Head Tefillin",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                    "Next, get out the head-tefillin. Remove the tefillin from the plastic case. The box goes on your head, just above your forehead. Center it in the middle of your head directly above the point that’s right between your eyes. The daled-shaped knot should rest on the base of your skull."),
                SizedBox(height: 20),
                Image.asset('assets/images/place_teffilin_2.webp'),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GuideNumber(number: "5"),
                    SizedBox(width: 10),
                    const Text(
                      "Tie on Hand",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                    "Now back to your hand. Wrap the remainder of the strap three times around your middle finger, like this: once around the base, then once just above the first joint, then one more time around the base. You’ve got some strap left over, so wrap it around your palm and tuck in the tail end."),
                SizedBox(height: 20),
                Image.asset('assets/images/guide_tie_on_hand.webp'),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GuideNumber(number: "6"),
                    SizedBox(width: 10),
                    const Text(
                      "Pray",
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                    "Meditate for a moment.\n\nBe conscious that G‑d Himself commanded that tefillin contain four Biblical passages which mention His Unity and the Exodus from Egypt, in order that we remember the miracles and wonders He performed for us, demonstrating that He has power and dominion over all.\n\nAlso note that He has enjoined us to place the tefillin on the arm adjacent to the heart, and on the head over the brain so that we submit our conscious soul (which is in the brain), as well as the desires and thoughts of our heart to Him.\n\nThus tefillin serve as an inspiring springboard to serve G‑d in a state of inspiration and to study Torah, His wisdom.\n\nAt very least, take a moment to remind yourself that tefillin is a mitzvah (commandment) of G‑d.\n\nIt is best to pray the entire morning prayers in one’s tefillin. However, if this is not possible, you can say the Shema prayer:"),
                SizedBox(height: 30),
                Text("Cover your eyes with your right hand and say:"),
                Text(
                  "שְׁמַע יִשְׂרָאֵל ה׳ אֱלֹהֵינוּ ה׳ אֶחָֽד",
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(height: 20),
                Text(
                  "Quietly, say the following:",
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  "בָּרוּךְ שֵׁם כְּבוֹד מַלְכוּתוֹ לְעוֹלָם וָעֶד",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(
                  "וְאָ֣הַבְתָּ֔ אֵ֖ת  ה׳ אֱלֹהֶ֑יךָ בְּכָל־לְבָבְךָ֥ וּבְכָל־נַפְשְׁךָ֖ וּבְכָל־מְאֹדֶֽך",
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 10),
                Text(
                  "וְהָי֞וּ הַדְּבָרִ֣ים הָאֵ֗לֶּה אֲשֶׁ֨ר אָנֹכִ֧י מְצַוְּךָ֛ הַיּ֖וֹם עַל־לְבָבֶֽךָ",
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 10),
                Text(
                  "וְשִׁנַּנְתָּ֣ם לְבָנֶ֔יךָ וְדִבַּרְתָּ֖ בָּ֑ם בְּשִׁבְתְּךָ֤ בְּבֵיתֶ֙ךָ֙ וּבְלֶכְתְּךָ֣ בַדֶּ֔רֶךְ וּֽבְשָׁכְבְּךָ֖ וּבְקוּמֶֽךָ",
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 10),
                Text(
                  "וּקְשַׁרְתָּ֥ם לְא֖וֹת עַל־יָדֶ֑ךָ וְהָי֥וּ לְטֹטָפֹ֖ת בֵּ֥ין עֵינֶֽיךָ",
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 10),
                Text(
                  "וּכְתַבְתָּ֛ם עַל־מְזוּזֹ֥ת בֵּיתֶ֖ךָ וּבִשְׁעָרֶֽיךָ             ",
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 100)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GuideNumber extends StatelessWidget {
  const GuideNumber({
    super.key,
    required this.number,
  });

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.white.withOpacity(0.2),
                offset: Offset(0, 2),
                blurRadius: 2)
          ]),
      child: Center(
          child: Text(
        number,
        style: const TextStyle(color: Colors.white, fontSize: 19),
      )),
    );
  }
}
