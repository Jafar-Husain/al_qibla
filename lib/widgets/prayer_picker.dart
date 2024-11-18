import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/app_provider.dart';

class prayerPicker extends StatelessWidget {
  const prayerPicker({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat customDateFormat = Provider.of<AppProvider>(context).getTimeFormat24()
    ? DateFormat('HH:mm')
    : DateFormat('h:mm a');
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 216,
        child: CupertinoPicker(
          scrollController: Provider.of<AppProvider>(context).scrollController,
          itemExtent: 50,
          magnification: 1.22,
          squeeze: 0.75,
          diameterRatio: 3,
          useMagnifier: true,
          onSelectedItemChanged: (index) {
            Provider.of<AppProvider>(context,listen: false).onPickerChange(index);
          },
          children: List<Widget>.generate(
            Provider.of<AppProvider>(context).prayerNames.length,
            (int index) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      Provider.of<AppProvider>(context).prayerNames[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                     Text(
                      customDateFormat.format(Provider.of<AppProvider>(context).prayerTimesList[index]),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
