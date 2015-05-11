_ = require('lodash')
errors = require('resin-errors')
umount = require('umount')
utils = require('./utils')

###*
# @summary Write an image to a device
# @public
# @function
#
# @param {Object} options - options
# @param {Function} callback - callback
#
# @example
#	image.write {
#		device: '/dev/disk2'
#		image: 'path/to/image.img'
#		progress: (status) ->
#			console.log(status)
#	}, (error) ->
#		throw error if error?
###
exports.write = (options, callback) ->

	if not options?
		throw new errors.ResinMissingParameter('options')

	if not _.isPlainObject(options)
		throw new errors.ResinInvalidParameter('options', options, 'not an object')

	if not options.device?
		throw new errors.ResinMissingOption('device')

	if not _.isString(options.device)
		throw new errors.ResinInvalidOption('device', options.device, 'not a string')

	if not options.image?
		throw new errors.ResinMissingOption('image')

	if not _.isString(options.image)
		throw new errors.ResinInvalidOption('image', options.image, 'not a string')

	if options.progress? and not _.isFunction(options.progress)
		throw new errors.ResinInvalidOption('progress', options.progress, 'not a function')

	if not callback?
		throw new errors.ResinMissingParameter('callback')

	if not _.isFunction(callback)
		throw new errors.ResinInvalidParameter('callback', callback, 'not a function')

	umount.umount options.device, (error, stdout, stderr) ->
		return callback(error) if error?

		if not _.isEmpty(stderr)
			return callback(new Error(stderr))

		utils.writeWithProgress(options.image, options.device, options.progress, callback)
