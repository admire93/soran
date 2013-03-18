__soran =
  BUGS_PREFIX: 'bugs'
  NAVER_PREFIX: 'naverMusic'  
  TRACK_POSTFIX: "Track"
  EVENT_USER_INIT: 'userInit'
  EVENT_LISTEN: 'listen'
  BUGS_TRACK_API_URL: "http://music.bugs.co.kr/player/track/"
  BUGS_DOMAIN: 'bugs.co.kr'
  ERROR: 'Error'
  servicePrefix: ''
  isListen: false
  conn: undefined
  loggedAt: 80
  nowPlaying:
    id: ''
    len: 0

  getUserIdentifier: () ->
    unless this.servicePrefix.length == 0 and this.user.name.length == 0
      "#{ n }@#{ this.servicePrefix }"
    else
      ''

  init: (conn) ->
    this.conn = conn
    that = this

    $(document).on 'click', () ->
      bugsUserNameCover = $('.username strong')
      if document.domain is that.BUGS_DOMAIN and bugsUserNameCover.length isnt 0
        that.servicePrefix = that.BUGS_PREFIX
        d =
          kind: that.EVENT_USER_INIT
          identifier: that.getUserIdentifier bugsUserNameCover.text()
        that.conn.postMessage d

  track: (id, artist, albumArtist, albumTitle, title, genre, length, releaseDate) ->
    data =
      id: id
      artist: artist
      albumArtist: albumArtist
      albumTitle: albumTitle
      title: title
      genre: genre
      length: length
      releaseDate: releaseDate
    data

__soran.init chrome.extension.connect()