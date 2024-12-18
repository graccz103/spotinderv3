class GenresList {
  static const List<String> genres = [
    'pop',
    'rock',
    'jazz',
    'hip-hop',
    'classical',
    'electronic',
    'blues',
    'samba',
    'reggae',
    'alternative',
    'A Cappella',
    'Country',
    'Dance',
    'Folk',
    'Funk',
    'Gospel',
    'House',
    'Indie',
    'Metal',
    'Punk',
    'R&B',
    'Soul',
    'Techno',
    'Trance'
  ];

  static List<String> getAllGenres() => genres;

  static bool isValidGenre(String genre) => genres.contains(genre);
}
