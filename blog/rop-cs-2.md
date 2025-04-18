Railroad Oriented Programming in C#: Part 2
===========================================

In the [previous part](/?page=rop-cs-1) we looked at problems with traditional forms of handling failure.
Here we will look at one solution to deal with these problems: a `Result` type that allows for a success case and a failure case.

## A result type supporting the failure path
While C# does not directory support Discriminated Unions, it does support subclassing.
Since a class can have multiple subclasses, and any object is always just one of them, we can use this phenomenon to implement the notion of having two return types, one for the success result, and one for the failure result.


~~~~cs
public abstract class Result {
  public sealed class Success : Result { }
  public sealed class Failure : Result { }
  // Private constructor so we are certain that Success and Failure are the only subclasses
  private Result () { }
}
~~~~

However, this class does not allow us to associate any return data with either the success or the failure result.
We can fix that.


~~~~cs
public abstract class Result<TSuccess, TFailure> {

  public sealed class Success : Result<TSuccess, TFailure> {
    public readonly TSuccess SuccessValue;
    public Success(TSuccess result) {
      SuccessValue = result;
    }
  }

  public sealed class Failure : Result<TSuccess, TFailure> {
    public readonly TFailure FailureValue;
    public Failure(TFailure error) {
      FailureValue = error;
    }
  }

  // Private constructor so we are certain that Success and Failure are the only subclasses
  private Result () { }
}
~~~~

With this in our toolkit we can now implement our `GetEmailAddress` function from earlier with an explicit failure path.


~~~~cs
Result<User, string> GetUser(string username) {
  var user = Datastore.FindUser(username);
  if (user == null)
    return new Result<User, string>.Failure("User has no email");
  return new Result<User, string>.Success(user);
}
~~~~

Usage of this function would look something like


~~~~cs
var result = GetUser(username);
if (result is Result<User,string>.Success) {
  var user = ((Result<User,string>.Success)result).ResultValue;
  // Do what you wanna do
} else {
  var error = ((Result<User,string>.Failure)result).ErrorValue;
  // Handle the failure appropriately
}
~~~~

As you can see we've achieved an explicit failure path.
When we call `GetUser` we obtain a result object and this encourages us to consider both the success and the failure case.
But the code leaves much to be desired.
Even more so when we need to call more than one function.


~~~~cs
Result<string, string> GetEmailAddress(User user);

// ...

var result = GetUser(username);
if (result is Result<User, string>.Success) {
  var user = ((Result<User, string>.Success)result).ResultValue;
  var result2 = GetEmailAddress(user);
  if (result2 is Result<string, string>.Success) {
    var email = ((Result<string, string>.Success)result2).ResultValue;
    // And so on...
  } else {
    var error2 = ((Result<string, string>.Failure)result2).ErrorValue;
    // Handle the failure appropriately
  }
} else {
  var error = ((Result<User, string>.Failure)result).ErrorValue;
  // Handle the failure appropriately
}
~~~~

We would like to

- not have to unwrap the `Result` instance by doing a type check + cast
- not have a new nesting level for each subsequent function we call
- not have to handle all failures individually
- not have to specify the whole type when creating a `Result` instance: `new Result<User, string>.Success()`

### A fluent result type

To resolve the complaints about our previous implementation, we'll define an `OnSuccess` function and a `Handle` function.
They will do the unwrapping for us and form a [Fluent Interface](https://en.wikipedia.org/wiki/Fluent_interface) and thereby removing the nesting.
Moreover, the OnSuccess function will "shortcircuit" the failure path, such that we only have to handle the failure path once.


~~~~cs
public abstract class Result<TSuccess, TFailure> {

  public abstract Result<TNextSuccess, TFailure> OnSuccess<TNextSuccess>(
    Func<TSuccess, Result<TNextSuccess, TFailure>> onSuccess);
  public abstract TReturn Handle<TReturn>(Func<TSuccess, TReturn> onSuccess, Func<TFailure, TReturn> onFailure);

  public sealed class Success : Result<TSuccess, TFailure> {
    public TSuccess SuccessValue { get; }

    public Success(TSuccess result) => SuccessValue = result;

    public override Result<TNextSuccess, TFailure> OnSuccess<TNextSuccess>(
      Func<TSuccess, Result<TNextSuccess, TFailure>> onSuccess)
        => onSuccess(SuccessValue);

    public override TReturn Handle<TReturn>(Func<TSuccess, TReturn> onSuccess, Func<TFailure, TReturn> onFailure)
        => onSuccess(SuccessValue);
  }

  public sealed class Failure : Result<TSuccess, TFailure> {
    public TFailure FailureValue { get; }

    public Failure(TFailure error) => FailureValue = error;

    public override Result<TNextSuccess, TFailure> OnSuccess<TNextSuccess>(
      Func<TSuccess, Result<TNextSuccess, TFailure>> onSuccess)
        => new Failure(FailureValue);

    public override TReturn Handle<TReturn>(Func<TSuccess, TReturn> onSuccess, Func<TFailure, TReturn> onFailure)
        => onFailure(FailureValue);
  }

  private Result() { }
}
~~~~

Apart from the daunting function signatures, the actual function bodies are trivial.
Yet they suddenly allow us to write very concise code.
Compare the following with what we had in the previous section.


~~~~cs
GetUser(username)
  .OnSuccess(GetEmailAddress);
  .Handle(
    emailAddress => ..., // Do your thing
    error => ... // Handle the failure appropriately
  );
~~~~

If we visualize the code flow above in a diagram, it becomes clear why this style of programming is sometimes referred to as _railway oriented programming_.
The `Result` type encapsulates two "paths" or "tracks", the success track and the failure track.


~~~~pikchr
scale = .8

R: oval "Result" fit
arrow from R.n right color lightblue behind R
oval "Success" fit fill lightblue
arrow from R.s right color orange behind R
oval "Failure" fit fill orange
~~~~

And the `OnSuccess` and `Handle` methods form trackpieces.


~~~~pikchr
<!-- include: rop.pikchr -->

onSuccess("OnSuccess", "SuccessValue")
~~~~


~~~~pikchr
<!-- include: rop.pikchr -->

handle("Handle", "EndValue")
~~~~

The railway of the example code would look like


~~~~pikchr
<!-- include: rop.pikchr -->

startResult("GetUser","User","string")
onSuccess("GetEmailAddress","string")
handle("Handle","string")
~~~~

### Another example

Suppose now that we needed to write the following function.


~~~~cs
/// <returns>Message to be printed on the screen</returns>
string MailMessageToUser(string username, string msg);
~~~~

And suppose that we have the following functions at our disposal.


~~~~cs
Result<User, string> GetUser(string username);
Result<string, string> GetEmailAddress(User user);
Result<EmailMessage, string> CreateEmailMessage(string emailAddress, string msg);
Result<Unit, string> SendEmail(EmailMessage email);
~~~~

If you're wondering what that `Unit` type is, it's a replacement for `void`, since we can't put `void` in there.
For more information refer to [The missing C# built-in type: void](/?page=unit-cs).

Then we could implement the function as follows.


~~~~cs
/// <returns>Message to be printed on the screen</returns>
string MailMessageToUser(string username, string msg) {
  return GetUser(username)
    .OnSuccess(GetEmailAddress)
    .OnSuccess(email => CreateEmailMessage(email, msg))
    .OnSuccess(SendEmail)
    .Handle(
      _ => "Email sent",
      error => {
        Log(error);
        return "Email not sent";
      }
    );
}
~~~~

The railway of the example code would look like


~~~~pikchr
<!-- include: rop.pikchr -->

startResult("GetUser","User","string")
onSuccess("GetEmailAddress","string")
newline
onSuccess("CreateEmailMessage","EmailMessage")
onSuccess("SendEmail","Unit")
handle("Handle","string")
~~~~

### Void handlers

If we would rather handle the end result without returning anything, e.g. using void methods only, we would need a variant of `Handle` for that.


~~~~cs
public abstract class Result<TSuccess, TFailure> {

  // ...

  public void HandleVoid(Action<TResult> onSuccess, Action<TError> onFailure) {
    _ = onSuccess ?? throw new ArgumentNullException(nameof(onSuccess));
    _ = onFailure ?? throw new ArgumentNullException(nameof(onFailure));

    _ = Handle(onSuccess.AsFunc(), onFailure.AsFunc());
  }
}
~~~~

Then we could use it as follows.


~~~~cs
/// <returns>Message to be printed on the screen</returns>
string MailMessageToUser(string username, string msg) {
  return GetUser(username)
    .OnSuccess(GetEmailAddress)
    .OnSuccess(email => CreateEmailMessage(email, msg))
    .OnSuccess(SendEmail)
    .HandleVoid(
      _ => {
        Console.WriteLine("Email sent");
      },
      error => {
        Log(error);
        Console.WriteLine("Email not sent");
      }
    );
}
~~~~

For the implementation of `AsFunc`, refer to [The missing C# built-in type: void](/?page=unit-cs).

### The OnFailure method

If we have a OnSuccess method, there is no reason why we couldn't have an OnFailure method too.
This would allow us to do operations on the failure track, such as modifying the error, or recovering from the error and get back on the success track.


~~~~pikchr
<!-- include: rop.pikchr -->

onFailure("OnFailure","ErrorValue")
~~~~


~~~~cs
/// <returns>Message to be printed on the screen</returns>
string MailMessageToUser(string username, string msg) {
  return GetUser(username)
    .OnSuccess(GetEmailAddress)
    .OnSuccess(email => CreateEmailMessage(email, msg))
    .OnSuccess(SendEmail)
    .OnFailure(error => new Result<Unit, string>.Failure("An error occurred: " + error))
    .Handle(
      _ => "Email sent",
      error => {
        Log(error);
        return "Email not sent";
      }
    );
}
~~~~


~~~~pikchr
<!-- include: rop.pikchr -->

startResult("GetUser","User","string")
onSuccess("GetEmailAddress","string")
onSuccess("CreateEmailMessage","EmailMessage")
newline
onSuccess("SendEmail","Unit")
onFailureF("TransformError","string")
handle("Handle","string")
~~~~

[We still need to deal with the awkward construction of `Result` instances, and we'll do that in the next part. ➤](/?page=rop-cs-3)
