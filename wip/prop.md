# Property Testing

from https://fsharpforfunandprofit.com/posts/property-based-testing-2/:

1. pin down behavior of input types that are too loose
2. checking for typical results ("hard to prove, easy to verify")
3. checking against an alternative implementation ("test oracle")
  - avoid reimplementing the expected behavior in the test code
4. checking through structural induction ("solve a smaller problem first")
5. checking for preserved invariants ("some things never change")

6. check algebraic laws through observation function
checking commutative operations ("different paths, same destination")
checking an operation's inverse operation ("there and back again")
checking for idempotence ("the more things change, the more they stay the same")

check interaction between constructors, decorators and combinators of your algebra with respect to interesting relations,
such as equality or ordering

check above things for more specific subclasses of the input space
  this is especially appealing for 2 and 3
  - In the extreme scenario, just test individual input-output examples
