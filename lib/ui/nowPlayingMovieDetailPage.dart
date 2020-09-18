import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movies_app/config/app_config.dart';
import 'package:movies_app/models/cast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movies_app/models/movie.dart';

import 'package:movies_app/widgets/castWidget.dart';

class NowPlayingMovieDetailPage extends StatefulWidget {
  final Movie nowPlayingMovie;


  const NowPlayingMovieDetailPage({Key key, this.nowPlayingMovie}) : super(key: key);

  @override
  _NowPlayingDetailPageState createState() => _NowPlayingDetailPageState();
}

class _NowPlayingDetailPageState extends State<NowPlayingMovieDetailPage> {
  Future<List<Cast>> getCast({
    String apiKey,
    int movieId,
  }) async {
    //https://api.themoviedb.org/3/movie/popular?api_key=7896722387e54b703820ce535aa3c1a3&language=en-US&page=1

    final http.Response response = await http.get(
        "https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$apiKey");

    final List<Cast> castList = json
        .decode(response.body)["cast"]
        .map<Cast>((f) => Cast.fromJson(f))
        .toList();

    castList.forEach((f) => print(f.name));

    return castList;
  }

  void profileTapped(String char){
    Fluttertoast.showToast(
        msg: "$char",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.yellow,
        fontSize: 16.0
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.nowPlayingMovie.title ?? "Undıfıned"}",
        ),
      ),
      body: Container(
        color: Colors.blueGrey,
        child: ListView(
          children: [
            Column(
              children: <Widget>[
                Hero(
                  tag: "${widget.nowPlayingMovie.backdropPath}",
                  child: Image.network(
                      "https://image.tmdb.org/t/p/w500${widget.nowPlayingMovie.backdropPath}"),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.star_border),
                    Text(
                      "IMDB  ",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                    ),
                    Text(
                      "${widget.nowPlayingMovie.voteAverage}",
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(5),
              color: Colors.black38,
              child: Text(
                "${widget.nowPlayingMovie.releaseDate}",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${widget.nowPlayingMovie.overview}",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            FutureBuilder(
                future: getCast(
                  apiKey: AppConfig.apiKey,
                  movieId: widget.nowPlayingMovie.id,
                ),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Cast>> snapshot) {
                  if (snapshot.hasData) {
                    //snapshot.data.forEach((f)=> print(f.backdropPath));
                    return Container(
                      height: height/4,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return CastWidget(
                              name: snapshot.data[index].name,
                              profilePath: snapshot.data[index].profilePath,
                              character: snapshot.data[index].character,
                              size: height,
                              onTapped: () => profileTapped(snapshot.data[index].character),
                            );
                          }),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
