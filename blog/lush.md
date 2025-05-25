LUSH
====
Lispy Unix SHell

Design in one sentence: type CLI pipelines with POSIX syntax, but any higher order pipeline logic is done using s-expressions.
Interactive features are configured with lisp code.

## Program model

**Primary Ways a Program Receives Input**

1. Command-line arguments (argv)
	- Passed at exec time by the parent process.
2. Environment variables (envp)
	- Also passed at exec time.
3. Initial file descriptors
	- Includes standard FDs: stdin (0), stdout (1), stderr (2)
	- May include additional FDs from parent (e.g., pipes, sockets, inherited resources)
4. Current working dir
5. Filesystem (readable or discoverable)
	- Can read config files, device files, /proc, etc.
	- Includes memory-mapped files, shm_open, etc.
	- Requires knowing where to look (e.g., $HOME/.config/foo, /etc/foo.conf)
6. Signals (asynchronous control flow)
	- Delivered at any time during execution.
	- Can only carry limited information (signal number, sometimes a bit more via siginfo_t)

We consider channels 4, 5 and 6 side effects, to be used only if they are required to complete a programs objective.
Side effects should be documented properly when sharing programs with others.

We consider channels 1, 2 and 3 part of the normal program flow, and built our language around these.

**Main Concepts**

A *program* models a recipe for work being done on the computer.
A program has *parameters*, *I/O streams* and an *environment*.
The parameters are explicitly specified by caller of a program, whereas the I/O streams and environment variables are inherited implicitly.

A *command* is a program supplied with a list of arguments as the program's parameters.
An *invocation* is the execution instance of a command.
An invocation receives its environment variables as a copy of its parent's, possibly with invocation-specific modifications.
An invocation receives its standard file descriptors as a copy of its parent's, possibly with invocation-specific redirections.

The *scope* of an invocation is of the set of available programs to be called.
This does not include running a program explicitly via it's absolute path (which is considered a filesystem interaction, and thus a side effect).
Invocations inherit scopes automatically from the parent invocation, in the same manner as the environment .

The *variables* of an invocation is the list of environment variables inherited from the parent invocation.
The scope and variables together form the *environment* of the invocation.

The *return code* of an invocation is a byte that indicates how the execution went.
A return code of 0 signals an uneventful execution, while any other values have program specific meanings and usually indicate something went wrong.

A *macro* is a callable entity that is not a program.

## Data

There are two types of data values: lists and constants, each defined as usual in Lisp languages.
The only supported constant is currently the string. A constant is conceptually the same as a program that takes no arguments and writes that value to stdout. 

Programs communicate data by default through stdin/stdout and arguments.
The args list is a list of the argument values supplied to the command.
The stdin is a readable stream of values, whereas the stdout is a writeable stream of values.
The stderr is normally used for communicating with the user, such a log messaging.

## Syntax

Programs are defined like
```r
(program args <command>)
```

Programs are installed (named) into the current scope like
```r
(install name <program>)
```

Commands are invoked like
```r
(<program> [arg1 [arg2 ...]])
```

Comments start with `#`.

At the top level, the outermost parameters are optional if the command is typed on one line.

## Builtin Macros

There are two macros to write data: `out` and `err`. They both take any number of values as argument and write them to stdout and stderr respectively.

## Evaluation

An expression of the form `(x y z ...)` is evaluated.

- When the first term is a program, the evaluation results in an invocation where the program `x` is called with the arguments `y`, `z`, etc.
The arguments are first evaluated from left to right, and their stdout is captured and used as argument values.
Since stdout is a stream of values, this can result in more than one argument being passed per evaluation.

- When the first term is a macro, it follows macro-specific rules for evaluation.

- When an expression is a constant, it evaluates to itself. This evaluates in the same manner as invoking a parameterless program writing that value to stdout.

## Example programs

```r
program args (out "hello world") # A program that writes hello world to stdout
"hello world" # Also a program that writes hello world to stdout
install l (program args (ls -al (args | expand))) # Makes alias of the `ls -al` command available in the current scope
```

## Command algebra
Commands can be composed to produce more complex commands.

**`&`**: If `A` and `B` are commands, then so is `A & B`. This command first runs A passing the stdin onto A and waits for completion. Both output streams of `A` are directed to the corresponding output streams of the compound program. Then `B` is invoked in the same manner as `A`. The return code is that of B.

**`;`**: The same as `A & B` except `B` is only invoked when the return code of `A` is 0.

**`?`**: The same as `A & B` except `B` is only invoked when the return code of `A` is not 0.

**`|`**: If `A` and `B` are commands, then so is `A | B`. The command invokes both `A` and `B` (they are started in order, but will usually run concurrently). The stdin of the compound command is directed to A, the stdout of A is directed to the stdin of B. The stdout of B is directed to the stdout of the compound command. The stderr of both A and B are directed to the stderr of the compound command. The return code is the first non-zero return code of the chain.

The precedence of these operators is `&` > `?` > `|`  > `;`.

```r
(program (dir) (cd dir ; (ls | grep README) ? echo "No readme found"))
```

This program attempts to enter the given directory and search for a file with a name that contains "README" in it. If the directory does not exist, the program exits with the return code of `cd`. If no readme has been found, the program writes a messages to stdout.


## I/O redirections
Standard redirections are postfix macros:

```sh
(<cmd> > file.txt)
(<cmd> >> file.txt)
(<cmd> err> file.txt)
(<cmd> err>> file.txt)
(<cmd> < file.txt)
(<cmd> err>out) # points fd (file descriptor) 2 to the same file description as fd 1.
(<cmd> err<>out) # swaps file descriptions of fds 1 and 2.
(<cmd> err+>out) # points fd 2 to a pipe that writes to fd 1 and the original file description of fd 2.
```

<!--

### Output capture
There are three ways to capture output as a byte sequence and rebind this an argument to another program.

*`(cmd)`*: Evaluates cmd, sends stderr to parent, and captures stdout. If return code is nonzero, evaluation of parent is aborted.
*`?(cmd)`*: Evaluates cmd and captures return code as bytestring of length 1. Stdout and stderr are sent to parent.
*`$(cmd)`*: Evaluates cmd and captures triple (stdout stderr returncode).

The program `rc` takes one byte n as parameter and exits with return code n upon invocation.
The program `echo` takes a bytestring as argument and writes this to stdout.

```py
(program n) ≡ (program ?(rc n))
(program b) ≡ (program (echo b))
```

## Wire format
A *byte* is a number between 0 and 255 (inclusive).
A *value* is a sequence of bytes that does not contain the byte 0.
A *bytestream* is a sequence of bytes (including 0-bytes) which can only be traversed once, and only in a sequential manner.


### List encoding
Lists are supported by Lush.
It also acts as a mapping by the following convention: a list entry that contains an `=` character can be treated as a key-value pair, whereby the bytestring before the first `=` is treated as key.
Lists are represented in memory by a series of bytestrings, separated by a US (Unit Separator/31/1F) byte.
Lists can be nested, where byte SI (Shift In/14/E) opens a nested list, and byte SO (Shift Out/15/F) closes it.

-->

