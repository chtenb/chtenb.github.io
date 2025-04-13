% On Exception Throwing and Catching in OO

Exceptions are a well-established feature of almost every Object Oriented programming language these days.
However, exceptions are tricky.
Let's discuss the tricky parts and how we can use exceptions to their strength.

## Problems with throwing exceptions

- Exceptions are not part of the function signature. As such a caller of a function does not know which exceptions to catch unless he reads all the code that is possibly hit by the function, assuming that he even has access to it.

- In well-defined and well-maintained APIs the list of possible exceptions a function can throw is stated in the documentation. But the compiler is not aware of this. So:

  * The user of the API can easily overlook exceptions and get away without compiler warnings.

  * If the API changes over time and adds more exceptions, the user will not be notified of this by the compiler.

  * Most functions are not part of a well-defined API. And even seemingly well-defined/documented APIs are not always documented exhaustively, especially as they change over time.

- Throwing is slow and using throw/catch for control flow just kills performance.

- When using a debugger, the debugger halts on most exceptions. Specifying which exceptions to halt on is a lot of work if you throw a lot of exceptions for control flow, instead of just for things that are really exceptional.

- Frequent try-catch blocks are verbose, make the actual intention of the code much less clear and which eventually leads to making mistakes.


There are often other ways to handle failure, like having functions return an error value.
A robust approach to this is discussed in [this article about Railroad Oriented Programming](/?page=rop-cs-1).

## Exceptions are a part of life
Making a failure path part of the function return type is neat, but it does not mean that there are no exceptional situations for which the exception throwing mechanism is actually a very good fit.
To give an extreme example, almost any function can _in theory_ encounter an `OutOfMemoryException` while doing an allocation.
Or any function could _in theory_ trigger a bug somewhere causing a `NullReferenceException` to be thrown.
Exceptions are a fact of life, and we should be prepared to deal with them.
It would make no sense to have the returntype of each function indicate that it could return with a null reference failure in the way we suggested above.
These cases are really exceptions which are *unexpected*.
There is often no proper way to handle them other than to cancel the whole "operation", log the error and present the user with an appropriate error, indicating that something went completely sideways.
So how should we deal with that in our code?

In a complex application there is no way of telling whether you have caught all exceptions you want to catch.
You probably don't want to crash your application or present your user an exception with a callstack.
In that case you should split up your application into transactional operations, or _transactions_ for short, to contain how far an exception can propagate. Let's define the term _transaction_.

- A piece of code is a valid transaction if its abortion would not harm the health of the rest of the application.

- A transaction may contain other subtransactions.

Given that we've succesfully composed our code in terms of transactions, exceptions can be handled properly and safely in the following structured way.

1. Place a try-catch-all construction at the top of each transaction, such that it is guaranteed that each exception will not propagate beyond the transaction in which it occurs. Make sure the exception is properly handled and logged. If the exception cannot be properly handled in a particular transaction it should be rethrown and propagated to the parent transaction.

2. Never place a try-catch construction at a point in your program where it incorrectly may prevent a transaction to be aborted.

3. If your transactions are not bigger than they need to be, then your application is probably decently resilient to exceptions.

How a program should be split up into transactions is very much dependent on the program.
Some programs (perhaps a CLI) may even consist of a single transaction.

Let's take a web application as an example. In a web application each request should _at least_ be a separate transaction because a failure to handle a request should not bring the web application down or influence other requests in any way.
If it is appropriate to split a request into more than one transaction, then do so by all means.

All right. We've achieved that any uncaught exception only affects its containing transaction.
However, we still don't know if we've missed any exceptions that should _not_ cause the transaction to be aborted.
What can we do about that?

1. Don't throw exceptions in your code if it shouldn't abort the transaction. Instead make the corresponding failure part of the normal code path [using a `Result` type](/?page=rop-cs-1).

2. For exceptions thrown by 3rd party APIs, make sure to study the documentation to find any uncaught exceptions that you could have missed, or be on the safe side and place catch-all clauses around 3rd party API calls.

With these rules of thumb we should be able to use exceptions to their strength instead of letting them make our code complicated and unpredictable.
