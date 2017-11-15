{sha256, checkSnapshot, submitSnapshot} = require '../spider-seo'

exports.snapshotPage = (path) ->
  html = document.documentElement.innerHTML
  # Compute SHA256 from html
  hash = sha256.hmac path, html
  checkSnapshot.call hash, (err,res) ->
    if err
      console.error 'Spider-SEO returned error:', err
    else
      if res
        snapshot = hash: hash, path: path, html: html
        submitSnapshot.call snapshot, (err,res) ->
          if err
            console.error 'Spider-SEO returned error:', err
