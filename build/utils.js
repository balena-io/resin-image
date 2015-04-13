var diskio, errors, fs, progressStream, _;

_ = require('lodash');

fs = require('fs');

diskio = require('diskio');

errors = require('resin-errors');

progressStream = require('progress-stream');


/**
 * @summary Get the size of a file
 * @protected
 * @function
 *
 * @param {String} file - path to file
 * @param {Function} callback - callback
 *
 * @example
 *	utils.getFileSize 'path/to/file', (error, size) ->
 *		throw error if error?
 *		console.log(size)
 */

exports.getFileSize = function(file, callback) {
  if (file == null) {
    throw new errors.ResinMissingParameter('file');
  }
  if (!_.isString(file)) {
    throw new errors.ResinInvalidParameter('file', file, 'not a string');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return fs.exists(file, function(exists) {
    if (!exists) {
      return callback(new Error("File not found: " + file + "."));
    }
    return fs.stat(file, function(error, stats) {
      if (error != null) {
        return callback(error);
      }
      return callback(null, stats.size);
    });
  });
};


/**
 * @summary Get a progress stream for writing a file
 * @protected
 * @function
 *
 * @param {Number} size - file size
 * @param [Function] onProgress - on progress callback
 * @returns {Stream} the progress stream
 *
 * @example
 * progress = utils.getProgressPipe(512, (state) -> console.log(state))
 */

exports.getProgressPipe = function(size, onProgress) {
  var progress;
  if (size == null) {
    throw new errors.ResinMissingParameter('size');
  }
  if (!_.isNumber(size)) {
    throw new errors.ResinInvalidParameter('size', size, 'not a number');
  }
  if (size < 0) {
    throw new errors.ResinInvalidParameter('size', size, 'not a positive number');
  }
  if ((onProgress != null) && !_.isFunction(onProgress)) {
    throw new errors.ResinInvalidParameter('onProgress', onProgress, 'not a function');
  }
  progress = progressStream({
    length: size,
    time: 500
  });
  if (onProgress != null) {
    progress.on('progress', onProgress);
  }
  return progress;
};


/**
 * @summary Write a file to a device with progress
 * @protected
 * @function
 *
 * @param {String} file - path to file
 * @param {String} destination - path to device
 * @param [Function] onProgress - on progress callback
 * @param {Function} callback - callback
 *
 * @example
 * utils.writeWithProgress 'myfile', '/dev/disk2', (state) ->
 *		console.log(state)
 *	, (error) ->
 *		throw error if error?
 */

exports.writeWithProgress = function(file, destination, onProgress, callback) {
  if (destination == null) {
    throw new errors.ResinMissingParameter('destination');
  }
  if (!_.isString(destination)) {
    throw new errors.ResinInvalidParameter('destination', destination, 'not a string');
  }
  if ((onProgress != null) && !_.isFunction(onProgress)) {
    throw new errors.ResinInvalidParameter('onProgress', onProgress, 'not a function');
  }
  if (callback == null) {
    throw new errors.ResinMissingParameter('callback');
  }
  if (!_.isFunction(callback)) {
    throw new errors.ResinInvalidParameter('callback', callback, 'not a function');
  }
  return exports.getFileSize(file, function(error, size) {
    var progress, stream;
    if (error != null) {
      return callback(error);
    }
    if (size === 0) {
      error = new Error("Invalid file size: " + file + ". The file is 0 bytes.");
      return callback(error);
    }
    progress = exports.getProgressPipe(size, onProgress);
    stream = fs.createReadStream(file).pipe(progress);
    return diskio.writeStream(destination, stream, callback);
  });
};
