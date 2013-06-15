BUGS_ARTIST_URL = "http://music.bugs.co.kr/artist/"
BUGS_ALBUM_URL = "http://music.bugs.co.kr/album/"
NAVER_ARTIST_URL = "http://music.naver.com/artist/home.nhn?artistId="
NAVER_ALBUM_URL = "http://music.naver.com/album/index.nhn?albumId="
BUGS_DIRECT_URL = "http://music.bugs.co.kr/newPlayer?trackId="

Soran = () ->
  true

Soran.prototype =
  extend: (d) ->
    if typeof(d) is 'object'
      for k, v of d
        if this.hasOwnProperty k
          throw k + " already defined in object"
        else
          this[k] = v
    else
      throw JSON.stringify(d) + ' isnt object'
  playlists: []
  sort:
    referencedAt: (x) ->
      parseInt $(x).data("music-referenced-at")
    updatedAt: (x) ->
      parseInt $(x).data("music-updated-at")
    artist: (x) ->
      JSON.parse(decodeURIComponent($(x).data("music"))).artist
    album: (x) ->
      JSON.parse(decodeURIComponent($(x).data("music"))).albumTitle
    count: (x) ->
      parseInt $(x).data("music-count")
    name: (x) ->
      JSON.parse(decodeURIComponent($(x).data("music"))).title
  currentSort: ''
  showPlayList: (_by) ->
    if window.soran.sort.hasOwnProperty _by
      if window.soran.currentSort isnt _by
        lists = $(this.playlists.get().qsort(this.sort[_by]).reverse())
        this.currentSort = _by
      else
        lists = $($("#listen tbody tr").get().reverse())

      $("#listen tbody tr").remove()
      $("#listen tbody").append(lists)
    true

  withCircle: ($dest, env, task, argument, callback) ->
    $p = $($dest.parent())
    $loading = $('<div class=\"loading\" style="width: 150px; margin: 0 auto;"><i class="icon-refresh icon-spin" style="font-size:100pt; color: #1ABC9C"></i><br /><h3 style="font-weight: 900">LOADING</h3></div>')
    $p.append($loading)
    f = (c) ->
      $loading.remove()
      callback(c)

    argument.push(f)
    task.apply(env, argument)
    true

  getPlayList: (identifier, callback) ->
    option =
      url: '/musics?identifier=' + identifier
      dataType: 'json'
      success: (d) ->
        console.log(d)
        callback(d)
      error: (e, j, x) ->
        errorResp =
          code: 500
        callback(errorResp)

    $.ajax option
    true
  
  getAllEdge: (identifier, callback) ->
    option =
      url: "/edge?identifier=#{ identifier }"
      success: (d) ->
        callback d

    $.ajax option
    true

  initPlaylist: (identifier) ->
    that = this
    this.withCircle $("#listen"), this, this.getPlayList, [identifier], (d) ->
      $tbody = $("#listen tbody")
      tbody = ""
      if d.code == 200
        for edge in d.content
          do (edge) ->
            music = JSON.parse(edge.point.data)
            if music.albumArtist isnt undefined and music.title isnt undefined
              getDataColumn = (titleURL, artistURL, albumURL) ->
                [
                  "<tr id=\"#{ edge.point.identifier }\" data-music=\"#{ encodeURIComponent edge.point.data }\"",
                  'data-music-count="' + edge.count + '" data-music-referenced-at="' + edge.point.referencedAt + '" ',
                  'data-music-updated-at="' + edge.point.updatedAt + '">',
                  '<td class="title">',
                  "<a href=\"#{ titleURL }\">",
                  music.title,
                  '</a>',
                  '</td>',
                  '<td class="artist">',
                  '<a href="' + artistURL + '">',
                  music.artist,
                  '</a>',
                  '</td>',
                  '<td class="album">',
                  '<a href="' + albumURL + '">',
                  music.albumTitle,
                  '</a>',
                  '</td>',
                  '<td class="count">',
                  edge.count,
                  '</td>',
                  '</tr>'
                ].join('')
              splited = edge.point.identifier.split("-")
              serviceName = splited[0]
              trackNum = splited[1]
              if serviceName is "bugs"
                link = BUGS_DIRECT_URL + trackNum
                tbody += getDataColumn(
                  "javascript:void(window.open('#{ link }', 'Bugs Player', 'width=384,height=667,resizable=0'))",
                  BUGS_ARTIST_URL + music.artistId,
                  BUGS_ALBUM_URL + music.albumId
                )
              else if serviceName is "naverMusic"
                tbody += getDataColumn(
                  "http://music.naver.com/search/search.nhn?query=" + encodeURIComponent(music.title + " " + music.artist),
                  NAVER_ARTIST_URL + music.artistId,
                  NAVER_ALBUM_URL + music.albumId
                )
      $content = $(tbody)
      $tbody.append $content
      that.playlists = $content.clone()
      that.showPlayList "referencedAt"

window.soran = new Soran()
