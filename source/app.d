import std.stdio;
import std.array:join;
import std.process;
import core.thread;

void main(string[] _args)
{
	writeln("--- Starting forever-d");

	if(_args.length < 2)
		return;

	auto cmdline = _args[1..$].join(" ");

	while(true)
	{
		writefln("--- Starting: '%s'", cmdline);
		scope(exit) writefln("--- Process Ended");

		auto pipes = pipeProcess(_args[1..$], Redirect.stdout | Redirect.stderr);
		scope(exit) wait(pipes.pid);

		auto outThread = new Thread(()
		{
			foreach (line; pipes.stdout.byLine)
			{
				writefln("%s",line);
			}
		});

		auto errThread = new Thread(()
		{
			foreach (line; pipes.stderr.byLine)
			{
				writefln("ERR: %s",line);
			}
		});

		outThread.start();
		errThread.start();
	}
}
