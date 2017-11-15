# Spider SEO package...
`import sha256 from 'js-sha256'`
exports.sha256 = sha256

exports.checkSnapshot = new ValidatedMethod {
  name: 'checkSnapshot'
  validate: null
  run: (hash) ->
    unless @isSimulation
      _checkSnapshot.call @, hash
}

exports.submitSnapshot = new ValidatedMethod {
  name: 'submitSnapshot'
  validate: null
  run: (args) ->
    {path, html, hash} = args
    unless @isSimulation
      _submitSnapshot.call @, hash, path, html
}

`export const name = 'spider-seo';`
