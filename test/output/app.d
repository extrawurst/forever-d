import core.thread;
import std.stdio;

void main()
{
	std.stdio.stdout.setvbuf(null, _IONBF);
	std.stdio.stderr.setvbuf(null, _IONBF);

	while (true)
	{
		writefln("Hello StdOut");
		std.stdio.stderr.writeln("Hello StdErr");

		Thread.sleep(300.msecs);
	}
}
