module app;

import std.stdio;

///
struct CmdOptions
{
	private string stdoutFile;
	private string stderrFile;
	private string scriptOnRestart;
	private int max = -1;
	private int minUptime = 1000;

	///
	public void parse(ref string[] _args)
	{
		import std.getopt : getopt;

		getopt(_args,
			"log|l",	&stdoutFile,
			"err|e",	&stderrFile,
			"script",	&scriptOnRestart,
			"min-uptime",	&minUptime,
			"max|m",	&max);
	}

	///
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

	///
	@property bool useStdOutFile() const { return stdoutFile.length > 0; }
	///
	@property bool useStdErrFile() const { return stderrFile.length > 0; }
}

private void log(T...)(string _format, T params)
{
	import std.stdio : writeln, writefln;

	if(_format.length == 0)
	{
		writeln("");
	}
	else
	{
		import std.datetime : Clock;

		writefln("-- %s -- " ~ _format, Clock.currTime, params);
	}
}

private enum helpMessage =
`forever-d [options] [program] <Arguments...>

options:
    -m -max     Max runs of [program]. default is 0 (unlimited)
    -l -log     File to print [program] std-out to. By default it's printed to stdout of forever-d
    -e -err     File to print [program] std-err to. By default it's printed to stdout of forever-d
    -script     Script run on process restart. Use [script-env] ENV variables in there.
    -min-uptime Minimum time in milliseconds program needs to run so it will restart again. (Defaults to 1000)

script-env:
    FD_EXITCODE     exit code of [program]
    FD_RESTARTS     number of restarts
    FD_CMDLINE      the actual cmd line used for [program]`;

///
void main(string[] _args)
{
	import std.process : spawnProcess, spawnShell, wait, Config;
	import core.thread : Thread;
	import std.array : join;
	import std.conv : to;
	import std.datetime : StopWatch;

	log("Starting forever-d");

	if(_args.length < 2 || _args[1] == "--help")
	{
		writeln(helpMessage);
		return;
	}

	CmdOptions options;
	options.parse(_args);

	options.print();

	auto cmdline = _args[1 .. $].join(" ");

	string[string] envVars;
	int restartCount;
	StopWatch uptime;
	bool canRestart = true;

	envVars["FD_CMDLINE"] = cmdline;

	File outStream = stdout;
	File errStream = stderr;

	if(options.useStdOutFile)
		outStream = File(options.stdoutFile, "a+");

	if(options.useStdErrFile)
		errStream = File(options.stderrFile, "a+");

	while((options.max == -1 || (options.max-- > 0)) && canRestart)
	{
		log("Starting: '%s'", cmdline);
		uptime.start();

		auto pid = spawnProcess(_args[1 .. $], std.stdio.stdin, outStream, errStream,
				null, Config.retainStdout);

		auto exitCode = wait(pid);
		uptime.stop();
		if(uptime.peek().msecs < options.minUptime)
			canRestart = false;
		uptime.reset();
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
}
