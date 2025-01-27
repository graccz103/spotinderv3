import 'components/spotify_service/auth_service.dart';
import 'components/spotify_service/artist_service.dart';
import 'components/spotify_service/album_service.dart';
import 'components/spotify_service/track_service.dart';
import 'components/spotify_service/utils.dart';
import 'components/spotify_service/genre_manager.dart';

class SpotifyService {
  late final AuthService _authService;
  late final ArtistService _artistService;
  late final AlbumService _albumService;
  late final TrackService _trackService;
  late final GenreManager _genreManager;
  List<String> getAvailableGenres() {
    return _genreManager.fetchGenres();
  }
  bool validateGenre(String genre) {
    return _genreManager.validateGenre(genre);
  }

  // Konstruktor z wymaganymi parametrami
  SpotifyService({
    required String clientId,
    required String clientSecret,
  }) {
    _authService = AuthService(clientId: clientId, clientSecret: clientSecret);
    _albumService = AlbumService();
    _trackService = TrackService();
    _genreManager = GenreManager();
    _artistService = ArtistService(
      authService: _authService,
      albumService: _albumService,
      trackService: _trackService,
    );
  }



  // Funkcja pobierająca losowego artystę, uwzględniająca listę wykluczonych ID
  Future<Map<String, dynamic>> getRandomArtist({
    required List<String> excludedIds,
    String? genre,
  }) async {
    return await _artistService.getRandomArtist(
      excludedIds: excludedIds,
      genre: genre, // Przekaż parametr genre
    );
  }


  // Funkcja pobierająca szczegóły artysty
  Future<Map<String, dynamic>> getArtistData(Map<String, dynamic> artist) async {
    final accessToken = await _authService.getAccessToken();
    return await _artistService.getArtistData(artist, accessToken);
  }

  // Funkcja pobierająca najnowszy album artysty
  Future<Map<String, dynamic>> getLatestAlbum(String artistId) async {
    final accessToken = await _authService.getAccessToken();
    return await _albumService.getLatestAlbum(artistId, accessToken);
  }

  // Funkcja pobierająca topowy utwór artysty
  Future<Map<String, dynamic>> getTopTrack(String artistId) async {
    final accessToken = await _authService.getAccessToken();
    return await _trackService.getTopTrack(artistId, accessToken);
  }

  // Funkcja pobierająca info o artyście z last.fm
  Future<Map<String, dynamic>> getArtistWithDescription(String artistName) async {
    final description = await _artistService.getArtistDescription(artistName);
    return {
      'name': artistName,
      'description': description ?? 'No description available.'
    };
  }


  // Funkcja otwierająca link do Spotify
  Future<void> openSpotifyLink(String url) async {
    await openSpotifyLink(url);
  }
}
