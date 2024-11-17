import 'package:flutter/material.dart';
import 'package:wird/models/rosary.dart';
import 'package:wird/models/serie.dart';
import 'package:wird/pages/prayer.dart';
import 'package:wird/services/databaseService.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Rosary> rosaries = [];
  List<Serie> series = [];
  final db = DatabaseService.instance;
  void navigateToPrayer(context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Prayer()));
  }

  void navigateToPrayerEdit(context, rosary) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Prayer(rosary: rosary)));
  }

  @override
  void initState() {
    super.initState();
    fetchRosaries();
  }

  Future<void> deleteRosaryWithSeries(int rosary) async {
    await db.deleteRosary(rosary);
    await db.deleteSeriesByRosary(rosary);
    setState(() {
      fetchRosaries();
    });
  }

  Future<void> fetchRosaries() async {
    List<Rosary> listRosaries = await db.getRosaries();
    // List<Serie> listSeries = await db.getSeries();
    // print(listSeries);
    print(listRosaries);
    listRosaries.forEach((rosary) async {
      List<Serie> listSeries = await db.getSeriesByRosaryId(rosary.id!);
      setState(() {
        rosary.rosarySeries = listSeries;
      });
    });
    setState(() {
      rosaries = listRosaries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes wirds'),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
                child: Expanded(
              child: rosaries.isNotEmpty
                  ? ListView.builder(
                      itemCount: rosaries.length,
                      itemBuilder: (BuildContext buildContext, index) {
                        return GestureDetector(
                            onTap: () => {
                                  print(rosaries[index].id),
                                  navigateToPrayerEdit(context, rosaries[index])
                                },
                            child: Container(
                                padding: EdgeInsets.all(5),
                                child: Card(
                                    child: Column(
                                  children: [
                                    Row(children: [
                                      Text(
                                        rosaries[index].name,
                                      ),
                                      IconButton(
                                        icon:
                                            Icon(Icons.delete_forever_outlined),
                                        onPressed: () async =>
                                            await deleteRosaryWithSeries(
                                                rosaries[index].id!),
                                      )
                                    ]),
                                    Divider(),
                                    Container(
                                        height: 70,
                                        child: ListView.builder(
                                            itemCount: rosaries[index]
                                                .rosarySeries
                                                .length,
                                            itemBuilder:
                                                (BuildContext buildContext, i) {
                                              return Container(
                                                child: Row(
                                                  children: [
                                                    Text(rosaries[index]
                                                        .rosarySeries[i]
                                                        .count
                                                        .toString()),
                                                    Text(
                                                        ' ${rosaries[index].rosarySeries[i].title}')
                                                  ],
                                                ),
                                              );
                                            }))
                                  ],
                                ))));
                      })
                  : Center(
                      child: const Text('Rien à afficher'),
                    ),
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 5,
          child: const Icon(Icons.add),
          onPressed: () => navigateToPrayer(context)),
    );
  }
}
