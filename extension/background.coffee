mintpressoAPIKey = "240ff06dee7-f79f-423f-9684-0cedd2c13ef3::240"

_soran =
  BUGS_PREFIX: 'bugs'
  NAVER_PREFIX: 'naverMusic'  
  TRACK_POSTFIX: "Track"
  EVENT_USER_INIT: 'userInit'
  EVENT_LISTEN: 'listen'
  BUGS_TRACK_API_URL: "http://music.bugs.co.kr/player/track/"
  SORAN_TYPE_USER: 'user' 
  SORAN_TYPE_MUSIC: 'music'
  SORAN_TYPE_ARTIST: 'artist'
  SORAN_VERB_SING: 'sing'
  SORAN_VERB_LISTEN: 'listen'
  ERROR: 'Error'
  user:
    type: 'user'
    identifier: ''

  addUser: (identifier) ->
    console.log 'Add user, ', identifier
    if identifier.length isnt 0 and this.user.identifier isnt identifier
      this.user.identifier = identifier
      data = 
        'type': 'user'
        'identifier': identifier
      mintpresso.set data

  addMusic: (d, callback) ->
    data =
      'type': this.SORAN_TYPE_MUSIC
      'data': {}

    for k, v of d
      if k is "identifier"
        data[k] = d[k]
      else
        data.data[k] = d[k]
        
    console.log 'Add music, ', data
    mintpresso.set data, (dt) ->
      callback dt.point

  addArtist: (d, callback) ->
    data =
      'type': this.SORAN_TYPE_ARTIST
      'identifier': d.artist
    console.log 'Add artist, ', data
    mintpresso.set data, (dt) ->
      callback dt.point

  listen: (user, music, callback) ->
    data = {}
    data[user.type] = user.identifier
    data['verb'] = this.SORAN_VERB_LISTEN
    data[music.type] = music.identifier
    console.log 'listen, ', data
    mintpresso.set data, (d) ->
      callback if d.status.code is 201 or d.status.code is 200 then true else false

  sing: (artist, music, callback) ->
    data = {}
    data[artist.type] = artist.identifier
    data['verb'] = this.SORAN_VERB_SING
    data[music.type] = music.identifier
    mintpresso.get data, (d) ->
      unless d.edges isnt undefined and d.edges.length > 0
        mintpresso.set data, (d) ->
          callback if d.status.code is 201 or d.status.code is 200 then true else false
      else
        callback true

chrome.browserAction.onClicked.addListener (tab) ->
  if _soran.user.identifier.length is 0
    console.log "boo"
    d =
      tabId: tab.id
      popup: "popup.html"
    chrome.browserAction.setPopup d
  else 
    indexOfAt = _soran.user.identifier.lastIndexOf("@")
    name = _soran.user.identifier.substr 0, indexOfAt
    service = _soran.user.identifier.substr(indexOfAt + 1, _soran.user.identifier.length)
    d =
      url: "http://soran.admire.kr/#{ service }/@/#{ name }"
      left: 0
      top: 0
      focused: true
      type: "normal"
    chrome.windows.create d, (c) ->
      console.log c

#type ( optional enum of "normal", "popup", "panel", or "detached_panel" )

chrome.extension.onConnect.addListener (port) ->
  window["mintpresso"].init(mintpressoAPIKey, {withoutCallback: true})
  tab = port.sender.tab 
  console.log "added"
  port.onMessage.addListener (data) ->
    if data.kind isnt undefined
      if data.kind is _soran.EVENT_USER_INIT
        _soran.addUser data.identifier
      else if data.kind.length isnt 0 and _soran.user.identifier.length isnt 0
        switch data.kind
          when _soran.BUGS_PREFIX + _soran.ERROR
            console.error data
          when _soran.EVENT_LISTEN
            _soran.addMusic data.track, (music) ->
              _soran.addArtist data.track, (artist) ->
                _soran.sing artist, music, (success) ->
                  console.log success
              _soran.listen _soran.user, music, (success) ->
                console.log success
          else
            console.warn data
    else
      console.warn "data.kind is undefined.", data
