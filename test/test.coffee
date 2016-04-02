# build time tests for slide plugin
# see http://mochajs.org/

slide = require '../client/slide'
expect = require 'expect.js'

describe 'slide plugin', ->

  describe 'expand', ->

    it 'can make itallic', ->
      result = slide.expand 'hello *world*'
      expect(result).to.be 'hello <i>world</i>'
