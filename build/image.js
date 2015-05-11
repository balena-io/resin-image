var async, errors, umount, utils, _;

async = require('async');

_ = require('lodash');

errors = require('resin-errors');

umount = require('umount');

utils = require('./utils');


/**
 * @summary Write an image to a device
 * @public
 * @function
 *
 * @param {Object} options - options
 * @param {Function} callback - callback
 *
 * @example
 *	image.write {
 *		device: '/dev/disk2'
 *		image: 'path/to/image.img'
 *		progress: (status) ->
 *			console.log(status)
 *	}, (error) ->
 *		throw error if error?
 */

exports.write = function(options, callback) {
  if (options == null) {
    throw new errors.ResinMissingParameter('options');
  }
  if (!_.isPlainObject(options)) {
    throw new errors.ResinInvalidParameter('options', options, 'not an object');
  }
  if (options.device == null) {
    throw new errors.ResinMissingOption('device');
  }
  if (!_.isString(options.device)) {
    throw new errors.ResinInvalidOption('device', options.device, 'not a string');
  }
  if (options.image == null) {
    throw new errors.ResinMissingOption('image');
  }
  if (!_.isString(options.image)) {
    throw new errors.ResinInvalidOption('image', options.image, 'not a string');
  }
  if ((options.progress != null) && !_.isFunction(options.progress)) {
    throw new errors.ResinInvalidOption('progress', options.progress, 'not a function');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return async.waterfall([
    function(callback) {
      return umount.isMounted(options.device, callback);
    }, function(isMounted, callback) {
      if (!isMounted) {
        return callback(null, null, null);
      }
      return umount.umount(options.device, callback);
    }, function(stdout, stderr, callback) {
      if (!_.isEmpty(stderr)) {
        return callback(new Error(stderr));
      }
      return utils.writeWithProgress(options.image, options.device, options.progress, callback);
    }
  ], callback);
};
