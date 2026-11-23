---
title: Observation Algebras
numbersections: true
toc: true
---


Philosophy
==========

**Observations**
: An observation is a reported piece of information about the world, possibly made up of several independent or joint observations, and nothing more: two observations that carry the same information are the same observation.
Any further information about an observation, such as how often or when something was observed, counts as an observation in its own right.

**Joint Observations**
: Observations do not only come in isolation.
Observations that were made together, such as the fields of one record or the parts of one sensor reading, form a joint observation.
Observations that were made separately are independent.
Independent observations can be interpreted together but don’t have to be.
The parts of a joint observation, however, are only claimed in the context of each other: none of them stands on its own.

**Trivial Observations**
: That something was reported is information in its own right, even if the report says nothing more.
This means we can have a trivial observation, that does not have any details, which is different from having no observation at all.

**Open World Principle**
: It is often not possible to know whether a set of observations is complete, so new observations must always be admissible.
In particular, not having some observation is not evidence against it.

**Safe Reasoning Principle**
: Since a set of observations is never known to be complete, a conclusion is only safe if new independent observations cannot invalidate it.


Observation Algebra
===================

We propose an algebraic structure to encode observations while adhering to the philosophy described earlier.
An element of the structure represents an observation, which may itself consist of several independent or joint observations.
An observation that cannot be split into independent observations is called *irreducible*.

**Definition (Observation Algebra).** An *observation algebra*, or *commutative idempotent dioid*, is a set `D` closed under two binary operations `+` and `⋅` and with two distinguished elements `0, 1 ∈ D`, such that for all `a, b, c ∈ D`:

1. *Addition Associativity*: `a + (b + c) = (a + b) + c`
2. *Addition Identity*: `0 + a = a`
3. *Addition Commutativity*: `a + b = b + a`
4. *Addition Idempotency*: `a + a = a`
5. *Multiplication Associativity*: `a(bc) = (ab)c`
6. *Multiplication Identity*: `1 ⋅ a = a`
7. *Multiplication Commutativity*: `ab = ba`
8. *Multiplication Idempotency*: `aa = a`
9. *Distributivity*: `a(b + c) = ab + ac`
10. *Annihilation*: `a ⋅ 0 = 0`

The *sum* `a + b` combines `a` and `b` as independent observations, and the *product* `a ⋅ b` combines them into a joint observation.
The element `0` represents no observation, and `1` represents the trivial observation.
By the *Open World Principle*, new observations are always admissible, so any two observations can be added.
Hence the observation algebra is closed under addition.
An observation is determined by its information alone (*Observations*), so it does not matter how independent observations are grouped (1), in which order they arrive (3), or whether one is repeated (4).
Adding no observation changes nothing (2), by *Trivial Observations*.
Since independent observations can be considered together and any two observations can be added, by extension any two observations can be multiplied.
A joint observation carries exactly the information of its parts, so by *Observations* it does not matter how its parts are grouped (5) or ordered (7), or whether a part is repeated (8).
A trivial part carries no information, so it does not change a joint observation (6), by *Trivial Observations*.
A joint observation claims its parts only in the context of each other (Joint Observations).
If one of its parts was never observed, there is no context in which the others were claimed, so the joint observation cannot be made (10).
If a part was observed several times independently, each of these observations provides its own context for the others, so each forms a separate joint observation (9).
Annihilation can intuitively be understood as distribution of an empty sum, just as a part that was never reported has no reports to complete the joint observation with.

The *Safe Reasoning Principle* is not an axiom: it restricts which functions we use on observations for safe reasoning, which we will introduce later.

Another way of looking at this is as two commutative idempotent monoids that are combined by distributivity, hence the term *commutative idempotent dioid*.

## Examples

**Example (Powerset).** Let `S` be any set, then `(𝒫(S), ∪, ∩, ∅, S)` is an observation algebra.
*Proof.* `𝒫(S)` is closed under `∪` and `∩`, and contains `∅` and `S`. Axioms 1, 3, 4 and 5, 7, 8 are associativity, commutativity and idempotency of `∪` and `∩`; 2 is `∅ ∪ a = a`; 6 is `S ∩ a = a`, using `a ⊆ S`; 9 is distributivity of `∩` over `∪`; 10 is `∅ ∩ a = ∅`.
∎

**Example (Sets of half-open intervals).** Let `(T, ≤)` be a totally ordered set of *positions*, including extrema `-∞, +∞` with `-∞ < t < +∞` for all `t ∈ T`. For `s, e ∈ T` write
```
[s, e) := { t ∈ T | s ≤ t < e }
```
and note `[s, e) = ∅` whenever `e ≤ s`.
Let `D` be the set of all finite unions of such intervals, with
```
a + b := a ∪ b     0 := ∅ = [s, s)
a ⋅ b := a ∩ b     1 := T ∖ {+∞} = [-∞, +∞)
```
Then `(D, +, ⋅, 0, 1)` is an observation algebra.
*Proof.* First, the operations are well defined on `D`. Closure under `+` is immediate, since a union of two finite unions of intervals is one. For `⋅`, totality of `≤` gives
```
[s₁, e₁) ∩ [s₂, e₂) = [ max(s₁, s₂), min(e₁, e₂) )
```
so an intersection of intervals is an interval, and `(⋃ᵢ Iᵢ) ∩ (⋃ⱼ Jⱼ) = ⋃_{i,j} (Iᵢ ∩ Jⱼ)` is a finite union of intervals. Also `0 = [s, s) ∈ D` and `1 = [-∞, +∞) ∈ D`.
Hence `D` is a sublattice of `(𝒫(T ∖ {+∞}), ∪, ∩)` containing `∅` and `T ∖ {+∞}`, and each axiom holds already in the powerset lattice.
∎

**Example (Lattice).** Generalizing the previous examples, any bounded distributive lattice is also an observation algebra.
Let `(L, ∨, ∧, ⊥, ⊤)` be a bounded distributive lattice, and let `D = L`, with
```
0 := ⊥     1 := ⊤
a + b := a ∨ b
a ⋅ b := a ∧ b
```
Then `(D, +, ⋅, 0, 1)` is an observation algebra.

**Example (Lineage).** Let `S` be a set of *sources*, and `⊥ ∉ 𝒫(S)` a separate element representing no observation.
An element is either `⊥`, or the set of sources that contributed to it. Let `D = 𝒫(S) ∪ {⊥}`, with, for `a, b ⊆ S`,
```
0 := ⊥     1 := ∅
a + b := a ∪ b             a ⋅ b := a ∪ b      
⊥ + a := a + ⊥ := a        ⊥ ⋅ a := a ⋅ ⊥ := ⊥
```
Then `(D, +, ⋅, 0, 1)` is an observation algebra.

Both independent and joint observations draw on the sources of all their parts.
The trivial observation `∅` involves no sources, which is different from not observing anything at all.

Unlike in a lattice, the product grows: `a ⊑ ab`.
Lineage records *which* sources contributed, but not *how*: it cannot distinguish independent from joint observations, since `+` and `⋅` coincide on sets.

This algebra is known as the *lineage semiring* in database provenance (Green, ICDT 2009).

**Example (Discrete).** Let `S` be a set of *values*, and `* ∉ S` a separate element representing an unspecified value. Let `D = 𝒫(S ∪ {*})`, with
```
0 := ∅     1 := {*}
a + b := a ∪ b
a ⋅ b := (a ∩ b) ∪ (a if * ∈ b) ∪ (b if * ∈ a)
```
Then `(D, +, ⋅, 0, 1)` is an observation algebra: it is the taxonomy refinement (see below) with root `*`, where every value refines `*` and no value refines another.

Two different values observed jointly cancel each other, while independent reports of them coexist:
```
{red} ⋅ {red} = {red}
{red} ⋅ {green} = ∅
{red} ⋅ {*} = {red}
{red, green} ⋅ {green, blue} = {green}
{red, *} ⋅ {green, blue} = {green, blue}
```
Typical uses are categorical attributes, such as colours, statuses or country codes.

The algebra is not a lattice, since `{*} + {red} = {*, red} ≠ {*}`: an unspecified value and a specific value can be observed independently.
With `1 = S` instead of `{*}`, the product becomes intersection and we recover the powerset example, but then the trivial observation reads as "all values at once" rather than "an unspecified value".

**Example (Taxonomy Refinement).** Let `(T, ≤)` be a *taxonomy*: a partial order with a root `*` such that `x ≤ *` for all `x ∈ T`, and in which the ancestors `{ y ∈ T | x ≤ y }` of any `x` form a total order.
Read `x ≤ y` as "`x` refines `y`", e.g. `Amsterdam ≤ Netherlands ≤ Europe`.
Two nodes are *compatible* if one refines the other, and then we write
```
x ∧ y := x    if x ≤ y
         y    if y ≤ x
```
Let `D = 𝒫(T)`, with
```
0 := ∅     1 := {*}
a + b := a ∪ b
a ⋅ b := { x ∧ y | x ∈ a, y ∈ b, x and y compatible }
```
Then `(D, +, ⋅, 0, 1)` is an observation algebra.

The product refines joint observations and drops the incompatible combinations:
```
{Netherlands} ⋅ {Amsterdam, Paris} = {Amsterdam}
```

**Example (Free Named Observations).**
We define `Obs(Atom, Attr)` as the free observation algebra over a set of atoms `Atom`, with names from a set of attributes `Attr`.
When `Atom` and `Attr` are clear from context, we simply write `Obs`.

An **atom** is an atomic observation. The set of all atoms is notated `Atom`.
An **attribute** is an atomic name. The set of all attributes is notated `Attr`.
An **attribute path** is an element of the free monoid on attributes, `Path := (Attr*, ., ε)`.

Then there are the following operations that generate the rest of the algebra.

- The naming operation `:` attaches an attribute path to a value. This pairing is written `path:val`.
- The product `[_, _]` combines two values into a joint observation.
- The sum `{_, _}` combines two values as independent observations.

Let `x, y, z ∈ Obs` and `a, b ∈ Path`.

- *Sum Associativity*: `{x, {y, z}} = {{x, y}, z}`
- *Sum Commutativity*: `{x, y} = {y, x}`
- *Sum Identity*: The identity value is denoted `{}`, and represents no observation: `{x, {}} = x`.
- *Sum Idempotency*: `{x, x} = x` "Having an observation twice is the same as having it once"

- *Product Associativity*: `[x, [y, z]] = [[x, y], z]`
- *Product Commutativity*: `[x, y] = [y, x]`
- *Product Identity*: The identity value is denoted `[]`, and represents the trivial observation: `[x, []] = x`.
- *Product Idempotency*: `[x, x] = x` "Having an observation twice is the same as having it once"

- *Product-Sum Distributivity*: `[x, {y, z}] = {[x, y], [x, z]}` "An observation involving two independently observed values is the same as observing those values separately."
- *Product-Sum Annihilation*: `[x, {}] = {}` "A joint observation can only be completed if all its parts are observed"

- *Named-Product Distributivity*: `a:[x, y] = [a:x, a:y]`
- *Named-Sum Distributivity*: `a:{x, y} = {a:x, a:y}`
- *Named Empty Sum*: `a:{} = {}` "No observation in general is the same as no observation on a subject"
- *Named Empty Product*: `a:[] = []` "No information in general is the same as no information on a subject"
- *Naming Associativity*: Naming is associative under this equality: `a:(b:x) = (a.b):x`.
- *Naming Identity*: Naming with the identity name is the same as having no name at all: `ε:x = x`.

The first four naming axioms follow from the fact that a free naming operator does not change the structure of observations it names.
Hence all algebra primitives (addition, multiplication and identities) are preserved.
The last two say that naming with a path is the same as naming with its attributes one after the other.

While product and sum are defined as binary operations, we will often write them as n-ary operations, since they are both associative.
So

- `{x} = x`
- `{x, y, z, ...} = {x, {y, {z, ...}}}`
- `[x] = x`
- `[x, y, z, ...] = [x, [y, [z, ...]]]`


Information Ordering
====================

Every observation algebra carries an order that compares how much is observed: `a ⊑ b` when `b` already includes every observation in `a`.

**Definition (Information Ordering).** Let `D` be an observation algebra. Denote `a ⊑ b` iff `a + b = b`.

**Theorem.** `⊑` is a partial order on `D`, with least element `0`.
*Proof.*
Let `a, b, c ∈ D`.

- Reflexivity: `a + a = a` by idempotency (4), hence `a ⊑ a`.
- Transitivity: Assume `a ⊑ b` and `b ⊑ c`. Then
```
a + c = a + (b + c)    (b ⊑ c)
      = (a + b) + c    (1)
      = b + c          (a ⊑ b)
      = c              (b ⊑ c)
```
hence `a ⊑ c`.
- Antisymmetry: Assume `a ⊑ b` and `b ⊑ a`. Then
```
b = a + b    (a ⊑ b)
  = b + a    (3)
  = a        (b ⊑ a)
```
- Least element: `0 + a = a` by identity (2), hence `0 ⊑ a`.
∎

**Theorem (Natural Order).** For all `a, b ∈ D`, `a ⊑ b` iff there is an `x ∈ D` with `a + x = b`.
*Proof.*
(⟹) If `a + b = b`, take `x = b`.
(⟸) If `a + x = b`, then
```
a + b = a + (a + x)    (a + x = b)
      = (a + a) + x    (1)
      = a + x          (4)
      = b
```
∎

So `b` includes `a` exactly when `b` is `a` together with some further independent observations.

The unit `1` need not be the greatest element: in the discrete observation algebra, `{*} + {x} = {*, x} ≠ {*}` for `x ≠ *`.

**Theorem (Sum implies Product).** For all `a, b ∈ D`, `ab ⊑ a + b`.
*Proof.*
To prove: `ab + (a + b) = a + b`.
```
a + b = (a + b)(a + b)           (8)
      = (a + b)a + (a + b)b      (9)
      = a(a + b) + b(a + b)      (7)
      = (aa + ab) + (ba + bb)    (9)
      = (a + ab) + (ab + b)      (7, 8)
      = ab + (a + b)             (1, 3, 4)
```
∎

Note that this theorem aligns with the philosophical idea of joint observations, in that independent observations can be considered together.
This theorem confirms that the joint combination of independent observations is indeed implied.

**Definition.** The *join* `a ⊔ b` is the least `c ∈ D` such that `a ⊑ c` and `b ⊑ c`.

**Theorem (Join is Sum).** For all `a, b ∈ D`, `a ⊔ b = a + b`.
*Proof.*
`a + b` is an upper bound of `a` and `b`:
```
a + (a + b) = (a + a) + b    (1)
            = a + b          (4)

b + (a + b) = (a + b) + b    (3)
            = a + (b + b)    (1)
            = a + b          (4)
```
It is the least one: let `a ⊑ c` and `b ⊑ c`. Then
```
(a + b) + c = a + (b + c)    (1)
            = a + c          (b ⊑ c)
            = c              (a ⊑ c)
```
hence `a + b ⊑ c`.
∎

So `(D, ⊑)` is a join-semilattice with least element `0`, and `+` is its join.

**Theorem (Sum and Product Monotonicity).** For all `a, b, c ∈ D`, if `a ⊑ b`, then `a + c ⊑ b + c` and `ac ⊑ bc`.
*Proof.* Assume `a ⊑ b`. Then
```
(a + c) + (b + c) = (a + b) + (c + c)    (1, 3)
                  = b + c                (a ⊑ b, 4)
```
and
```
bc = cb          (7)
   = c(a + b)    (a ⊑ b)
   = ca + cb     (9)
   = ac + bc     (7)
```
∎

**Theorem (Bounds).** Let `c ∈ D`. For all `a, b ∈ D`:
- if `a ⊑ c` and `b ⊑ c`, then `ab ⊑ a + b ⊑ c`,
- if `c ⊑ a` and `c ⊑ b`, then `c ⊑ ab ⊑ a + b`.

*Proof.*
In both cases, `ab ⊑ a + b` by *Sum implies Product*.
If `a ⊑ c` and `b ⊑ c`, then `a + b ⊑ c`, since `a + b` is the least upper bound of `a` and `b` by *Join is Sum*.
If `c ⊑ a` and `c ⊑ b`, then
```
c = cc    (8)
  ⊑ ac    (Product Monotonicity, c ⊑ a)
  = ca    (7)
  ⊑ ba    (Product Monotonicity, c ⊑ b)
  = ab    (7)
```
so `c ⊑ ab` by transitivity.
∎

**Definition.** The *meet* `a ⊓ b`, if it exists, is the greatest `c ∈ D` such that `c ⊑ a` and `c ⊑ b`.
By antisymmetry, it is unique if it exists.

**Corollary.** `a ⊓ b ⊑ ab` whenever `a ⊓ b` exists, by *Bounds*.

**Theorem (Meet by Product).** For all `a, b ∈ D`, `ab = a ⊓ b` iff `ab ⊑ a` and `ab ⊑ b`.
*Proof.*
(⟹) `a ⊓ b` is a lower bound of `a` and `b` by definition.
(⟸) `ab` is a lower bound of `a` and `b`, and every lower bound `c` of `a` and `b` satisfies `c ⊑ ab` by *Bounds*.
So `ab` is the greatest lower bound, and `ab = a ⊓ b` by uniqueness.
∎

The product need not be the meet: in the discrete observation algebra, `{*} ⋅ {red} = {red}`, which is not included in `{*}`, while the meet of `{*}` and `{red}` is `∅`.

<!--
## Irreducible Observations

An observation may consist of several independent observations, but those that do not are of special interest as they convey something about what the basic observations are for an algebra.

**Definition (Irreducible Observation).** An observation `x ∈ D` is *irreducible* if `x ≠ 0`, and `x = y + z` implies `x = y` or `x = z` for all `y, z ∈ D`.

**Definition (Prime Observation).** An observation `x ∈ D` is *prime* if `x ≠ 0`, and `x ⊑ y + z` implies `x ⊑ y` or `x ⊑ z` for all `y, z ∈ D`.

**Remark.** If observations are given as sums of primes, inclusion and redundancy can be decided term by term.
Let `x = x₁ + ⋯ + xₘ` with every `xᵢ` prime, and `y = y₁ + ⋯ + yₙ`.
Then `x ⊑ y` iff every `xᵢ` is included in some `yⱼ`.
In particular, a term `xₖ` can be removed from `x` without changing it iff `xₖ` is included in another term `xⱼ`.
Without primality, this fails: in `Obs`, `{a, [a, b]} ⊑ {a, b}`, although `[a, b]` is included in neither term, and `[a, b]` is redundant in `{a, [a, b]}`, even though `[a, b]` is not included in `a`.

**Example (Powerset).** The irreducible observations are the singletons `{s}`, and they are prime, since `{s} ⊆ y ∪ z` implies `s ∈ y` or `s ∈ z`.
The same holds in the discrete observation algebra and the taxonomy refinement.
The unit need not be irreducible: in the powerset, if `S` has at least two elements, then obviously `S` is not a singleton.

**Example (Lineage).** The irreducible observations are the trivial observation `∅` and the singletons `{s}`, and they are all prime.

**Example (Half-open intervals).** Over `ℤ ∪ {-∞, +∞}`, the irreducible observations are the unit intervals `[n, n + 1)`, and they are prime.
Over `ℝ ∪ {-∞, +∞}`, there are no irreducible observations at all: every non-empty interval `[s, e)` is the sum of `[s, m)` and `[m, e)` for any `s < m < e`.

**Example (Free Named Observations).** The joint observation `[a, b]` of two atoms is irreducible but not necessarily prime.
Intuitively this can be understood by *Sum implies Product*, `[a, b] ⊑ {a, b}`, while it is not the case that `[a, b] ⊑ a` or `[a, b] ⊑ b`.

**Theorem (Primes are Irreducible).** Every prime observation is irreducible.
*Proof.* Let `x` be prime and `x = y + z`. Then `x ⊑ y + z`, so `x ⊑ y` or `x ⊑ z`.
Also `y ⊑ y + z = x` and `z ⊑ y + z = x` by *Join is Sum*, so `x = y` or `x = z` by antisymmetry.
∎

**Theorem (Prime by Irreducibility).** If `ab ⊑ a` for all `a, b ∈ D`, then every irreducible observation is prime.
*Proof.* First, if `x ⊑ w`, then `xw = x`: `xw ⊑ x` by assumption, and `x ⊑ xw` by *Bounds*, since `x ⊑ x` and `x ⊑ w`.
Now let `x` be irreducible and `x ⊑ y + z`. Then
```
x = x(y + z)    (x ⊑ y + z)
  = xy + xz     (9)
```
so `x = xy` or `x = xz`, since `x` is irreducible.
In the first case, `x = xy = yx ⊑ y` by (7) and the assumption, and likewise `x ⊑ z` in the second case.
∎

By the *Meet by Product* theorem, the assumption says that the product is always the meet, as in a lattice.
So primality and irreducibility only differ in observation algebras where the product is not the meet.

**Theorem (Irreducible Decomposition).** If `D` is finite, then every observation is the sum of the irreducible observations it includes.
*Proof.* By strong induction on the number of observations included in `x`.
If `x = 0`, it is the empty sum, since `0` is not irreducible.
If `x` is irreducible, it is one of the irreducible observations it includes, and all others are included in it.
Otherwise `x = y + z` with `y ≠ x` and `z ≠ x`.
Then `y, z ⊑ x` by *Join is Sum*, so `y` and `z` include fewer observations than `x`, and are sums of irreducible observations by induction, all of which are included in `x`.
So `x` is a sum of irreducible observations it includes, and adding the remaining ones does not change the sum, since they are all included in `x`.
∎

In infinite observation algebras this can fail: over `ℤ ∪ {-∞, +∞}`, the interval `[0, +∞)` is not a finite sum of irreducible observations, since every finite sum of unit intervals is bounded.


Maps and Polynomials
====================

## Cartesian Products

**Definition (Cartesian Product).** Let `X` and `Y` be observation algebras. The *Cartesian product* `X × Y` is the set of pairs `(x, y)` with `x ∈ X` and `y ∈ Y`, with
```
(x, y) + (x', y') := (x + x', y + y')      0 := (0, 0)
(x, y) ⋅ (x', y') := (x ⋅ x', y ⋅ y')      1 := (1, 1)
```
We write `Xⁿ` for the Cartesian product of `n` copies of `X`, whose elements are the tuples `(x₁, …, xₙ)` with operations taken componentwise, where `X⁰` has the single element `()`.

An element of `X × Y` is a pair of observations, one in each algebra, kept side by side.

**Theorem.** `X × Y` is an observation algebra, and so is `Xⁿ`.
*Proof.* Each axiom holds componentwise, since it holds in each factor.
For example, `(x, y) ⋅ (0, 0) = (x ⋅ 0, y ⋅ 0) = (0, 0)` by (10).
∎

**Theorem.** The information ordering on `X × Y` is componentwise: `(x, y) ⊑ (x', y')` iff `x ⊑ x'` and `y ⊑ y'`. Likewise for `Xⁿ`.
*Proof.*
```
(x, y) ⊑ (x', y')  ⟺  (x + x', y + y') = (x', y')
                   ⟺  x + x' = x'  and  y + y' = y'
                   ⟺  x ⊑ x'  and  y ⊑ y'
```
The same argument applies to each component of a tuple.
∎

**Remark.** The Cartesian product `X × Y` keeps observations in separate algebras: `+` and `⋅` act on each component separately, so observations in `X` never interact with observations in `Y` by addition or multiplication.
Contrast this with two subjects in `Obs`, distinctly labeled by their own attributes `a` and `b`.
As independent observations `{a:x, b:y}`, they still combine jointly: `[{a:x, b:y}, {a:x', b:y'}]` contains the joint observations `[a:x, b:y']` and `[a:x', b:y]`.
As a joint observation `[a:x, b:y]`, they stand or fall together: independent alternatives for one part give independent records, `[a:{x, x'}, b:y] = {[a:x, b:y], [a:x', b:y]}`, and a missing part leaves no record at all, `[a:{}, b:y] = {}`.
In the Cartesian product, by contrast, a missing part leaves the other intact: `(x, 0) ≠ 0`.

## Maps

We will study functions between observation algebras, which we call *maps*.
Let `X` and `Y` be observation algebras. A map `f : X → Y` is called

- *monotone* if `x ⊑ y` implies `f(x) ⊑ f(y)`,
- *additive* if `f(x + y) = f(x) + f(y)`,
- *multiplicative* if `f(x ⋅ y) = f(x) ⋅ f(y)`,
- *normal* if `f(0) = 0`,
- *unital* if `f(1) = 1`,

for all `x, y ∈ X`.
A map `f : Xⁿ → Y` of several arguments is a map from the Cartesian product `Xⁿ`, so these properties apply to it directly.
We say that `f` has a property *in each argument* if it has it in each argument separately, with the other arguments fixed.

For maps `g, h : X → Y` we write `g + h` and `g ⋅ h` for the maps `x ↦ g(x) + h(x)` and `x ↦ g(x) ⋅ h(x)`.

**Remark.**
Additivity does not imply normality: a constant map `f(x) = c` with `c ≠ 0` is additive by (4), but `f(0) = c`.

### Monotone Maps

**Theorem (Cartesian Monotonicity).** A map `f : Xⁿ → Y` is monotone in each argument iff it is monotone.

*Proof.*
(⟸) Fix all arguments but the `i`-th. If `x ⊑ y`, then `(a₁, …, x, …, aₙ) ⊑ (a₁, …, y, …, aₙ)` componentwise, by reflexivity in the other components, so `f(a₁, …, x, …, aₙ) ⊑ f(a₁, …, y, …, aₙ)`.
(⟹) Let `a ⊑ b`. Replace the arguments one at a time, using monotonicity in each argument:
```
f(a₁, a₂, …, aₙ) ⊑ f(b₁, a₂, …, aₙ)
                 ⊑ f(b₁, b₂, …, aₙ)
                 ⋯
                 ⊑ f(b₁, b₂, …, bₙ)
```
so `f(a) ⊑ f(b)` by transitivity.
∎

In contrast to additivity, a product of monotone maps is always monotone: there are no cross terms to account for.

**Theorem (Monotone Sums and Products).** If `g, h : X → Y` are monotone, then so are `g + h` and `g ⋅ h`.

*Proof.* `+` and `⋅` are monotone in each argument by *Sum and Product Monotonicity* and (3, 7), hence monotone by *Cartesian Monotonicity*.
`g + h` and `g ⋅ h` are their compositions with `x ↦ (g(x), h(x))`, which is monotone by *Monotone Pairing*. Conclude by *Monotone Composition*.
∎

**Theorem (Additive implies Monotone).** Every additive map is monotone.

*Proof.* Let `x ⊑ y`, so `x + y = y`. Then `f(y) = f(x + y) = f(x) + f(y)`, hence `f(x) ⊑ f(y)`.
∎

**Corollary.** Every map that is additive in each argument is monotone.

*Proof.* By *Additive implies Monotone*, it is monotone in each argument, hence monotone by *Cartesian Monotonicity*.
∎

In particular, `+` and `⋅` are monotone, as are all operations that are additive in each argument.

**Theorem (Superadditivity).** If `f : X → Y` is monotone, then `f(x) + f(y) ⊑ f(x + y)` for all `x, y ∈ X`.

*Proof.* By *Join is Sum*, `x ⊑ x + y` and `y ⊑ x + y`, so `f(x) ⊑ f(x + y)` and `f(y) ⊑ f(x + y)` by monotonicity.
Hence `f(x) + f(y) ⊑ f(x + y)` by *Bounds*.
∎

**Lemma (Basic Monotone Maps).** Constant maps, the identity, and the projections `πᵢ : Xⁿ → X, (x₁, …, xₙ) ↦ xᵢ` are monotone.

*Proof.* For a constant `c`, `c ⊑ c` by reflexivity. The identity is immediate. For projections, `a ⊑ b` in `Xⁿ` means `aᵢ ⊑ bᵢ` for all `i`, since the order on `Xⁿ` is componentwise.
∎

**Lemma (Monotone Composition).** If `g : X → Y` and `h : Y → Z` are monotone, then so is `h ∘ g`.

*Proof.* If `x ⊑ y`, then `g(x) ⊑ g(y)`, so `h(g(x)) ⊑ h(g(y))`.
∎

So for monotonicity it makes no difference whether we consider each argument separately or all arguments at once.
In particular, a map that is monotone in each argument stays monotone when the same argument is used several times, as the next lemma shows.

**Lemma (Monotone Pairing).** For maps `g : X → Y` and `h : X → Z`, the map `x ↦ (g(x), h(x))` into `Y × Z` is monotone iff `g` and `h` are.

*Proof.* The order on `Y × Z` is componentwise, so `(g(x), h(x)) ⊑ (g(y), h(y))` holds iff `g(x) ⊑ g(y)` and `h(x) ⊑ h(y)`.
∎

**Lemma (Monotone Diagonal).** If `f : X × X → Y` is monotone in each argument, then `d(x) = f(x, x)` is monotone.

*Proof.* `d` is the composition of `x ↦ (x, x)`, which is monotone by *Basic Monotone Maps* and *Monotone Pairing*, with `f`, which is monotone by *Cartesian Monotonicity*. Conclude by *Monotone Composition*.
∎

### Additive Maps

**Lemma (Basic Additive Maps).** Constant maps, the identity, and the projections `πᵢ : Xⁿ → X` are additive.

*Proof.* For a constant `c`, `c = c + c` by (4). The identity is immediate. For projections, `πᵢ(a + b) = aᵢ + bᵢ = πᵢ(a) + πᵢ(b)`, since `+` on `Xⁿ` is componentwise.
∎

**Lemma (Additive Composition).** If `g : X → Y` and `h : Y → Z` are additive, then so is `h ∘ g`.

*Proof.* `h(g(x + y)) = h(g(x) + g(y)) = h(g(x)) + h(g(y))`.
∎

**Lemma (Additive Pairing).** For maps `g : X → Y` and `h : X → Z`, the map `x ↦ (g(x), h(x))` into `Y × Z` is additive iff `g` and `h` are.

*Proof.* `+` on `Y × Z` is componentwise, so `(g(x + y), h(x + y)) = (g(x), h(x)) + (g(y), h(y))` holds iff it holds in each component.
∎

**Lemma (Additive Sums and Scaling).** If `g, h : X → Y` are additive and `c ∈ Y`, then `g + h` and `x ↦ c ⋅ g(x)` are additive.

*Proof.*
```
g(x + y) + h(x + y) = (g(x) + h(x)) + (g(y) + h(y))      (1, 3)
c ⋅ g(x + y)        = c ⋅ g(x) + c ⋅ g(y)                (9)
```
∎

**Theorem (Cartesian Additivity).** If `f : Xⁿ → Y` is additive, then it is additive in each argument. The converse does not hold.

*Proof.* Fix all arguments but the `i`-th. By (4), `(a₁, …, x, …, aₙ) + (a₁, …, y, …, aₙ) = (a₁, …, x + y, …, aₙ)`, so additivity of `f` gives
```
f(a₁, …, x + y, …, aₙ) = f(a₁, …, x, …, aₙ) + f(a₁, …, y, …, aₙ)
```
For the converse, `⋅` is additive in each argument, but in the powerset of `{1, 2}`, `({1} + {2}) ⋅ ({2} + {1}) = {1, 2}`, while `{1} ⋅ {2} + {2} ⋅ {1} = ∅`.
∎

Unlike for monotonicity, additivity in each argument does not imply additivity.
Additivity in each argument is the weaker property, and the one that `⋅` and most operations satisfy.
The next lemma measures exactly what is lost when the same argument is used twice.

**Lemma (Additive Diagonal).** Let `f : X × X → Y` be additive in each argument, and `d(x) = f(x, x)`. Then
```
d(x + y) = d(x) + d(y) + f(x, y) + f(y, x)
```
so `d` is additive iff `f(x, y) + f(y, x) ⊑ d(x) + d(y)` for all `x, y ∈ X`.

*Proof.*
```
d(x + y) = f(x + y, x + y)
         = f(x, x + y) + f(y, x + y)                     (additive in the first argument)
         = f(x, x) + f(x, y) + f(y, x) + f(y, y)         (additive in the second argument)
         = d(x) + d(y) + f(x, y) + f(y, x)               (1, 3)
```
∎

**Corollary (Additive Cross Terms).** If `g, h : X → Y` are additive, then `g ⋅ h` is additive iff `g(x) h(y) + g(y) h(x) ⊑ g(x) h(x) + g(y) h(y)` for all `x, y ∈ X`.

*Proof.* Apply *Additive Diagonal* to `f(u, v) = g(u) ⋅ h(v)`, which is additive in each argument by *Additive Sums and Scaling* and (7).
∎

**Corollary.** If `g : X → Y` is additive, then `g ⋅ g` is additive.

*Proof.* `g ⋅ g = g` by (8).
∎

**Example.** On the half-open intervals over `ℤ ∪ {-∞, +∞}`, the shift `σ` is additive, but `x ↦ x ⋅ σ(x)` is not: for `x = [0, 1)` and `y = [1, 2)`, the cross term `y ⋅ σ(x) = [1, 2)` is not contained in `x ⋅ σ(x) + y ⋅ σ(y) = ∅`.

### Evaluation on Sums

When observations are given as finite sums, maps that are additive and normal in each argument can be evaluated term by term.

**Theorem (Pairwise Evaluation).** Let `f : X × Y → Z` be additive and normal in each argument. If `x = x₁ + ⋯ + xₘ` and `y = y₁ + ⋯ + yₙ`, with `m, n ≥ 0`, then
```
f(x, y) = Σ_{i ≤ m, j ≤ n} f(xᵢ, yⱼ)
```
*Proof.* For `m, n ≥ 1`, expand the first argument by additivity in the first argument, and then each term by additivity in the second argument.
If `m = 0` or `n = 0`, then `x = 0` or `y = 0`, and both sides are `0`: the left side by normality, and the right side because it is the empty sum.
∎

The result does not depend on how `x` and `y` are written as sums.
Normality is needed for the empty sum: without it, `f(0, y)` could be a non-zero constant that the sum on the right does not produce.

Often, most pairs of terms contribute nothing. If this is governed by a key, only pairs with matching keys need to be considered.

**Corollary (Keyed Evaluation).** Let `f` be as in *Pairwise Evaluation*, and let `k : X → K` and `k' : Y → K` be maps into a set `K` such that `f(xᵢ, yⱼ) = 0` whenever `k(xᵢ) ≠ k'(yⱼ)`. Then
```
f(x, y) = Σ_{k(xᵢ) = k'(yⱼ)} f(xᵢ, yⱼ)
```
*Proof.* By *Pairwise Evaluation*, dropping the pairs with different keys, which are `0`, by (2).
∎

If `K` is totally ordered, the pairs with matching keys can be found by sorting both sums by key and scanning them once, as in a sort-merge join, rather than checking all `m ⋅ n` pairs.

**Example.** In the powerset, `⋅` is additive and normal in each argument. For singletons, `{s} ⋅ {t} = 0` whenever `s ≠ t`, so with `k({s}) = s`, the intersection of two finite sets can be computed by sorting their elements and scanning both lists once.

### Multiplicative Maps

**Lemma (Basic Multiplicative Maps).** Constant maps, the identity, and the projections `πᵢ : Xⁿ → X` are multiplicative.

*Proof.* For a constant `c`, `c = c ⋅ c` by (8). The identity is immediate. For projections, `πᵢ(a ⋅ b) = aᵢ ⋅ bᵢ = πᵢ(a) ⋅ πᵢ(b)`, since `⋅` on `Xⁿ` is componentwise.
∎

**Lemma (Multiplicative Composition).** If `g : X → Y` and `h : Y → Z` are multiplicative, then so is `h ∘ g`.

*Proof.* `h(g(x ⋅ y)) = h(g(x) ⋅ g(y)) = h(g(x)) ⋅ h(g(y))`.
∎

**Lemma (Multiplicative Pairing).** For maps `g : X → Y` and `h : X → Z`, the map `x ↦ (g(x), h(x))` into `Y × Z` is multiplicative iff `g` and `h` are.

*Proof.* `⋅` on `Y × Z` is componentwise, so `(g(x ⋅ y), h(x ⋅ y)) = (g(x), h(x)) ⋅ (g(y), h(y))` holds iff it holds in each component.
∎

**Lemma (Multiplicative Products).** If `g, h : X → Y` are multiplicative, then so is `g ⋅ h`.

*Proof.*
```
g(x ⋅ y) ⋅ h(x ⋅ y) = g(x) ⋅ g(y) ⋅ h(x) ⋅ h(y)            (g, h multiplicative)
                    = (g(x) ⋅ h(x)) ⋅ (g(y) ⋅ h(y))        (5, 7)
```
∎

With a constant map for `h`, this shows in particular that `x ↦ c ⋅ g(x)` is multiplicative.

**Theorem (Cartesian Multiplicativity).** If `f : Xⁿ → Y` is multiplicative, then it is multiplicative in each argument. The converse does not hold.

*Proof.* Fix all arguments but the `i`-th. By (8), `(a₁, …, x, …, aₙ) ⋅ (a₁, …, y, …, aₙ) = (a₁, …, x ⋅ y, …, aₙ)`, so multiplicativity of `f` gives
```
f(a₁, …, x ⋅ y, …, aₙ) = f(a₁, …, x, …, aₙ) ⋅ f(a₁, …, y, …, aₙ)
```
For the converse, in the powerset of `{1}`, `+` is multiplicative in each argument by distributivity of `∪` over `∩`, but with `x = y' = {1}` and `x' = y = ∅`, we get `x ⋅ x' + y ⋅ y' = ∅`, while `(x + y) ⋅ (x' + y') = {1}`.
∎

**Lemma (Multiplicative Cross Terms).** If `g, h : X → Y` are multiplicative, then `g + h` is multiplicative iff `g(x) h(y) + h(x) g(y) ⊑ g(x) g(y) + h(x) h(y)` for all `x, y ∈ X`.

*Proof.*
```
(g(x) + h(x)) ⋅ (g(y) + h(y)) = g(x) g(y) + g(x) h(y) + h(x) g(y) + h(x) h(y)      (7, 9)
g(x ⋅ y) + h(x ⋅ y)           = g(x) g(y) + h(x) h(y)                              (g, h multiplicative)
```
so the two sides are equal iff `g(x) h(y) + h(x) g(y) ⊑ g(x) g(y) + h(x) h(y)`, by the definition of `⊑` and (1, 3).
∎

So additivity and multiplicativity are dual in this respect: sums of additive maps and products of multiplicative maps are always well behaved, while products of additive maps and sums of multiplicative maps produce cross terms.

### Homomorphisms

**Definition (Homomorphism).** A *homomorphism* is a map that is additive, multiplicative, normal and unital.
A homomorphism `A → A` is called an *endomorphism*.

For example, the projections `πᵢ : Xⁿ → X` are homomorphisms, the naming operations `a:` are endomorphisms of `Obs`, and the shift `[s, e) ↦ [s + 1, e + 1)` is an endomorphism of the half-open intervals over `ℤ ∪ {-∞, +∞}`.

**Corollary.** Every homomorphism is monotone, by *Additive implies Monotone*.

**Corollary.** Compositions of homomorphisms are homomorphisms, and `x ↦ (g(x), h(x))` is a homomorphism iff `g` and `h` are.

*Proof.* By *Additive Composition*, *Multiplicative Composition*, *Additive Pairing* and *Multiplicative Pairing*. Normality and unitality are preserved by composition, since `h(g(0)) = h(0) = 0` and likewise for `1`, and hold for a pairing iff they hold in each component, since `0` and `1` on `Y × Z` are componentwise.
∎


<!--

## Operations

Let `A` be an observation algebra.
An *n-ary operation* on `A` is a map `f : Aⁿ → A`.

For example, `+` and `⋅` are binary operations on every observation algebra, and every constant `c` is a 0-ary operation.
The naming operations `a:` of `Obs` are unary operations, as are complement `x ↦ S ∖ x` on the powerset `𝒫(S)`, and the shift `[s, e) ↦ [s + 1, e + 1)` on the half-open intervals over `ℤ ∪ {-∞, +∞}`, where `±∞ + 1 = ±∞`.

### Polynomials

Polynomials construct operations inductively from simpler ones.
Let `A` be an observation algebra, and let `Γ` be a set of operations `γ : Aᵏ → A` on `A`, each with its own number of arguments `k`.

A *`Γ`-polynomial over `A`* in the variables `x₁, …, xₙ` is an expression built from

- a variable `xᵢ`,
- a constant `c ∈ A`,
- `p + q` and `p ⋅ q` for polynomials `p` and `q`,
- `γ(p₁, …, p_k)` for `γ ∈ Γ` with `k` arguments and polynomials `p₁, …, p_k`.

We write
```
f : Aⁿ → A
f(x₁, …, xₙ) = p
```
for the operation that substitutes its arguments for the variables of `p` and evaluates the result in `A`, and call `f` the *operation induced by `p`*.
We often say and use *polynomial* when we technically mean the operation induced by it.
We write `p(x₁, …, xₙ)` for the value of `p` at `x₁, …, xₙ ∈ A`.

We use `≡` for syntactic identity: `p ≡ q` when `p` and `q` are the same polynomial expression.
We use `=` for equality in the algebra at hand: `x = y` when `x` and `y` denote the same element.
For polynomials, we write `p = q` to say that they induce the same operation.

### Monotone Polynomials

**Theorem (Monotone Polynomials).** If every `γ ∈ Γ` is monotone, then every `Γ`-polynomial is monotone.
*Proof.* Let `p` be a `Γ`-polynomial over `A` in the variables `x₁, …, xₙ`, and let `a, b ∈ Aⁿ` with `a ⊑ b`.
We show `p(a) ⊑ p(b)` by induction on `p`.

- If `p ≡ xᵢ`, then `p(a) = aᵢ ⊑ bᵢ = p(b)`.
- If `p ≡ c` for a constant `c`, then `p(a) = c = p(b)`.
- If `p ≡ q + r` or `p ≡ q ⋅ r`, then `q(a) ⊑ q(b)` and `r(a) ⊑ r(b)` by induction, so `p(a) ⊑ p(b)` by *Cartesian Monotonicity*, since `+` and `⋅` are monotone by *Sum and Product Monotonicity*.
- If `p ≡ γ(p₁, …, p_k)` for `γ ∈ Γ`, then `pᵢ(a) ⊑ pᵢ(b)` for each `i` by induction, so `p(a) ⊑ p(b)` by *Cartesian Monotonicity*, since `γ` is monotone.
∎


### Monomials

A *factor* is a variable, a constant, or `γ(p₁, …, p_k)` for `γ ∈ Γ` and polynomials `p₁, …, p_k`.
A *monomial* is a product of factors.
If `Γ = ∅`, a monomial is a product of variables and constants.

**Theorem (Distributive Form).** Every polynomial is equal to a sum `m₁ + ⋯ + mₖ` of monomials, with `k ≥ 1`.
This is also known as the *sum-of-products form*.

*Proof.* By induction on the polynomial.

- A factor is a monomial.
- For a sum, `(m₁ + ⋯ + mₖ) + (m'₁ + ⋯ + m'ₗ)` is a sum of monomials by (1).
- For a product, `(m₁ + ⋯ + mₖ)(m'₁ + ⋯ + m'ₗ)` is the sum of all `mᵢm'ⱼ` by (7, 9), and each `mᵢm'ⱼ` is a monomial.
∎

Since `0` is a constant, and hence a monomial, sums of monomials never need to be empty.

**Theorem (Additive Distributive Form).** Every polynomial is equal to a sum of monomials in which every operation that is additive in each argument is applied only to monomials.

*Proof.* As for *Distributive Form*, with one further case.
For `γ(p₁, …, p_k)`, write each `pᵢ` in this form, by induction.
If `γ` is not additive in each argument, `γ(p₁, …, p_k)` is a factor.
If it is, then by additivity in each argument, `γ(p₁, …, p_k)` is the sum of `γ(m₁, …, m_k)` over all choices of a monomial `mᵢ` from the sum for `pᵢ`, and each `γ(m₁, …, m_k)` is a factor.
∎

**Theorem (Multiplicative Distributive Form).** Every polynomial is equal to a sum of monomials in which, moreover, every operation that is additive and multiplicative in each argument is applied only to factors.

*Proof.* As for *Additive Distributive Form*, with one further step when `γ` is additive and multiplicative in each argument.
Each argument `mᵢ` is a product of factors, or the constant `1`, which is itself a factor.
By multiplicativity in each argument, `γ(m₁, …, m_k)` is the product of `γ(f₁, …, f_k)` over all choices of a factor `fᵢ` of `mᵢ`, which is a monomial.
∎

Neither normality nor unitality is needed: an operation applied to `0` or to `1` gives a constant, which is already a factor.
They are the empty cases of additivity and multiplicativity, as *Annihilation* is the empty case of *Distributivity*.

#### Distributive form over `Obs`

A *record* is a product of named variables `p:xᵢ` and named atoms `p:s`.

**Corollary (Distributive Form over `Obs`).** If `Γ` consists of the naming operations, every polynomial over `Obs` is equal to a sum of records, where the empty sum is `{}`.

*Proof.* Write each constant as an expression built from atoms, `{}` and `[]` by sums, products and naming.
The naming operations are additive and multiplicative, so by *Multiplicative Distributive Form*, the polynomial is a sum of monomials in which every name is applied only to a variable, an atom, `{}`, `[]`, or another name.
Nested names merge into one, `a₁:(⋯aⱼ:v⋯) = (a₁. ⋯ .aⱼ):v`, by Naming Associativity.
Names on `{}` and `[]` vanish, by Named Empty Sum and Named Empty Product, and unnamed variables and atoms are named by `ε`, by Naming Identity.
Finally, factors `[]` are dropped by Product Identity, and monomials containing `{}` are equal to `{}` by Product-Sum Annihilation and dropped by Sum Identity.
∎

With no variables, the corollary says that every element of `Obs` is a sum of products of named atoms, which replaces the *Names on Atoms* lemma.

-->
