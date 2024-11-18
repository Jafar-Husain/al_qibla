import 'package:al_qibla/provider/app_provider.dart';
import 'package:al_qibla/widgets/missed_prayer_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ... (Your existing imports)

class MissedPrayerScreen extends StatelessWidget {
  const MissedPrayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text("Missed Prayers"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: ListView(
          children: [
            MissedContainer(
              prayerName: "Fajr",
              missedNumber: Provider.of<AppProvider>(context).fajrMissed(),
              Color1: Provider.of<AppProvider>(context).firstGrad[0],
              Color2: Provider.of<AppProvider>(context).secondGrad[0],
              onClickAction: () async {
                Provider.of<AppProvider>(context, listen: false).setFajrMissed(
                  Provider.of<AppProvider>(context, listen: false)
                          .fajrMissed() +
                      1,
                );
              },
              onClickMinus: () async {
                Provider.of<AppProvider>(context, listen: false).setFajrMissed(
                  await Provider.of<AppProvider>(context, listen: false)
                          .fajrMissed() -
                      1,
                );
              },
              onClickEdit: () {
                _showInputDialog(context,0);
              },
            ),
            MissedContainer(
              prayerName: "Dhuhr",
              missedNumber: Provider.of<AppProvider>(context).dhuhrMissed(),
              Color1: Provider.of<AppProvider>(context).firstGrad[2],
              Color2: Provider.of<AppProvider>(context).secondGrad[2],
              onClickAction: () {
                Provider.of<AppProvider>(context, listen: false).setDhuhrMissed(
                  Provider.of<AppProvider>(context, listen: false)
                          .dhuhrMissed() +
                      1,
                );
              },
              onClickMinus: () {
                Provider.of<AppProvider>(context, listen: false).setDhuhrMissed(
                  Provider.of<AppProvider>(context, listen: false)
                          .dhuhrMissed() -
                      1,
                );
              },
              onClickEdit: () {
                 _showInputDialog(context,1);
              },
            ),
            MissedContainer(
              prayerName: "Asr",
              missedNumber: Provider.of<AppProvider>(context).asrMissed(),
              Color1: Provider.of<AppProvider>(context).firstGrad[3],
              Color2: Provider.of<AppProvider>(context).secondGrad[3],
              onClickAction: () {
                Provider.of<AppProvider>(context, listen: false).setAsrMissed(
                  Provider.of<AppProvider>(context, listen: false).asrMissed() +
                      1,
                );
              },
              onClickMinus: () {
                Provider.of<AppProvider>(context, listen: false).setAsrMissed(
                  Provider.of<AppProvider>(context, listen: false).asrMissed() -
                      1,
                );
              },
              onClickEdit: () {
                 _showInputDialog(context,2);
              },
            ),
            MissedContainer(
              prayerName: "Maghrib",
              missedNumber: Provider.of<AppProvider>(context).maghribMissed(),
              Color1: Provider.of<AppProvider>(context).firstGrad[4],
              Color2: Provider.of<AppProvider>(context).secondGrad[4],
              onClickAction: () {
                Provider.of<AppProvider>(context, listen: false)
                    .setMaghribMissed(
                  Provider.of<AppProvider>(context, listen: false)
                          .maghribMissed() +
                      1,
                );
              },
              onClickMinus: () {
                Provider.of<AppProvider>(context, listen: false)
                    .setMaghribMissed(
                  Provider.of<AppProvider>(context, listen: false)
                          .maghribMissed() -
                      1,
                );
              },
              onClickEdit: () {
                 _showInputDialog(context,3);
              },
            ),
            MissedContainer(
              prayerName: "Isha",
              missedNumber: Provider.of<AppProvider>(context).ishaMissed(),
              Color1: Provider.of<AppProvider>(context).firstGrad[5],
              Color2: Provider.of<AppProvider>(context).secondGrad[5],
              onClickAction: () {
                Provider.of<AppProvider>(context, listen: false).setIshaMissed(
                  Provider.of<AppProvider>(context, listen: false)
                          .ishaMissed() +
                      1,
                );
              },
              onClickMinus: () {
                Provider.of<AppProvider>(context, listen: false).setIshaMissed(
                  Provider.of<AppProvider>(context, listen: false)
                          .ishaMissed() -
                      1,
                );
              },
              onClickEdit: () {
                 _showInputDialog(context,4);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showInputDialog(
    BuildContext context, int prayerInt) async {
  String inputValue = '';

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter Value'),
        content: TextField(
          keyboardType: TextInputType.number, // Set keyboard type to number
          onChanged: (value) {
            inputValue = value;
          },
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              // Handle the 'Add' button click
              if (prayerInt == 0) {
                Provider.of<AppProvider>(context, listen: false)
                    .setFajrMissed(int.parse(inputValue));
              }
              else if (prayerInt==1) {
                Provider.of<AppProvider>(context, listen: false)
                    .setDhuhrMissed(int.parse(inputValue));
              }
              else if (prayerInt==2) {
                Provider.of<AppProvider>(context, listen: false)
                    .setAsrMissed(int.parse(inputValue));
              }
              else if (prayerInt==3) {
                Provider.of<AppProvider>(context, listen: false)
                    .setMaghribMissed(int.parse(inputValue));
              }
              else if (prayerInt==4) {
                Provider.of<AppProvider>(context, listen: false)
                    .setIshaMissed(int.parse(inputValue));
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
