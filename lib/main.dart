import 'package:chandler/models/chandlers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chandler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: Hive.openBox('locations'),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MyHomePage(title: 'Chandler');
          }
          return Scaffold(
              body: Center(
            child: Text(
              "Opening Chandler...",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ));
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
      ),
      body: ChandlerLocationListView(),
      floatingActionButton: SaveLocationButton(),
    );
  }
}

class SaveLocationButton extends StatefulWidget {
  @override
  _SaveLocationButtonState createState() => _SaveLocationButtonState();
}

class _SaveLocationButtonState extends State<SaveLocationButton> {
  bool _isLoading = false;
  Future<void> _onSave() async {
    final service = await Geolocator.isLocationServiceEnabled();
    if (!service) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location Service was disabled."),
          action: SnackBarAction(label: "Retry", onPressed: _onSave),
        ),
      );

      return;
    }
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Saving Location..."),
        duration: Duration(minutes: 60),
      ),
    );
    setState(() {
      _isLoading = true;
    });
    final location = await Geolocator.getCurrentPosition();
    final chandler = Chandler(
      latitude: location.latitude,
      longitude: location.longitude,
      createdAt: DateTime.now(),
    );
    Hive.box('locations').add(chandler.toJson());
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      disabledElevation: 0,
      onPressed: _isLoading ? null : _onSave,
      icon: Icon(Icons.save),
      label: Text("${!_isLoading ? 'Save' : 'Loading...'}"),
    );
  }
}

class ChandlerLocationListView extends StatefulWidget {
  @override
  _ChandlerLocationListViewState createState() =>
      _ChandlerLocationListViewState();
}

typedef Chandlers = List<Chandler>;

class _ChandlerLocationListViewState extends State<ChandlerLocationListView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('locations').listenable(),
      builder: (context, Box box, _) {
        final data = box.values.cast<String>().toList();

        if (data.isEmpty) {
          return Center(
            child: Text("No saved Locations"),
          );
        }
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final chandler = Chandler.fromJson(data[index]);
            return ListTile(
              title: Text("${chandler.createdAt}"),
              subtitle: Text(
                "Latitude: ${chandler.latitude}, Longitude: ${chandler.longitude}",
              ),
            );
          },
        );
      },
    );
  }
}
