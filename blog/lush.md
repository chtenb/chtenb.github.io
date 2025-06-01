LUSH
====
Lispy Unix SHell

Design in one sentence: type shell invocations with a UNIX-like syntax, but based on a lisp dialect that has programs and files as main language primitives.

Lush is not intended as general purpose programming language.
It's a shell language to link programs together.

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
A program has *parameters* in the form of program *arguments* or environment *variables*.
Program I/O is done through standard I/O streams, stdin/stdout/stderr.

An *operator* is any callable entity.
A *macro* is similar to a program, but follows different evaluation rules.
A *special operator* is any callable entity that is not a program or a macro.

A *command* is an operator supplied with arguments.
An *invocation* is the execution instance of a command, corresponding to a process.
An invocation receives its environment variables as a copy of its parent's, possibly with invocation-specific modifications.
An invocation receives its standard file descriptors as a copy of its parent's, possibly with invocation-specific redirections.

A common pattern programs employ is to expose parameters as both arguments and variables, where arguments override variables.
Since variables are passed implicitly to child invocations, this allows controlling the behavior of programs across multiple program boundaries, which is useful for controlling default behavior even when you don't directly call a program yourself and thus have no control over the arguments being passed.

The *scope* of an invocation (also called *dynamic scope*) is the set of available programs to be called and files to be accessed, mainly defined by the $PATH variable and the current working directory (CWD).
This definition does not include running a program or accessing a file explicitly via it's absolute path (which is considered a filesystem interaction, and thus a side effect).
Invocations inherit scopes automatically from the parent invocation, because $PATH is a variable and the CWD is inherited too.

The *exit code* of an invocation is a number that indicates how the execution went.
A exit code of 0 signals an uneventful execution, while any other values have operator specific meanings and usually indicate something went wrong.


## Data
In Lush, data is represented by values. There are several kinds of values.

- A *string* is a sequence of bytes that contains utf-8 text. Syntax: `"Hello world"`.
- A *word* is a similar to a string, but has special evaluation rules. Syntax: `hello`.
- A *list* is a sequence of values. Syntax: `("hello world" hello (a b c))`.
- An *operator* is an opaque value that can be invoked with arguments.

Programs communicate data by through stdin and stdout.
Although arguments and variables are also capable of communicating data, they have OS-dependent restrictions in size.
The stdin is a readable stream of values, whereas the stdout is a writeable stream of values.
The stderr is normally used for communicating with the user, such a log messaging, but is in fact just a stream of values, similar to stdout.
The exit code of a program is represented by a string containing a decimal number.

## Evaluation
A *string* is a so-called constant, meaning that when it is evaluated, it returns itself.

When a *word* is evaluated, the following rules apply:

1. If the name starts with a `@` it is interpreted as an argument of the currently defined program, and it is substituted with the argument value.
2. If it starts with a `$`, it is interpreted as a variable and is substituted by the value in that variable.
3. If it starts with a `_`, it is substituted with the name of a private file. See below.
4. If it contains `*` characters, it is interpreted as a glob pattern and is evaluated to all the filenames matching the pattern.
5. Otherwise it evaluates to a string.

When a *list* `(x y z ...)` is evaluated, all the list elements are first scanned if there is a word matching a macro name.

1. For the first macro that is found, the macro is evaluated with two list arguments: the elements to the left and to the right of the macro.
2. If there are no macros present, the list is evaluated recursively from left to right.
3. Then, if the first element is a program or a string that matches a program name, it is invoked with the remaining elements as arguments, and the entire expression evaluates to the values in the stdout of the program.
4. Note that stdout can have multiple values, so a program evaluation can result in multiple values (and thus also result in multiple arguments when passed to another program).
5. If the first element is not a program, the expression evaluates to a list again, but with the elements evaluated.

When an *operator* is evaluated, an error is signaled, because operators can only be evaluated in the context of a list.

## Syntax
Commands are invoked like
```
(<program> [arg1 [arg2 ...]])
```
where `<program>` is either a program definition or a program name.
Arguments can be variables or again a command invocation.
When an argument is a command invocation, the stdout is used as arguments.

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

### Command algebra
Commands can be composed to produce more complex commands using a set of macros called command *combinators*.

**`&`**: If `A` and `B` are commands, then so is `A & B`. This command first runs A passing the stdin onto A and waits for completion. Both output streams of `A` are directed to the corresponding output streams of the compound program. Then `B` is invoked in the same manner as `A`. The exit code is that of B.

**`;`**: The same as `A & B` except `B` is only invoked when the exit code of `A` is 0.

**`?`**: The same as `A & B` except `B` is only invoked when the exit code of `A` is not 0.

**`|`**: If `A` and `B` are commands, then so is `A | B`. The command invokes both `A` and `B` (they are started in order, but will usually run concurrently). The stdin of the compound command is directed to A, the stdout of A is directed to the stdin of B. The stdout of B is directed to the stdout of the compound command. The stderr of both A and B are directed to the stderr of the compound command. The exit code is the first non-zero exit code of the chain.

The precedence of these operators are all the same.
They are always evaluated from left to right (i.e. left-associative: `(A ; B) ; C ≡ A ; B ; C`).
Parentheses can be used to change the order of evaluation.
Parentheses are optional for grouping commands between combinators.
So `A ; B x y ; C ≡ A ; (B x y) ; C`.


```sh
(program (dir) (cd dir ; ls | grep README ? error "No readme found"))
```

This program attempts to enter the given directory and search for a file with a name that contains "README" in it. If the directory does not exist, the program exits with the exit code of `cd`. If no readme has been found, the program writes a messages to stdout.


### I/O redirections
I/O redirections are specified with macros called command *decorators*.

I/O can interact with files as follows.

```r
(<cmd> > file.txt)
(<cmd> >> file.txt)
(<cmd> err> file.txt)
(<cmd> err>> file.txt)
(<cmd> < file.txt)
(<cmd> ?> file.txt) # Writes the exit code to rc.txt
```

<!-- The same interactions are allowed with variables, which have to be prefixed with a `$` sign. -->
<!-- Variables can contain more than one value. -->

<!-- ```r -->
<!-- (<cmd> > $myvar) -->
<!-- (<cmd> >> $myvar) -->
<!-- (<cmd> err> $myvar) -->
<!-- (<cmd> err>> $myvar) -->
<!-- (<cmd> < $myvar) -->
<!-- (<cmd> ?> $myvar) -->
<!-- ``` -->

Output streams allow the following mutual redirections.

```r
(<cmd> err>out) # Points fd (file descriptor) 2 to the same file description as fd 1.
(<cmd> out><err) # Swaps file descriptions of fds 1 and 2.
(<cmd> err+>out) # Points fd 2 to a pipe that writes to fd 1 and the original file description of fd 2.
```

The default I/O directions are inherited from the parent program.
The root program will usually be the shell, which uses the currently connected tty for stdin/stdout/stderr, and writes the exit code to `$?`.

All these redirection operators have the same precedence as the command combinators, and are evaluated from left to right.

## Private files and programs and lexical scoping
Files can store more than one value and are global and globally mutable.
It is possible to write values into *private* files.
Private files can be written as a word that is prefixed with an underscore, like `_priv.txt`, and behave just as a normal filename, except their names will be modified by the shell as to not collide with any files outside the *lexical scope*.
Moreover, the files will not point into the CWD, but in a temporary location, possibly in memory instead of on disk.

In the same vein, programs can be privately installed.
```sh
(install _hw (program () (echo "Hello world)))
```
Now the program `_hw` is only available to be called from within the lexical scope where it was defined.

## Wire formats
Lush has two different notions of serializing values.
They can be serialized in human readable way, just like how you type commands, or in a binary way, which is easier and more efficient for external interaction.
The human readable format is called "lush", where as the binary format is called "blush".

Every I/O boundary is crossed by reading and writing all the values in blush.
The interpreter may optimize this away when possible.

### Blush specification
Values are delimited by NULL (00) or US (1F) bytes.
Strings are not quoted with `"`, but just serialized as their bare bytes.
Words are prefixed by SOH (01).
Lists are not delimited by parentheses, but instead by SO (0E) and SI (0F), and list elements are again separated by US (1F) or NULL (00).

This implies that strings are not allowed to contain bytes 0, 1, 14, 15 or 31.

## Special operators
Special operators work within the context of a program. They have no variables or I/O streams of their own.
They do have an exit code though, and as such can be used with command combinators (except the pipe operator).

- `install`: Make a program available under a given name in the current dynamic scope.
- `exit`: Only valid within a program definition. Exits the currently defined program with the given code.
- `set`: set a variable: `(set PATH (append $PATH ";/foo/bar"))`.

## Builtin Macros
- `program`: Define a program and write it to stdout.
- `with`: invoke a command with a set of variable assignments.
- `case`: takes one command to run and then one or more commands (continuations) to run for each possible exit code, starting with 0.
  The first continuation is run when the run command has exit code 0. Subsequent non-last continuations are run for exit codes 1, 2, etc. The last continuation is run if no other continuations have been run.
- `cond`: if/elseif/else
- `switch`: a value and a list of predicates with associated outcome values.


## Builtin Programs
- All system programs, like unix utilities
- `echo` / `error`: They both take any number of values as argument and write them to stdout and stderr respectively.
- `read-line`: read a line from stdin.
- `tmp : <filename> `: return a filename for a temporary file
- `each (p : value -> <modified value>) : values -> <modified values>`: run program `p` for each given value, and output the resulting values.
- `fold init (p acc : value -> <acc with p>) : values -> <aggregation>`: aggregated values by applying program `p` to each value and the accumulated aggregation so far. `init` is the initial aggregation.
- `(= <value> <value>)`: checks if two values are equal
- `(= <value>)`: partially applied version of above


## Example commands
```sh
# A program that ignores arguments writes hello world to stdout
program args (echo "hello world") ;

# Makes alias of the `ls -al` command available in the current dynamic scope
install l (program args (ls -al (@args | expand))) ;

# Install program hw into the current scope, and then call it from a python script
install hw ("hello world") ; python -c "import subprocess;subprocess.call('hw', shell=True)" ;

# Branch on whether a directory exists
case (test -d "foo") ("foo is a folder") ("foo is not a folder") ("something went wrong") ("this is unreachable, as test never returns a code higher than 2") ;

# Interactively checkout a git branch
install "g c" () (
  (git branch --color=never | lines | where (program (it) (starts-with "*" @it))) > _branches ;
  (cat _branches) ;
  (read-line "Type branch number to checkout and press enter to move on: " | trim) > _input ;
  (case (test -n (cat _input))
    ((list < _branches) | index (cat _input) | trim) > _branch) ; git checkout (cat _branch))
    (echo "Aborting..")
  )
) ;

# Modified version of git status
install "git state" () (
  (cd (git rev-parse --show-toplevel)) ;
  (cond
    [(test -f .git/BISECT_LOG) (echo BISECTING)]
    [(test -f .git/MERGE_HEAD) (echo MERGING)]
    [(test -d .git/rebase-merge ? test -d .git/rebase-apply) (echo REBASING)]
    [(test -f .git/CHERRY_PICK_HEAD) (echo CHERRY-PICKING)]
    [(test -f .git/REVERT_HEAD (echo REVERTING)]
    [else (echo NORMAL) 
  )
) ;

install "g st" () (
  (git state) > _state ;
  (if (substr "NORMAL" < _state)
    (color (fg magenta) _state) ;
  (git status -sb | lines | list > _statuslines) ;
  (index 0 < _statuslines) ;
  (cat _statuslines
    | drop 1
    | sort (program (line)
      (@line | ansi strip | substr 0 2 | switch
        ((= "??") 0)
        ((= "UU") 1)
        ((= "UD") 2)
        ((match " \S") 3)
        ((match "\S\S") 4)
        ((match "\S ") 5)
        (else 6)
      )
  )
)
```

<!--
### Datastructures
Lists also act as mappings by the following convention: a list entry that contains an `=` character can be treated as a key-value pair, whereby the string before the first `=` is treated as key.

### Questions
- Can we generalize over environment variables to be keys in an environment listmap?
-->

