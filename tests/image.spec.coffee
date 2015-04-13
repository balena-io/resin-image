_ = require('lodash')
chai = require('chai')
expect = chai.expect
errors = require('resin-errors')
image = require('../lib/image')

describe 'Image:', ->

	describe '.write()', ->

		it 'should throw if no options', ->
			expect ->
				image.write(null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if options is not an object', ->
			expect ->
				image.write([], _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no options.device', ->
			expect ->
				image.write({ image: 'foo' }, _.noop)
			.to.throw(errors.ResinMissingOption)

		it 'should throw if options.device is not a string', ->
			expect ->
				image.write({ image: 'foo', device: [ 'bar' ] }, _.noop)
			.to.throw(errors.ResinInvalidOption)

		it 'should throw if no options.image', ->
			expect ->
				image.write({ device: 'bar' }, _.noop)
			.to.throw(errors.ResinMissingOption)

		it 'should throw if options.image is not a string', ->
			expect ->
				image.write({ image: [ 'foo' ], device: 'bar' }, _.noop)
			.to.throw(errors.ResinInvalidOption)

		it 'should throw if options.progress is defined but it not a function', ->
			expect ->
				image.write
					image: [ 'foo' ]
					device: 'bar'
					progress: [ _.noop ]
				, _.noop
			.to.throw(errors.ResinInvalidOption)

		it 'should throw if no callback', ->
			expect ->
				image.write({ image: 'foo', device: 'bar' }, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				image.write({ image: 'foo', device: 'bar' }, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)
