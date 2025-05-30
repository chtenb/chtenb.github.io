LUSH
====
Lispy Unix SHell

Design in one sentence: type shell invocations with a UNIX-like syntax, but based on a lisp dialect that has programs and files as main language primitives.

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

We consider channels 1, 2 and 3 part of the normal program flow, and build our language around these.

**Main Concepts**

A *program* models a recipe for work being done on the computer.
A program has *parameters*, *standard I/O streams* and an *environment*.
The parameter arguments are explicitly given by caller of a program, whereas the I/O streams and environment variables are inherited implicitly.

A *command* is a program supplied with a list of arguments as the program's parameters.
An *invocation* is the execution instance of a command.
An invocation receives its environment variables as a copy of its parent's, possibly with invocation-specific modifications.
An invocation receives its standard file descriptors as a copy of its parent's, possibly with invocation-specific redirections.

The *variables* of an invocation are the environment variables inherited from the parent invocation.
The scope and variables together form the *environment* of the invocation.

The *scope* of an invocation (also called *dynamic scope*) is the set of available programs to be called and files to be accessed, mainly defined by the $PATH variable and the current working directory.
This definition does not include running a program or accessing a file explicitly via it's absolute path (which is considered a filesystem interaction, and thus a side effect).
Invocations inherit scopes automatically from the parent invocation, because $PATH is a variable and the CWD is inherited too.

The *exit code* of an invocation is a byte that indicates how the execution went.
A exit code of 0 signals an uneventful execution, while any other values have program specific meanings and usually indicate something went wrong.

An *operator* is any callable entity.
A *macro* is an operator that is not a program.

## Data
In Lush, data is represented by values. There are several kinds of values.

- A *string* is a sequence of bytes that contains utf-8 text. Syntax: `"Hello world"`.
- A *word* is a similar to a string, but has special evaluation rules. Syntax: `hello`.
- A *list* is a sequence of values. Syntax: `("hello world" hello (a b c))`.
- An *operator* is an opaque value that can be invoked with arguments.

Programs communicate data by default through stdin/stdout and arguments.
The args list is a list of the argument values supplied to the command.
The stdin is a readable stream of values, whereas the stdout is a writeable stream of values.
The stderr is normally used for communicating with the user, such a log messaging.
The exit code of a program is represented by an ascii string containing a decimal number.

## Evaluation
A *string* is a so-called constant, meaning that when it is evaluated, it returns itself.

When a *word* is evaluated, the following rules apply:

1. If it starts with a `$`, it is interpreted as a variable and is substituted by the value in that variable.
2. If it contains `*` characters, it is interpreted as a glob pattern and is evaluated to all the filenames matching the pattern.
3. Otherwise it evaluates to a string.

When a *list* `(x y z ...)` is evaluated, all the list elements are first scanned if there is a word matching a macro name.

1. For the first macro that is found, the macro is evaluated with two list arguments: the elements to the left and to the right of the macro.
2. If there are no macros present, the list is evaluated recursively from left to right.
3. Then, if the first element is a word that matches a program name, it is invoked with the remaining elemens as arguments, and the entire expression evaluates to the values in the stdout of the program.
4. Note that stdout can have multiple values, so a program evaluation can result in multiple values (and thus also result in multiple arguments when passed to another program).
5. If the first element is not a program, the expression evaluates to a list again, but with the elements evaluated.

When an *operator* is evaluated, an error is signaled, because operators can only be evaluated in the context of a list.

## Syntax
Commands are invoked like
```
(<program> [arg1 [arg2 ...]])
```
where `<program>` is either a program definition or a program name.

Programs are defined like
```
(program <args> <body>)
```

Programs are installed (named) into the current runtime scope and all child runtime scopes like
```
(install name <program>)
```

The body of a program consists of an optional number of installations followed by a command.
```sh
(program ()
  (install get-branches (program () (git branch --color=never | lines)))
  (join ", " (get-branches)))
```


Comments start with `#`.

At the top level, the outermost parameters are optional if the command is typed on one line.

## Builtin Macros
- `program`: Define a program.
- `install`: Make a program available under a given name.
- `out` / `err`: They both take any number of values as argument and write them to stdout and stderr respectively.
- `case`: takes one command to run and then two or more commands (continuations) to run for each possible exit code, starting with 0. The last command is the "else" case.
- `return`: exits the current command with the given code.
- `exit`: Only valid with a program definition. Exits the currently defined program with the given code.

### Command algebra
Commands can be composed to produce more complex commands.

**`&`**: If `A` and `B` are commands, then so is `A & B`. This command first runs A passing the stdin onto A and waits for completion. Both output streams of `A` are directed to the corresponding output streams of the compound program. Then `B` is invoked in the same manner as `A`. The exit code is that of B.

**`;`**: The same as `A & B` except `B` is only invoked when the exit code of `A` is 0.

**`?`**: The same as `A & B` except `B` is only invoked when the exit code of `A` is not 0.

**`|`**: If `A` and `B` are commands, then so is `A | B`. The command invokes both `A` and `B` (they are started in order, but will usually run concurrently). The stdin of the compound command is directed to A, the stdout of A is directed to the stdin of B. The stdout of B is directed to the stdout of the compound command. The stderr of both A and B are directed to the stderr of the compound command. The exit code is the first non-zero exit code of the chain.

The precedence of these operators are all the same. They are always evaluated from left to right. Parentheses can be used to change the order of evaluation.

```sh
(program (dir) (cd dir ; ls | grep README ? echo "No readme found"))
```

This program attempts to enter the given directory and search for a file with a name that contains "README" in it. If the directory does not exist, the program exits with the exit code of `cd`. If no readme has been found, the program writes a messages to stdout.


### I/O redirections
I/O redirections are postfix macros.

I/O can interact with files as follows.

```r
(<cmd> > file.txt)
(<cmd> >> file.txt)
(<cmd> err> file.txt)
(<cmd> err>> file.txt)
(<cmd> < file.txt)
(<cmd> ?> file.txt) # Writes the exit code to rc.txt
```

The same interactions are allowed with variables, which have to be prefixed with a `$` sign.

```r
(<cmd> > $myvar)
(<cmd> >> $myvar)
(<cmd> err> $myvar)
(<cmd> err>> $myvar)
(<cmd> < $myvar)
(<cmd> ?> $myvar)
```

Output streams allow the following mutual redirections.

```r
(<cmd> err>out) # Points fd (file descriptor) 2 to the same file description as fd 1.
(<cmd> err<>out) # Swaps file descriptions of fds 1 and 2.
(<cmd> err+>out) # Points fd 2 to a pipe that writes to fd 1 and the original file description of fd 2.
```

The default I/O directions are inherited from the parent program.
The root program will usually be the shell, which uses the currently connected tty for stdin/stdout/stderr, and writes the exit code to `$?`.

### Builtin Programs

## Private storage and lexical scoping
Values can be stored in files and variables.
Files can store more than one value and are global and globally mutable.
Variables are copied from the parent to a child invocation, and so child invocations cannot mutate variables of their parents, and vice versa, a parent can also not mutate variables of their children.

It is possible to write values into *private* files or variables.
Private files and variables are prefix with an underscore, like `_priv.txt` and `$_priv`, and behave just like their normal counterparts, except their names will be modified by the shell as to not collide with any files and variables outside the *lexical scope*.
Moreover, the files will not be placed in the CWD, but in a temporary location.

In the same vein, programs can be privately installed.
```sh
(install _hw (program () (out "Hello world)))
```
Now the program `_hw` is only available to be called from within the lexical scope where it was defined.

## Wire formats
Lush has two different notions of serializing values.
They can be serialized in human readable way, just like how you type commands, or in a binary way, which is easier and more efficient for external interaction.
The human readable format is called "lush", where as the binary format is called "blush".

### Blush specification
Values are delimited by NULL (00) bytes.
Strings are not quoted with `"`, but just serialized as their bare bytes.
Words are prefixed by SOH (01).
Lists are not delimited by parentheses, but instead by SO (0E) and SI (0F), and list elements are separated by US (1F).

This implies that strings are not allowed to contain bytes 0, 1, 14, 15 or 31.

## Example programs
```sh
# A program that writes hello world to stdout
program args (out "hello world")

# Makes alias of the `ls -al` command available in the current dynamic scope
install l (program args (ls -al (args | expand))) ;

# Install program hw into the current scope, and then call it from a python script
install hw ("hello world") ; python -c "import subprocess;subprocess.call('hw', shell=True)"

# Branch on whether a directory exists
case (test -d "foo") ("foo is a folder") ("foo is not a folder") ("something went wrong") ("this is unreachable, as test never returns a code higher than 2")

# Interactively checkout a git branch
install "g c" () (
  (git branch --color=never | lines | where (program (it) (starts-with "*" it))) > $_branches ;
  (out $_branches) ;
  (read-line "Type branch number to checkout and press enter to move on: " | trim) > $_input ;
  (case (test -n $_input)
    ((list $_branches) | index $_input | trim) > $_branch) ; git checkout $_branch)
    (out "Aborting..")
  )
)

install "git state" () (
  (cd (git rev-parse --show-toplevel)) ;
  (cond
    [(test -f .git/BISECT_LOG) (out BISECTING)]
    [(test -f .git/MERGE_HEAD) (out MERGING)]
    [(test -d .git/rebase-merge ? test -d .git/rebase-apply) (out REBASING)]
    [(test -f .git/CHERRY_PICK_HEAD) (out CHERRY-PICKING)]
    [(test -f .git/REVERT_HEAD (out REVERTING)]
    [else (out NORMAL) 
  )
)

install "g st" () (
  (git state) > $_state ;
  (if (substr "NORMAL" $_state)
    (out (fg magenta) $_state (ansi reset))) ;
  (list (git status -sb | lines)) > $_statuslines ;
  ($_statuslines | index 0) ;
  ($_statuslines
    | drop 1
    | sort (program (line)
      (switch (line | ansi strip | substr 0 2)
        ((= "??") 0)
        ((= "UU") 1)
        ((= "UD") 2)
        ((match " \S") 3)
        ((match "\S\S") 4)
        ((match "\S ") 5)
        (else 5)
      )
  )
)
```

<!--
### Datastructures
Lists also act as mappings by the following convention: a list entry that contains an `=` character can be treated as a key-value pair, whereby the string before the first `=` is treated as key.

### Questions
What is evaluation really?
And should constants indeed behave like programs when evaluated?
-->

