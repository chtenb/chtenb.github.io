The missing C# built-in type: void
==================================

## The problem: void is not a type

Suppose you wanted to write a `Map` function for tasks.
The definition is very simple.

~~~~cs
async Task<T2> Map<T1, T2>(Task<T1> task, Func<T1, T2> f) => f(await task);
~~~~

You can then use it as follows.

~~~~cs
Task<int> DoubleIntAsync(Task<int> task)
{
  return Map(task, i => i * i);
}
~~~~

There is a problem however.
We've written our `Map` function to be able to deal with `Task<>` and `Func<>`.
But tasks and functions can of course also have void values.
And since the type system doesn't allow us to simply use `Task<void>` and `Func<void>` there exist special void cases of the `Task<>` and `Func<>` types, namely `Task` and `Action`.
And that disallows us from using our `Map` for the void cases of these types.
In other words, the following functions won't compile.

~~~~cs
Task PrintIntAsync(Task<int> task)
{
  return Map(task, Console.WriteLine);
}

Task<string> ReturnTaskFinished(Task task)
{
  return Map(task, () => "task finished");
}

Task LogTaskFinished(Task task)
{
  return Map(task, () => Console.WriteLine("task finished"));
}
~~~~

We would have to write `Map` overloads to support these void cases.

~~~~cs
async Task Map<T1>(Task<T1> task, Action<T1> f) => f(await task);
async Task Map(Task task, Action f) { await task; f(); }
async Task<T2> Map<T2>(Task task, Func<T2> f) { await task; return f(); }
~~~~

In this case the function definitions are fairly simple and we only need four of them, but the general problem is bigger.
For each additional type involved that has a void case, the amount of necessary overloads doubles.
And every time we want to write a function that deals with generic types in a generic way (like `Map`) we encounter this issue and have to write all the overloads.
And don't forget that the `Action` and `Task` void cases also had to be written to work around this issue.

## A poor man's solution: the unit type

The [unit type](https://en.wikipedia.org/wiki/Unit_type) is nothing but a type with only one value.
Many functional programming languages do not actually support void functions like C# does.
Instead they have a builtin unit type, which is used whenever a function doesn't return any actual data.
We can create our own C# version of a `Unit` and use it instead of `void`.

~~~~cs
public struct Unit : IEquatable<Unit>
{
  public static readonly Unit unit;
  public override bool Equals(object obj) => obj is Unit;
  public override int GetHashCode() => 0;
  public static bool operator ==(Unit left, Unit right) => left.Equals(right);
  public static bool operator !=(Unit left, Unit right) => !(left == right);
  public bool Equals(Unit other) => true;
  public override string ToString() => "()";
}
~~~~

If we now have a function that is `void` we can have it return `Unit` instead, so that it can be used as a `Func<Unit>` delegate.
Similarly, if we need a `Task` without a value, we can simply use `Task<Unit>`.

But our code doesn't live in isolation.
We have to deal with existing code and an existing ecosystem, both of which expose a lot of void oriented types and functions.
Luckily C# supports extension methods, which allow use to deal with this in an acceptable way and convert void cases to their unit counterparts.

~~~~cs
using static Unit;

public static class ExtensionMethods
{
  public static async Task<Unit> AsUnitTask(this Task task)
  {
    await task;
    return unit;
  }

  public static Func<TResult, Unit> AsFunc<TResult>(this Action<TResult> action)
  {
    return result =>
    {
      action(result);
      return unit;
    };
  }

  public static Func<Unit, Unit> AsFunc(this Action action)
  {
    return _ =>
    {
      action();
      return unit;
    };
  }
}
~~~~

Now we can rewrite the original snippets as follows.

~~~~cs
Task<int> DoubleIntAsync(Task<int> task)
{
  return Map(task, i => i * i);
}

Task<Unit> PrintIntAsync(Task<int> task)
{
  // C# does not allow us to call the extension method on the method group directly
  Action<int> a = Console.WriteLine; // First convert the method group to the delegate
  return Map(task, a.AsFunc()); // Now we can call the extension method on the delegate
}

Task<string> ReturnTaskFinished(Task task)
{
  return Map(task.AsUnitTask(), _ => "task finished");
}

Task<Unit> LogTaskFinished(Task task)
{
  Action a = () => Console.WriteLine("task finished");
  return Map(task.AsUnitTask(), a.AsFunc());
}
~~~~

It may seem that we've merely moved the burden from writing `Map` overloads to writing extension methods.
But that is not the case.
These conversion methods have to be written once per void case type, while the overloads had to be written for _each function_ that uses types with void cases generically, like `Map`.
And as demonstrated earlier, the number of overloads explodes with the number of types with a void case involved.

Yes, it would have been a lot better if `void` were a valid type.
But having a separate `Unit` type handy for when you need it is the next best thing.
And when you are writing a generic class, don't introduce another void case.
