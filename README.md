resin-image
-----------

[![npm version](https://badge.fury.io/js/resin-image.svg)](http://badge.fury.io/js/resin-image)
[![dependencies](https://david-dm.org/resin-io/resin-image.png)](https://david-dm.org/resin-io/resin-image.png)
[![Build Status](https://travis-ci.org/resin-io/resin-image.svg?branch=master)](https://travis-ci.org/resin-io/resin-image)

Resin.io image utilities.

Installation
------------

Install `resin-image` by running:

```sh
$ npm install --save resin-image
```

Documentation
-------------

### image.write(Object options, Function callback)

Write an image to a device.

The callback gets passed a single argument: a possible error.

**Notice:** You might need admin privileges to run this operation or you might get an `EACCES` error.

Example:

```coffee
image = require('resin-image')

image.write {
	device: '/dev/disk2'
	image: 'path/to/image.img'
	progress: (state) ->
		console.log(state)
}, (error) ->
	throw error if error?
```

#### String options.device

The device to write the image to. For example `/dev/disk2` or `\\.\PhysicalDrive1`.

#### String options.image

The path to the *.img file.

#### Function options.progress(Object state)

An optional property that is called each 500ms with state information.

`state` is an object containing the following properties:

```javascript
{
	percentage: 9.05,
	transferred: 949624,
	length: 10485760,
	remaining: 9536136,
	eta: 42,
	runtime: 3,
	delta: 295396,
	speed: 949624
}
```

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/resin-io/resin-image/issues](https://github.com/resin-io/resin-image/issues)
- Source Code: [github.com/resin-io/resin-image](https://github.com/resin-io/resin-image)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

Support
-------

If you're having any problem, please [raise an issue](https://github.com/resin-io/resin-image/issues/new) on GitHub.

ChangeLog
---------

### v1.1.2

- Only unmount mounted devices.

### v1.1.1

- Fix improper unmounting of multiple partitions in GNU/Linux.

### v1.1.0

- Add device unmounting functionality.

License
-------

The project is licensed under the MIT license.
