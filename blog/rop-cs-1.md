Railroad Oriented Programming in C#: Part 1
===========================================

The term _Railroad Oriented Programming_ has been [popularized by Scott Wlaschin as a term for a certain programming style for handling failure](https://fsharpforfunandprofit.com/rop/).
In this article series we will look at how we can implement this style of programming in C#.
Let's start by talking about the problems it is trying to solve.

## The problem: implicit function failure

Functions are often designed for the **success path**: the return type only consists of the type the function will return in case of a successful execution.
The following function definition likely wouldn't stand out in an average code base.

~~~~cs
User GetUser(string username);
~~~~

This function is supposed to return a User object for the user with the username that is passed into the function.
But sometimes the function isn't able to meet this expectation.

- maybe the user doesn't exist
- maybe because it needs to do a lookup in a datastore and the datastore is temporarily unreachable
- ...

~~~~pikchr
scale = 0.8
linewid = .5cm
lineht = .5cm
boxwid = 3.5cm

X0: oval "username" fit
arrow
X1: box "GetUser" fit
arrow 
X2: oval "User" fill lightblue fit
down
arrow dashed from X1.s down
X3: oval "?" fill crimson fit
~~~~

If a function fails, usually one of the following things happens.

1. A default value is returned, such as a null reference.

2. An exception is thrown.

3. A boolean or enum value is returned indicating success/failure cases while the actual result data is propagated through one or more [`out` parameters](https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/out-parameter-modifier).
    * A particular variant of this pattern that is regularly encountered in .NET libraries is referred to as the [Try-Parse Pattern in the Microsoft docs](https://docs.microsoft.com/en-us/dotnet/standard/design-guidelines/exceptions-and-performance#try-parse-pattern).


### Problems with using default values for failure
- For **value types** the default value is a valid member of the value space of the type. So either there would be no way to distinguish between a success return value and a failure return value, or if there are special values reserved for failure signaling (like `-1` is often used in the case of `int`) there is no compile-time guarantee that the failure case is handled distinctly.

- For **reference types** the default value (`null`) is not a valid member of the value space of a class in the sense that you can't call the class methods on it. The compiler however treats it as it _were_ a valid member, leading to null-reference bugs. Since the addition of nonnullable reference types in C# 8.0 this set of problems has been diminished a great deal, but a non-negligible pool of pitfalls remains.

- There is no way to return any data along with the failure, such as an error message or some object indicating the reason or nature of the failure.

- There is no way to distinguish between different kinds of failures.

### Problems with throwing exceptions for failure
[This short article about exceptions goes into the pitfalls of using exceptions.](/?page=exceptions-cs)

### The general problem of implicit failure paths
While the above paragraphs point out some problems with the respective failure-handling strategies, the main problem of these approaches is this: the **failure path** of `GetUser` is **implicitly defined**.
It is not part of the function signature, and the compiler is not aware of it.
As such, it doesn't get the same amount of attention from the programmer as the success path and is quite frankly too often completely overlooked.

### Problems with using booleans/enums with `out` parameters for failure
This approach is more explicit than the other two approaches. 
However, the compiler is still unable to verify if the checks are done properly, if all cases are covered and if the right `out` parameters are used in the right cases.
If you restrict yourself to the Try-Parse Pattern this becomes less of a problem, but that disables distinghuising between different kinds of failures or returning data along with failures.

## Solution: explicit failure paths through a `Result` type
The solution sounds pretty obvious: make the failure path part of the normal return type of the function.

~~~~pikchr
scale = 0.8
linewid = .5cm
lineht = .5cm
boxwid = 3.5cm

X0: oval "username" fit
arrow
X1: box "GetUser" fit

arrow from X1.ne right color lightblue
oval "Success" fit fill lightblue
arrow from X1.se right color orange
oval "Failure" fit fill orange
~~~~

~~~~cs
(Success<User> OR Failure<Error>) GetUser(string username);
~~~~

Since this idea sounds so trivial, why isn't this done traditionally?
At least part of that has to do with the fact C-like languages do not make it easy to do this.
You would need to have a return type that can be _either_ the success type _or_ the failure type.
In functional programming languages such a construct _does_ exist and is called a [Discriminated Union](https://en.wikipedia.org/wiki/Tagged_union).
But C-like languages, including C#, do not have support for such a type.
Luckily C# has had added lots of language features over the years that make it possible to emulate discriminated unions and use them in a relatively convenient and type-safe way.
In the [next part](/?page=rop-cs-2) of this series we will have a look at one way of implementing explicit failure in C#: a `Result` type with two subtypes, the `Success` type for the success path and the `Failure` type for the failure path.

### Default values or Try-Parse vs the `Failure` type
If performance is critical and you need to avoid as many allocations as possible, then using default values or the Try-Parse Pattern may be a good fit.
However, be aware of the pitfalls listed above.
If performance is not absolutely critical, neither of these solutions bear any advantages over a proper `Failure` type instance.
Moreover, using the `Result` type as your function return type makes the function calls composable, which makes your code more concise and type-safe, as we will see later on.

### Exception throwing vs the `Failure` type
When writing a function, a good way for deciding whether to propagate a failure by throwing an exception is by asking the following question.

_Should the failure always cause the entire transaction to be aborted in any reasonably conceivable context in which the function might be called?_

If the answer is yes, then it is probably appropriate to handle the failure by throwing an exception.
If the answer is no, then it is probably better to handle the failure by incorporating it in the function return type, such that the caller is forced to make an explicit decision about how to handle the failure path.
For a more elaborate discussion of when and how to use exceptions, again refer to [this short article about exceptions](/?page=exceptions-cs).

[In the next part of this series we will implement a `Result` type for C#. ➤](/?page=rop-cs-2)

