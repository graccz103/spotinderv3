import 'genres_list.dart';

class GenreManager {
  // Pobiera wszystkie dostępne gatunki.
  List<String> fetchGenres() {
    return GenresList.getAllGenres();
  }

  // Sprawdza, czy dany gatunek jest poprawny.
  bool validateGenre(String genre) {
    return GenresList.isValidGenre(genre);
  }
}
