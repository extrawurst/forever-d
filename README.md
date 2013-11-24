forever-d
=========

Ensures that a given program runs continuously.

This project is inspired by forever for nodejs: https://github.com/nodejitsu/forever

Current the usage is:
```
	$ forever-d [options] [program] <Arguments...>
	
	options:
		-m -max		Max runs of [program]. default is 0 (unlimited)
		-l -log		Logfile to print [program] stdout to. By default this is printed to stdout of forever-d
		-e -err		Logfile to print [program] stderr to. By default this is printed to stdout of forever-d
```

This project is written in the D programming language and supports the DUB package format.
