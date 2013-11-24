import std.stdio;
import std.array:join;
import std.process;
import std.getopt;
import core.thread;

struct CmdOptions
{
	string stdoutFile;
	string stderrFile;
	int max=-1;

	public void Parse(ref string[] _args)
	{
		getopt(_args, 
			"log|l", &stdoutFile,
			"err|e", &stderrFile,
			"max|m", &max);
	}

	@property bool useStdOutFile() const { return stdoutFile.length > 0; }
	@property bool useStdErrFile() const { return stderrFile.length > 0; }
}

void main(string[] _args)
{
	writeln("--- Starting forever-d");

	if(_args.length < 2)
		return;

	CmdOptions options;
	options.Parse(_args);

	if(options.useStdOutFile)
		writefln("--- stdout file: %s", options.stdoutFile);
	if(options.useStdErrFile)
		writefln("--- stderr file: %s", options.stderrFile);
	if(options.max > 0)
		writefln("--- max runs: %s", options.max);

	auto cmdline = _args[1..$].join(" ");

	while(options.max == -1 || (options.max-- > 0))
	{
		writefln("--- Starting: '%s'", cmdline);

		auto pipes = pipeShell(cmdline, Redirect.stdout | Redirect.stderr);
		scope(exit) 
		{
			auto exitCode = wait(pipes.pid);
			writefln("\n--- Process Ended. Exitcode: %s", exitCode);
		}

		auto outThread = new Thread(()
		{
			File outStream = stdout;

			if(options.useStdOutFile)
				outStream = File(options.stdoutFile, "a");

			foreach (line; pipes.stdout.byLine)
			{
				if(options.useStdOutFile)
					outStream.writef("%s",line);
				else
					outStream.writefln("%s",line);
			}
		});

		auto errThread = new Thread(()
		{
			File outStream = stderr;

			if(options.useStdErrFile)
				outStream = File(options.stderrFile, "a");

			foreach (line; pipes.stderr.byLine)
			{
				if(options.useStdErrFile)
					outStream.writef("%s",line);
				else
					outStream.writefln("ERR: %s",line);
			}
		});

		outThread.start();
		errThread.start();
	}
}
