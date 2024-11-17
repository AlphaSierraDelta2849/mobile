import 'package:flutter/material.dart';
import 'package:wird/models/rosary.dart';
import 'package:wird/models/serie.dart';
import 'package:wird/pages/home.dart';
import 'package:wird/services/databaseService.dart';

class Prayer extends StatefulWidget {
  const Prayer({super.key, this.rosary});
  final rosary;

  @override
  State<Prayer> createState() => _PrayerState();
}

class _PrayerState extends State<Prayer> {
  DatabaseService db = DatabaseService.instance;
  List<Serie> series = [];
  List<int> deletedSeries = [];
  int currentSerie = -1;
  int currentCount = 0;
  late Rosary rosary;
  String rosaryName = 'mon wird';
  String currentSerieTitle = 'Al Hamdoulillah';
  late TextEditingController titleController = TextEditingController();
  late TextEditingController rosaryTitleController = TextEditingController();
  void incrementCount() {
    setState(() {
      currentCount++;
    });
  }

  @override
  void initState() {
    super.initState();
    rosaryTitleController.text = rosaryName;
    titleController.text = currentSerieTitle;
    if (widget.rosary != null) {
      rosary = widget.rosary;
      fetchSeries();
    }
  }

  Future<void> fetchSeries() async {
    final db = DatabaseService.instance;
    print(rosary.id);
    List<Serie> listSeries = await db.getSeriesByRosaryId(rosary.id!);
    setState(() {
      series = listSeries;
    });
    print(listSeries);
  }

  void decrementCount() {
    setState(() {
      if (currentCount > 0) currentCount--;
    });
  }

  void changeCurrentSerie(int numSerie) {
    setState(() {
      currentSerie = numSerie;
      currentCount = series[numSerie].count;
      currentSerieTitle = series[numSerie].title;
    });
  }

  Widget inputDialog() {
    return AlertDialog(
      title: const Text('Sauvegarder mon wird'),
      content: Container(
          height: 100,
          child: Column(children: [
            TextField(
              decoration:
                  const InputDecoration(hintText: 'Veuillez donner un titre'),
              controller: rosaryTitleController,
            )
          ])),
      actions: [
        TextButton(
          onPressed: () => {Navigator.pop(context, 'OK')},
          child: const Text('Retour'),
        ),
        TextButton(
          onPressed: () => {
            setState(() {
              rosaryName = rosaryTitleController.text;
            }),
            saveWird()
          },
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }

  Widget dialog() {
    return AlertDialog(
      title: const Text('Quitter?'),
      content: const Text('Voulez-vous quitter sans sauvegarder?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('Retour'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          ),
          child: const Text('Oui. Quitter'),
        ),
      ],
    );
  }

  void addToSerie() {
    Serie serie = Serie(title: currentSerieTitle, count: currentCount);
    if (currentSerie == -1)
      series.add(serie);
    else {
      series[currentSerie] = serie;
      currentSerie = -1;
    }
    currentCount = 0;
    setState(() {});
  }

  void deleteFromSerie(int serieIndex) {
    // print(series[serieIndex].id);
    // deletedSeries.add(series[serieIndex].id!);
    series.removeAt(serieIndex);
    print(serieIndex);

    // print(deletedSeries);
    setState(() {});
  }

  void resetAll() {
    series.clear();
    resetSerie();
  }

  void resetSerie() {
    currentCount = 0;
    currentSerieTitle = '';
    setState(() {});
  }

  Future<void> saveWird() async {
    print(titleController.text);
    if (widget.rosary == null) {
      final rosary = Rosary(name: rosaryName);
      int idRosary = await db.insertRosary(rosary);
      // print(idRosary as int);
      int idS = 0;
      print('insert');
      print(series);
      series.forEach((serie) async {
        idS = await db.insertSerie(serie, idRosary);
        if (idS != 0) {
          print(serie.count);
        }
      });
      endWird();
    } else {
      setState(() {
        rosary.name = rosaryName;
      });

      await db.updateRosary(rosary);
      db.deleteSeriesByRosary(rosary.id!);
      series.forEach((serie) async {
        await db.insertSerie(serie, rosary.id!);
      });
      // print(idRosary as int);
      // print(series);
      // print('updated');
      // for (var serie in series) {
      //   await db.updateSerie(serie);
      //   print(serie.count);
      // }
      // int deletedSerie = 0;
      // for (var serie in deletedSeries) {
      //   await db.deleteSerie(serie);
      //   print(deletedSerie);
      // }
      endWird();
    }
  }

  void endWird() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const Home(),
    ));
  }

  void backToHome() {
    showModal(1);
  }

  void showModal(int modalType) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return modalType == 1 ? dialog() : inputDialog();
        });

    // Navigator.of(context).pop();
  }

  editText() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: 650,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(icon: Icon(Icons.edit)),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  ElevatedButton(
                    child: const Text('Annuler'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    child: const Text('Sauvegarder'),
                    onPressed: () {
                      setState(() {
                        currentSerieTitle = titleController.text;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rosary != null ? widget.rosary.name : rosaryName),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  SizedBox(
                      height: height / 3.5,
                      child: ListView.builder(
                          itemCount: series.length,
                          itemBuilder: (context, i) {
                            return series.isNotEmpty
                                ? Column(children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${series[i].count} ${series[i].title}',
                                          style: currentSerie == i
                                              ? TextStyle(
                                                  backgroundColor:
                                                      Colors.green.shade300)
                                              : null,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          iconSize: 20,
                                          color: Colors.purple.shade300,
                                          onPressed: () =>
                                              changeCurrentSerie(i),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.clear_outlined),
                                          iconSize: 20,
                                          color: Colors.redAccent,
                                          onPressed: () => {
                                            print('delete'),
                                            deleteFromSerie(i)
                                          },
                                        )
                                      ],
                                    )
                                  ])
                                : const Text(
                                    'Aucune série terminée pour l instant ');
                          }))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(currentSerieTitle),
                IconButton(
                  onPressed: editText,
                  icon: const Icon(Icons.edit_square),
                  color: const Color.fromARGB(255, 245, 39, 207),
                )
              ],
            ),
            Text(
              '$currentCount',
              style: const TextStyle(fontSize: 70),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: decrementCount,
                  style: ElevatedButton.styleFrom(),
                  child: const Text('Waagni'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: incrementCount,
                  child: const Text('Wagni'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: addToSerie,
              child: const Text('limm'),
            ),
            const SizedBox(
              height: 50,
            ),
            Spacer(),
            Row(
              children: [
                IconButton(
                  onPressed: backToHome,
                  icon: const Icon(Icons.arrow_back_ios_new),
                  iconSize: 50,
                ),
                const Spacer(),
                IconButton(
                  onPressed: resetSerie,
                  icon: const Icon(Icons.exposure_zero_rounded),
                  iconSize: 50,
                ),
                const Spacer(),
                IconButton(
                  onPressed: resetAll,
                  icon: const Icon(Icons.restore),
                  iconSize: 50,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => showModal(2),
                  icon: const Icon(Icons.save),
                  iconSize: 50,
                )
              ],
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}

class BottomSheetExample extends StatelessWidget {
  const BottomSheetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('showModalBottomSheet'),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Modal BottomSheet'),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
