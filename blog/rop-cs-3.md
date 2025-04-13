% Railroad Oriented Programming in C#: Part 3

In the [previous part](/?page=rop-cs-2) we looked at an implementation of a `Result` type for explicit failure paths.
In this part we'll look at how we can improve the creation of these `Result` objects.

## Creating `Result` instances

When creating a `Result` instance we often find ourselves writing code like this.

~~~~cs
Result<User, string> GetUser(string username) {
  var user = Datastore.FindUser(username);
  if (user == null)
    return new Result<User, string>.Failure("User not found");
  return new Result<User, string>.Success(user);
}
~~~~

There is not much wrong with it, except that it may become cumbersome to have to specify those generic parameters all the time.
We'd much rather write the following.

~~~~cs
Result<User, string> GetUser(string username) {
  var user = Datastore.FindUser(username);
  if (user == null)
    return Result.Fail("User not found");
  return Result.Succeed(user);
}
~~~~

Unfortunately the C# compiler cannot infer type parameters on types, but only on methods.
So we could introduce a static class `Result` and put some factory methods in there.
But that still wouldn't help us in the above example, because the C# compiler can't infer type parameters based on the return type of the enclosing function.
This is an annoying limitation, but something we have to live with for now.

However, there are some clever tricks we can apply.
Alexey Golub explains one neat approach in his article https://tyrrrz.me/blog/return-type-inference[Simulating Return Type Inference in C#].
The idea is that we introduce types `GenericSuccess` and `GenericFailure` which do not have all the type parameters yet.
Then we introduce implicit cast operators to make it possible to cast it to a full result type with all the type parameters specified.
The win here is that the casting can be done by the compiler in a context where the type parameters are all clear from the context, even when it's based on the return type of the enclosing function.


~~~~cs
public abstract class Result<TSuccess, TFailure> {

  // ...

  public static implicit operator Result<TSuccess, TFailure>(Result.GenericSuccess<TSuccess> ok)
      => new Success(ok.Value);
  public static implicit operator Result<TSuccess, TFailure>(Result.GenericFailure<TFailure> error)
      => new Failure(error.Value);
}

public static class Result {
  public static GenericSuccess<TSuccess> Succeed<TSuccess>(TSuccess result) => new(result);
  public static GenericFailure<TFailure> Fail<TFailure>(TFailure error) => new(error);
  public static Result<TSuccess, TFailure> Succeed<TSuccess, TFailure>(TSuccess result) => Succeed(result);
  public static Result<TSuccess, TFailure> Fail<TSuccess, TFailure>(TFailure error) => Fail(error);
  public static GenericSuccess<Unit> Succeed() => Succeed(Unit.unit);
  public static GenericFailure<Unit> Fail() => Fail(Unit.unit);

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

If we now attempt to compile the previous code snippet, we find that the compiler is happy with the type parameters being left out.
However, there are still situations in which this will not infer all the types, for example when using a lambda expression, which has no explicit signature.

~~~~cs
Result<string, string> GetEmail(string username) {
  return GetUser(username)
    .OnSuccess(user => {
      return Result.Succeed("test@example.com");
    });
}
~~~~

This will give a compiler error saying that the type arguments could not be inferred.
In that case we should provide the type argument to the `OnSuccess` method.

~~~~cs
Result<string, string> GetEmail(string username) {
  return GetUser(username)
    .OnSuccess<string>(user => {
      return Result.Succeed("test@example.com");
    });
}
~~~~

As a rule of thumb, if one encounters any confusing compile errors, try supplying the type parameters to the `OnSuccess`, `OnFailure` and `Handle` methods, and work from there.

In the [next part](/?page=rop-cs-4) we will look at more complex railway tracks and conclude this series.
