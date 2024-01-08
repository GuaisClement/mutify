import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mutify/models/artist.dart';


import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class ArtistRepository {

  // Assurez-vous d'avoir le bon token d'accès avant cette étape
  String _accessToken = "BQDPmfFsOBOSl7jxNr62H8nFaVALXDpE0WLCD9eEKyYQq4zQmBuBi-SX7ddngi156928bFgWMXC3fU6MfUZkf8DA_nGUlmqeZVKGUi6jyUQNtZKYNBo";

  Future<void> saveArtists(List<Artist> artists) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> listJson = [];
      for (final Artist artist in artists) {
        listJson.add(jsonEncode(artist.toJson()));
      }
      await prefs.setStringList('artists', listJson);
      print('save success');
    } catch (e) {
      print('Erreur lors de la sauvegarde des artistes : $e');
    }
  }

  Future<List<Artist>> loadArtists() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Artist> listArtists = [];
      List<String>? listJson = [];

      if (prefs.containsKey('artists')) {
        listJson = prefs.getStringList('artists');
      } else {
        print('La clé "companies" n\'existe pas dans les préférences.');
      }

      if (listJson != null) {
        return listJson.map((json)=> Artist.fromJson(jsonDecode(json))).toList();
      }else{
        return [];
      }
    } catch (e) {
      print('Erreur lors du chargement des artistes : $e');
      return [];
    }
  }



  Future<List<Artist>> fetchArtists(String query) async {


    final Response response = await http.get(
      Uri.parse("https://api.spotify.com/v1/search?query=$query&type=artist&market=FR&locale=fr-FR%2Cfr%3Bq%3D0.9%2Cen-US%3Bq%3D0.8%2Cen%3Bq%3D0.7&offset=0&limit=10"),
      headers: {
        "Authorization": "Bearer $_accessToken",
      },
    );
    if(response.statusCode == 200) {
      final List<Artist> artistsReturned = []; // Liste que la méthode va renvoyer

      // Transformation du JSON (String) en Map<String, dynamic>
      final Map<String, dynamic> json = jsonDecode(response.body);

      if(json.containsKey("artists")) {

        // Récupération des "features"
        final List<dynamic> artists = json['artists']['items'];

        // Transformation de chaque "feature" en objet de type "Address"
        for (Map<String, dynamic> artist in artists) {

          String id = artist['id'];
          String name = artist['name'];
          String imageUrl = artist['images'].isNotEmpty ? artist['images'].first['url'] : '';
          artistsReturned.add(Artist(id, name, imageUrl));
        }
      }
      print(artistsReturned);
      return artistsReturned;
    } else if(response.statusCode == 401){
      // If status code is 500, request a new access token
      final newTokenResponse = await http.post(
        Uri.parse("https://accounts.spotify.com/api/token"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "grant_type": "client_credentials",
          "client_id": "afe425191c374e2a9a85b9ef3aaec6f6",
          "client_secret": "aabfd69762034f80914263c4eeba0be2",
        },
      );

      if (newTokenResponse.statusCode == 200) {
        // Successfully obtained a new access token
        final Map<String, dynamic> newTokenJson = jsonDecode(newTokenResponse.body);
        _accessToken = newTokenJson['access_token'];

        // Retry the original request with the new access token
        return fetchArtists(query);
      } else {
        throw Exception('Failed to obtain a new access token');
      }
    }else {
      throw Exception('Failed to load Artist');
    }
  }

}