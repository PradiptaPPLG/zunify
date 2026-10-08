/// Route path constants.
library;

abstract final class AppRoutes {
  static const home = '/home';
  static const search = '/search';
  static const library = '/library';
  static const history = '/library/history';
  static const settings = '/settings';
  static const player = '/player';
  static const playlists = '/library/playlists';

  static String playlistDetail(String id) => '/library/playlists/$id';
}
