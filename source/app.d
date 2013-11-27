import std.stdio;
import std.array:join;
import std.process;
import std.getopt;
import std.conv:to;
import core.thread;

struct CmdOptions
{
	string stdoutFile;
	string stderrFile;
	string scriptOnRestart;
	int max=-1;

	public void Parse(ref string[] _args)
	{
		getopt(_args, 
			"log|l",	&stdoutFile,
			"err|e",	&stderrFile,
			"script",	&scriptOnRestart,
			"max|m",	&max);
	}

	public void print()
	{
		if(useStdOutFile)
			log("stdout file: %s", stdoutFile);
		if(useStdErrFile)
			log("stderr file: %s", stderrFile);
		if(scriptOnRestart.length > 0)
			log("restart script: %s", scriptOnRestart);
		if(max > 0)
			log("max runs: %s", max);
	}

	@property bool useStdOutFile() const { return stdoutFile.length > 0; }
	@property bool useStdErrFile() const { return stderrFile.length > 0; }
}

void log(T...)(string _format, T params)
{
	if(_format.length == 0)
	{
		writeln("");
	}
	else
	{
		import std.string;
		import std.datetime;

		writefln("-- %s -- " ~ _format, Clock.currTime, params);
	}
}

void main(string[] _args)
{
	log("Starting forever-d");

	if(_args.length < 2)
		return;

	CmdOptions options;
	options.Parse(_args);

	options.print();

	auto cmdline = _args[1..$].join(" ");

	string[string] envVars;
	int restartCount;

	envVars["FD_CMDLINE"] = cmdline;

	while(options.max == -1 || (options.max-- > 0))
	{
		log("Starting: '%s'", cmdline);

		auto pipes = pipeShell(cmdline, Redirect.stdout | Redirect.stderr);
		scope(exit) 
		{
			auto exitCode = wait(pipes.pid);
			log("");
			log("Process Ended. Exitcode: %s", exitCode);

			restartCount++;

			if(options.scriptOnRestart.length > 0)
			{
				envVars["FD_EXITCODE"] = to!string(exitCode);
				envVars["FD_RESTARTS"] = to!string(restartCount);

				spawnShell(options.scriptOnRestart, envVars);
			}
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
