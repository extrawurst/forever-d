import std.stdio;
import std.process;

void main(string[] _args)
{
	if(_args.length < 2)
		return;

	while(true)
	{
		writefln("--- Starting: %s", _args[1..$]);

		auto pipes = pipeProcess(_args[1..$], Redirect.stdout);
		scope(exit) wait(pipes.pid);

		foreach (line; pipes.stdout.byLine)
			writefln("%s",line);
	}
}
