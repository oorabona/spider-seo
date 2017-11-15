{sha256} = require '../spider-seo'

badValues = /gzip|deflate|compress|exi|identity|pack200-gzip|brotli|bzip2|lzma|peerdist|sdch|xpress|xz|ostr\.io|_passenger_route\=|heroku-session-affinity\=|__cfduid\=/i
badHeaders = /cache-control|server|date|cf-ray|x-cache-status|x-real-ip|x-powered-by|x-runtime|cf-connecting-ip|cf-ipcountry|x-preprender-status|x-prerender-status|cf-cache-status|etag|expires|last-modified|alt-svc|link|age|keep-alive|nncoection|pragma|connection|www-authenticate|via|set-cookie|vary|x-accel-expires|x-accel-redirect|x-accel-limit-rate|x-accel-buffering|x-cache-status|x-accel-charset/i

userAgentRegExps = [
  /360spider/i,
  /adsbot-google/i,
  /ahrefsbot/i,
  /applebot/i,
  /baiduspider/i,
  /bingbot/i,
  /duckduckbot/i,
  /facebookbot/i,
  /facebookexternalhit/i,
  /google-structured-data-testing-tool/i,
  /googlebot/i,
  /instagram/i,
  /kaz\.kz_bot/i,
  /linkedinbot/i,
  /mail\.ru_bot/i,
  /mediapartners-google/i,
  /mj12bot/i,
  /msnbot/i,
  /msrbot/i,
  /oovoo/i,
  /orangebot/i,
  /pinterest/i,
  /redditbot/i,
  /sitelockspider/i,
  /skypeuripreview/i,
  /slackbot/i,
  /sputnikbot/i,
  /tweetmemebot/i,
  /twitterbot/i,
  /viber/i,
  /vkshare/i,
  /whatsapp/i,
  /yahoo/i,
  /yandex/i
]

SEO = new Mongo.Collection 'seo'

SEO._ensureIndex {hash: 1, path: 1},
  unique: true,
  background: true

@_checkSnapshot = (hash) ->
  @unblock()
  page = SEO.findOne {hash: hash}
  'undefined' is typeof page || !page.readonly

@_submitSnapshot = (hash, path, html) ->
  @unblock()
  page = SEO.findOne {hash: hash}

  # Make sure pages with readonly flag set will not be updated.
  return true if 'undefined' isnt typeof page && page.readonly

  # Double check hash ...
  _hash = sha256.hmac path, html
  if _hash isnt hash
    throw new Meteor.Error 500, 'Spider-SEO: Hash mismatch!'

  id = SEO.upsert {path: path}, {$set: {hash: hash, html: html}}
  !!id

responseHandler = (res, result = {}) ->
  if result.status == null or result.status == 'null'
    result.status = 404
  result.status = if isNaN(result.status) then 200 else parseInt(result.status)
  if result.headers and result.headers.length > 0
    i = 0
    while i < result.headers.length
      if !badValues.test(result.headers[i].value) and !badHeaders.test(result.headers[i].name)
        try
          res.setHeader result.headers[i].name, result.headers[i].value
        catch e
          # Silence here...
      i++
  else
    res.setHeader 'Content-Type', 'text/html'
  res.writeHead result.status
  res.end '<!DOCTYPE html>' + result.html
  return

WebApp.connectHandlers.use (req, res, next) ->
  if (/\?.*_escaped_fragment_=/.test(req.url) or _.any(userAgentRegExps, ((re) ->
      re.test req.headers['user-agent']
    )))

    console.log 'req url', req.url
    path = req.url.split(/[?#]/)[0]
    cached = SEO.findOne path: path
    if cached
      responseHandler res, cached
      console.info 'Spider-SEO successfully completed [from cache] for url: ' + path
    else
      console.log 'Page not cached...', path
  next()
