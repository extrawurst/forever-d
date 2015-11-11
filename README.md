forever-d [![Build Status](https://api.travis-ci.org/Extrawurst/forever-d.png)](https://travis-ci.org/Extrawurst/forever-d)
=========

Ensures that a given program runs continuously.

This project is inspired by forever for nodejs: https://github.com/nodejitsu/forever

Currently the usage is:
```
$ forever-d [options] [program] <Arguments...>

options:
	-m -max		Max runs of [program]. default is 0 (unlimited)
	-min-uptime 	Minimum time in milliseconds program needs to run so it will restart again. (Defaults to 1000)
	-l -log		File to print [program] std-out to. By default it's printed to stdout of forever-d
	-e -err		File to print [program] std-err to. By default it's printed to stdout of forever-d
	-script		Script run on process restart. Use [script-env] ENV variables in there.

script-env:
	FD_EXITCODE		exit code of [program]
	FD_RESTARTS		number of restarts
	FD_CMDLINE		the actual cmd line used for [program]
```

This project is written in the D programming language and supports the DUB package format.
