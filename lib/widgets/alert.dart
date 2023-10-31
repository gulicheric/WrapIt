import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCustomDialog(BuildContext context, String dialogText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          dialogText, // use the dialogText parameter here
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 141, 140, 140),
        actions: <Widget>[
          Align(
            alignment: Alignment.center,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.blue.withOpacity(0.5);
                    } else {
                      return Colors.blue;
                    }
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.blue.withOpacity(0.5);
                    } else {
                      return Colors.white;
                    }
                  },
                ),
              ),
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}
