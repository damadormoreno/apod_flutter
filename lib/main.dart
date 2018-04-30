
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'models/APODImage.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
      new MaterialApp(
          home: new Scaffold(
            appBar: new AppBar(
              title: new Text('Apod List'),
            ),
            body: new FutureBuilder(
              future: getApod(),
                builder: (BuildContext context,
                AsyncSnapshot<List> snapshot) {
              if (!snapshot.hasData)
                // Shows progress indicator until the data is load.
                return new MaterialApp(
                    home: new Scaffold(
                      body: new Center(
                        child: new CircularProgressIndicator(),
                      ),
                    )
                );
              // Shows the real data with the data retrieved.
              List apods = snapshot.data;
              return new CustomScrollView(
                primary: false,
                slivers: <Widget>[
                  new SliverPadding(
                    padding: const EdgeInsets.all(10.0),
                    sliver: new SliverGrid.count(
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      crossAxisCount: 2,
                      children: createApodCardItem(apods, context),
                    ),
                  ),
                ],
              );
            }),
          )
      )
  );
}

List<APODImage> createApodList(List data){
  List<APODImage> list = new List();

  for(int i = 0; i < data.length; i++){
    String concepts = data[i]["concepts"];
    String copyright = data[i]["copyright"];
    String date = data[i]["date"];
    String explanation = data[i]["explanation"];
    String hdurl = data[i]["hdurl"];
    String media_type = data[i]["media_type"];
    String service_version = data[i]["service_version"];
    String title = data[i]["title"];
    String url = data[i]["url"];

    APODImage apodImage = new APODImage(concepts, copyright, date,
        explanation, hdurl, media_type, service_version, title, url);

    list.add(apodImage);
  }
return list;
}

Future<List<APODImage>> getApod() async {
  var now = new DateTime.now();
  var oneWeekLater = now.subtract(Duration(days: 7));
  var formatter = new DateFormat('yyyy-MM-dd');
  String nowString = formatter.format(now);
  String oneWeekLaterString = formatter.format(oneWeekLater);

  final String url = 'https://api.nasa.gov/planetary/apod?'
      'api_key=ND6PCgDSOtfIgOvoiLoa7SHTvd4gmX6BeDfHCAzG&&'
      'start_date=${oneWeekLaterString}&end_date=${nowString}&concept_tags=true';
  var httpClient = new HttpClient();
  try {
    // Make the call
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.OK) {
      var responseBody = await response.transform(utf8.decoder).join();
      // Get the result map*/
      List data = json.decode(responseBody);
      List<APODImage> apodList = createApodList(data);

      return apodList.reversed.toList();
    } else {
      print("Failed http call.");
    }
  } catch (exception) {
    print(exception.toString());
  }
  return null;
}

List<Widget> createApodCardItem(List<APODImage> apods, BuildContext context) {
  // Children list for the list.
  List<Widget> listElementWidgetList = new List<Widget>();
  if (apods != null) {
    var lengthOfList = apods.length;
    for (int i = 0; i < lengthOfList; i++) {
      APODImage apodImage = apods[i];
      // Image URL
      var imageURL = apodImage.url;
      // List item created with an image of the poster
      if (apodImage.mediaType == "image") {
        var listItem = new GridTile(
            footer: new GridTileBar(
              backgroundColor: Colors.black45,
              title: new Text(apodImage.title),
            ),
            child: new GestureDetector(
              onTap: () {
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text("Go to detail"),
                ));
              },
              child: new Image.network(imageURL, fit: BoxFit.cover),
            )
        );

      listElementWidgetList.add(listItem);
      }
    }
  }
  return listElementWidgetList;
}
