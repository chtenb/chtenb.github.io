% Railroad Oriented Programming in C#: Part 4

In the [previous part](/?page=rop-cs-3) we looked at how we could construct `Result` instances more easily.
In this part we will look at slightly more complex railway tracks and wrap up the series.

## Subtracks and failure recovery

Railroad Oriented Programming is not limited to having a single straight railroad.
As we compose functions together writing our program, a more complex railroad system will evolve, reflecting our program flow.
It is highly recommended that one does not put too much complex railroad logic in a single function, but it is perfectly possible to construct subtracks within a railroad function.
Let's give an example that demonstrates having a subtrack and performing a failure recovery.

Suppose that now the `SendEmail` function does not return a `string` on failure, but some failure object like an `Exception` instance.

~~~~cs
Result<Unit, Exception> SendEmail(EmailMessage email, MailServer server);
~~~~

We could then inspect this failure object and decide how to handle it based on the kind of failure.
Suppose we want to send an email to the server, but we have a fallback server in case the first server fails.

~~~~cs
/// <returns>Message to be printed on the screen</returns>
string MailMessageToUser(string username, string msg, MailServer server1, MailServer server2) {
  return GetUser(username)
    .OnSuccess(GetEmailAddress)
    .OnSuccess(emailAddress => CreateEmailMessage(emailAddress, msg))
    .OnSuccess(email => SendEmail(email, server1)
      .OnFailure(ex => ex switch {
        ServerNotFoundException => 
          // Attempt server1. We don't need to inspect the second exception,
          // and can directly transform it to an error string using OnFailure.
          SendEmail(email, server2).OnFailure<string>(ex => Result.Fail(ex.Message)),
        _ => Result.Fail(ex.Message)
      })
    )
    .Handle(
      _ => "Email sent",
      error => {
        LogError(error);
        return "Email not sent";
      }
    );
}
~~~~

Here we attempt to defer our email to a second mail server when the first server appears unreachable.
The function `MailMessageToUser` having two mail servers as parameters is a little odd, and probably not how we would want to do it in real life.
But it demonstrates having subtracks and failure recovery very well in the context of our email example.

~~~~pikchr
include::rop.pikchr[]

startResult("GetUser","User","string")
onSuccess("GetEmailAddress","string")
onSuccess("CreateEmailMessage","MailMessage")
newline

S0: arrow color lightblue
B1: box "SendEmail" fit
line right linewid color orange behind B1
EX: oval "Exception" fit
arrow right linewid color orange behind B1
B2: box "SendEmail2" fit
line right linewid*2 color lightblue behind B2
oval "Unit" fit
E: line right color lightblue behind last oval

line behind B1 from B1.e right linerad then up then right until even with B2.e then right linerad*2 then down then right color lightblue
line behind EX from EX.e right linerad then down then right color orange

move from S0.start down lineht
line right until even with E.end color orange

line from B2.e right linerad then down then right color orange behind B2

move to E.end

handle("Handle","string")
~~~~

## Asynchronous programming

Using the `Result` type for asynchronous programming is perfectly possible, but again comes with a few hacks to account for some C# compiler limitations.
Maybe I'll write another article about that some time.

## Conclusion

Here follows the code for the `Result` type we've produced in this article series. 

~~~~cs
  public abstract class Result<TSuccess, TFailure> {

    public abstract Result<TNextSuccess, TFailure> OnSuccess<TNextSuccess>(
      Func<TSuccess, Result<TNextSuccess, TFailure>> onSuccess);
    public abstract Result<TSuccess, TNextFailure> OnFailure<TNextFailure>(
      Func<TFailure, Result<TSuccess, TNextFailure>> onFailure);
    /// <summary>
    /// Prefer <see cref="OnSuccess"> and <see cref="OnFailure"> over this method for returning Result types.
    /// </summary>
    public abstract TReturn Handle<TReturn>(Func<TSuccess, TReturn> onSuccess, Func<TFailure, TReturn> onFailure);

    public bool IsSuccess() => this is Success;
    public bool IsFailure() => this is Failure;

    #region Void overloads (Because void is not an actual type in .NET)

    public void HandleVoid(Action<TSuccess> onSuccess, Action<TFailure> onFailure) {
      _ = onSuccess ?? throw new ArgumentNullException(nameof(onSuccess));
      _ = onFailure ?? throw new ArgumentNullException(nameof(onFailure));

      _ = Handle(onSuccess.AsFunc(), onFailure.AsFunc());
    }

    #endregion

    public sealed class Success : Result<TSuccess, TFailure> {
      public TSuccess ResultValue { get; }

      public Success(TSuccess result) => ResultValue = result;

      public override Result<TNextSuccess, TFailure> OnSuccess<TNextSuccess>(
        Func<TSuccess, Result<TNextSuccess, TFailure>> onSuccess)
          => onSuccess(ResultValue);

      public override Result<TSuccess, TNextFailure> OnFailure<TNextFailure>(
        Func<TFailure, Result<TSuccess, TNextFailure>> onFailure)
          => Result.Succeed(ResultValue);

      public override TReturn Handle<TReturn>(Func<TSuccess, TReturn> onSuccess, Func<TFailure, TReturn> onFailure)
          => onSuccess(ResultValue);
    }

    public sealed class Failure : Result<TSuccess, TFailure> {
      public TFailure ErrorValue { get; }

      public Failure(TFailure error) => ErrorValue = error;

      public override Result<TNextSuccess, TFailure> OnSuccess<TNextSuccess>(
        Func<TSuccess, Result<TNextSuccess, TFailure>> onSuccess)
          => Result.Fail(ErrorValue);

      public override Result<TSuccess, TNextFailure> OnFailure<TNextFailure>(
        Func<TFailure, Result<TSuccess, TNextFailure>> onFailure)
          => onFailure(ErrorValue);

      public override TReturn Handle<TReturn>(Func<TSuccess, TReturn> onSuccess, Func<TFailure, TReturn> onFailure)
          => onFailure(ErrorValue);
    }

    public static implicit operator Result<TSuccess, TFailure>(Result.GenericSuccess<TSuccess> success)
        => new Success(success.Value);

    public static implicit operator Result<TSuccess, TFailure>(Result.GenericFailure<TFailure> failure)
        => new Failure(failure.Value);

    private Result() { }
  }

  /// <summary>
  /// This factory method class makes it possible to create result objects without
  /// having to specify the full result type explicitly.
  /// If the generic types cannot be inferred they can also be explicitly passed.
  /// </summary>
  public static class Result {
    public static GenericSuccess<TSuccess> Succeed<TSuccess>(TSuccess result)
        => new(result);

    public static GenericFailure<TFailure> Fail<TFailure>(TFailure error)
        => new(error);

    public static Result<TSuccess, TFailure> Succeed<TSuccess, TFailure>(TSuccess result)
        => Succeed(result);

    public static Result<TSuccess, TFailure> Fail<TSuccess, TFailure>(TFailure error)
        => Fail(error);

    public static GenericSuccess<Unit> Succeed()
        => Succeed(Unit.unit);

    public static GenericFailure<Unit> Fail()
        => Fail(Unit.unit);

    public readonly struct GenericFailure<T> {
      public T Value { get; }

      public GenericFailure(T value) {
        Value = value;
      }
    }

    public readonly struct GenericSuccess<T> {
      public T Value { get; }

      public GenericSuccess(T value) {
        Value = value;
      }
    }
  }
~~~~
