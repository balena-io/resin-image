_ = require('lodash')
fs = require('fs')
chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))
errors = require('resin-errors')
utils = require('../lib/utils')

describe 'Utils:', ->

	describe '.getFileSize()', ->

		it 'should throw if no file', ->
			expect ->
				utils.getFileSize(null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if file is not a string', ->
			expect ->
				utils.getFileSize(123, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				utils.getFileSize('file', null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				utils.getFileSize('file', [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		describe 'given the file exists', ->

			beforeEach ->
				@fsExistsStub = sinon.stub(fs, 'exists')
				@fsExistsStub.yields(true)

				@fsStatStub = sinon.stub(fs, 'stat')
				@fsStatStub.yields(null, size: 512)

			afterEach ->
				@fsExistsStub.restore()
				@fsStatStub.restore()

			it 'should return the size', (done) ->
				utils.getFileSize 'foo', (error, size) ->
					expect(error).to.not.exist
					expect(size).to.equal(512)
					done()

		describe 'given the file does not exist', ->

			beforeEach ->
				@fsExistsStub = sinon.stub(fs, 'exists')
				@fsExistsStub.yields(false)

			afterEach ->
				@fsExistsStub.restore()

			it 'should return an error', (done) ->
				utils.getFileSize 'foo', (error, size) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('File not found: foo.')
					expect(size).to.not.exist
					done()

	describe '.getProgressPipe()', ->

		it 'should throw if no size', ->
			expect ->
				utils.getProgressPipe(null, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if file is not a number', ->
			expect ->
				utils.getProgressPipe('hello', _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if file is not a positive number', ->
			expect ->
				utils.getProgressPipe(-512, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if onProgress is defined but is not a function', ->
			expect ->
				utils.getProgressPipe(123, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		it 'should not throw if onProgress is not defined', ->
			expect ->
				utils.getProgressPipe(123)
			.to.not.throw()

	describe '.writeWithProgress()', ->

		it 'should throw if no file', ->
			expect ->
				utils.writeWithProgress(null, 'output', _.noop, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if file is not a string', ->
			expect ->
				utils.writeWithProgress(123, 'output', _.noop, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no destination', ->
			expect ->
				utils.writeWithProgress('input', null, _.noop, _.noop)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if destination is not a string', ->
			expect ->
				utils.writeWithProgress('input', 123, _.noop, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if no callback', ->
			expect ->
				utils.writeWithProgress('input', 'output', _.noop, null)
			.to.throw(errors.ResinMissingParameter)

		it 'should throw if callback is not a function', ->
			expect ->
				utils.writeWithProgress('input', 'output', _.noop, [ _.noop ])
			.to.throw(errors.ResinInvalidParameter)

		it 'should throw if onProgress is defined but is not a function', ->
			expect ->
				utils.writeWithProgress('input', 'output', 123, _.noop)
			.to.throw(errors.ResinInvalidParameter)

		it 'should not throw if onProgress is not defined', ->
			expect ->
				utils.writeWithProgress('input', 'output', null, _.noop)
			.to.not.throw()

		describe 'given returned size is zero', ->

			beforeEach ->
				@utilsGetFileSizeStub = sinon.stub(utils, 'getFileSize')
				@utilsGetFileSizeStub.yields(null, 0)

			afterEach ->
				@utilsGetFileSizeStub.restore()

			it 'should return an error', (done) ->
				utils.writeWithProgress 'input', 'output', null, (error) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('Invalid file size: input. The file is 0 bytes.')
					done()
