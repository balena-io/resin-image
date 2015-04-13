_ = require('lodash')
fs = require('fs')
diskio = require('diskio')
errors = require('resin-errors')
progressStream = require('progress-stream')

###*
# @summary Get the size of a file
# @protected
# @function
#
# @param {String} file - path to file
# @param {Function} callback - callback
#
# @example
#	utils.getFileSize 'path/to/file', (error, size) ->
#		throw error if error?
#		console.log(size)
###
exports.getFileSize = (file, callback) ->

	if not file?
		throw new errors.ResinMissingParameter('file')

	if not _.isString(file)
		throw new errors.ResinInvalidParameter('file', file, 'not a string')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	fs.exists file, (exists) ->

		if not exists
			return callback(new Error("File not found: #{file}."))

		fs.stat file, (error, stats) ->
			return callback(error) if error?
			return callback(null, stats.size)

###*
# @summary Get a progress stream for writing a file
# @protected
# @function
#
# @param {Number} size - file size
# @param [Function] onProgress - on progress callback
# @returns {Stream} the progress stream
#
# @example
# progress = utils.getProgressPipe(512, (state) -> console.log(state))
###
exports.getProgressPipe = (size, onProgress) ->

	if not size?
		throw new errors.ResinMissingParameter('size')

	if not _.isNumber(size)
		throw new errors.ResinInvalidParameter('size', size, 'not a number')

	if size < 0
		throw new errors.ResinInvalidParameter('size', size, 'not a positive number')

	if onProgress? and not _.isFunction(onProgress)
		throw new errors.ResinInvalidParameter('onProgress', onProgress, 'not a function')

	progress = progressStream
		length: size
		time: 500

	if onProgress?
		progress.on('progress', onProgress)

	return progress

###*
# @summary Write a file to a device with progress
# @protected
# @function
#
# @param {String} file - path to file
# @param {String} destination - path to device
# @param [Function] onProgress - on progress callback
# @param {Function} callback - callback
#
# @example
# utils.writeWithProgress 'myfile', '/dev/disk2', (state) ->
#		console.log(state)
#	, (error) ->
#		throw error if error?
###
exports.writeWithProgress = (file, destination, onProgress, callback) ->

	if not destination?
		throw new errors.ResinMissingParameter('destination')

	if not _.isString(destination)
		throw new errors.ResinInvalidParameter('destination', destination, 'not a string')

	if onProgress? and not _.isFunction(onProgress)
		throw new errors.ResinInvalidParameter('onProgress', onProgress, 'not a function')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	exports.getFileSize file, (error, size) ->
		return callback(error) if error?

		if size is 0
			error = new Error("Invalid file size: #{file}. The file is 0 bytes.")
			return callback(error)

		progress = exports.getProgressPipe(size, onProgress)
		stream = fs.createReadStream(file).pipe(progress)
		diskio.writeStream(destination, stream, callback)
