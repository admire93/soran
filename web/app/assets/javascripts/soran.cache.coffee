Cache = () ->
  this.cached = {}
  true

Cache.prototype =
  isCacheEmpty: localStorage['soranCache'] is undefined or localStorage['soranCache'].length isnt 0
  get: (k) ->
    if this.cached.hasOwnProperty k
      this.cached[k]
    else if this.cached == {} and not this.isCacheEmpty
      this.cached = JSON.parse(localStorage['soranCache'])
      console.log 'here'
      this.get(k)
    else
      this.cached
  set: (k, v) ->
    if v.hasOwnProperty('updatedAt') and v.hasOwnProperty('data')
      this.cached[k] = v
      this.dump()
      this.cached[k]
    else
      throw '2nd param v MUST have `updatedAt` and `data` property'
      
  dump: () ->
    localStorage['soranCache'] = JSON.stringify(this.cached)

soran.extend
  cache: new Cache()
