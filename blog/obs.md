---
title: Observation Algebras
numbersections: true
toc: true
---


Philosophy
==========

**Observations**
: An observation is a reported piece of information about the world, and nothing more: two observations that carry the same information are the same observation.
Any further information about an observation, such as how often or when something was observed, counts as an observation in its own right.

**Joint Observations**
: Observations do not only come in isolation.
Observations that were made together, such as the fields of one record or the parts of one sensor reading, form a joint observation.
Observations that were made separately are independent.
Independent observations can be interpreted together but don't have to be, while the parts of a joint observation must always be considered together.

**Trivial Observations**
: Having no observation is different from having an observation that carries no information.
No observation means that no report was made: there is no witness, no record, no reading.
A trivial observation means that a report was made, but without any details.

**Completion Principle**
: A joint observation needs each one of its parts.
If a part consists of multiple independent observations, each such independent observation completes the joint observation on its own.
If a part was never reported, the joint observation can't be completed.

**Open World Principle**
: It is often not possible to know whether a set of observations is complete, so new observations must always be admissible.
In particular, not having some observation is not evidence against it.

**Safe Reasoning Principle**
: Since a set of observations is never known to be complete, a conclusion is only safe if new independent observations cannot invalidate it.


Observation Algebra
===================

We propose an algebraic structure to encode observations while adhering to the philosophy described earlier.
An element of the structure represents a collection of observations.

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
By the *Open World Principle*, new observations are always admissible, so any two collections of observations can be added.
Hence the observation algebra is closed under addition.
An observation is determined by its information alone (*Observations*), so it does not matter how independent observations are grouped (1), in which order they arrive (3), or whether one is repeated (4).
Adding no observation changes nothing (2), by *Trivial Observations*.
Since independent observations can be considered together and any two collections can be added, by extension any two collections can be multiplied.
A joint observation carries exactly the information of its parts, so by *Observations* it does not matter how its parts are grouped (5) or ordered (7), or whether a part is repeated (8).
A trivial part carries no information, so it does not change a joint observation (6), by *Trivial Observations*.
Distributivity and Annihilation follow from the *Completion Principle*.
If a part of a joint observation was reported independently as `b` and as `c`, each report completes the joint observation independently (9).
If a part was never reported, the joint observation cannot be completed (10).
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
_ Then `(D, +, ⋅, 0, 1)` is an observation algebra.
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
_ Then `(D, +, ⋅, 0, 1)` is an observation algebra.

**Example (Lineage).** Let `S` be a set of *sources*, and `⊥ ∉ 𝒫(S)` a separate element representing no observation.
An element is either `⊥`, or the set of sources that contributed to it. Let `D = 𝒫(S) ∪ {⊥}`, with `for a, b ⊆ S`
```
0 := ⊥     1 := ∅
a + b := a ∪ b             a ⋅ b := a ∪ b      
⊥ + a := a + ⊥ := a        ⊥ ⋅ a := a ⋅ ⊥ := ⊥
⊥ ⋅ ⊥ := ⊥ + ⊥ := ⊥
```
_ Then `(D, +, ⋅, 0, 1)` is an observation algebra.

Both independent and joint observations draw on the sources of all their parts.
The trivial observation `∅` involves no sources, which is different from not observing anything at all.

Unlike in a lattice, the product grows: `a ⊆ ab`.
Lineage records *which* sources contributed, but not *how*: it cannot distinguish independent from joint observations, since `+` and `⋅` coincide on sets.
It is not a lattice: `∅ + {s} = {s} ≠ ∅`.

This algebra is known as the *lineage semiring* in database provenance (Green, ICDT 2009).

**Example (Discrete).** Let `S` be a set of *values*, and `* ∉ S` a separate element representing an unspecified value. Let `D = 𝒫(S ∪ {*})`, with
```
0 := ∅     1 := {*}
a + b := a ∪ b
a ⋅ b := (a ∩ b) ∪ (a if * ∈ b) ∪ (b if * ∈ a)
```
_ Then `(D, +, ⋅, 0, 1)` is an observation algebra: it is the taxonomy refinement (see below) with root `*`, where every value refines `*` and no value refines another.

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

**Example (Taxonomy Refinement).** Let `(T, ≤)` be a *taxonomy*: a partial order with a root `*` such that `x ≤ *` for all `x ∈ T`, and in which the ancestors `{ y ∈ T | x ≤ y }` of any `x` form a chain.
Read `x ≤ y` as "`x` refines `y`", e.g. `Amsterdam ≤ Netherlands ≤ Europe`.
Two nodes are *compatible* if one refines the other, and then we write
```
x ∧ y := x    if x ≤ y
         y    if y ≤ x
```
_ Let `D = 𝒫(T)`, with
```
0 := ∅     1 := {*}
a + b := a ∪ b
a ⋅ b := { x ∧ y | x ∈ a, y ∈ b, x and y compatible }
```
_ Then `(D, +, ⋅, 0, 1)` is an observation algebra.

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

The structure that is freely generated by these operations forms the algebra `Obs`.

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

Every observation algebra carries an order that compares how much is observed: `a ⊆ b` when `b` already includes every observation in `a`.

**Definition (Information Ordering).** Let `D` be an observation algebra. Denote `a ⊆ b` iff `a + b = b`.

**Theorem.** `⊆` is a partial order on `D`, with least element `0`.
*Proof.*
Let `a, b, c ∈ D`.

- Reflexivity: `a + a = a` by idempotency (4), hence `a ⊆ a`.
- Transitivity: Assume `a ⊆ b` and `b ⊆ c`. Then
```
a + c = a + (b + c)    (b ⊆ c)
      = (a + b) + c    (1)
      = b + c          (a ⊆ b)
      = c              (b ⊆ c)
```
hence `a ⊆ c`.
- Antisymmetry: Assume `a ⊆ b` and `b ⊆ a`. Then
```
b = a + b    (a ⊆ b)
  = b + a    (3)
  = a        (b ⊆ a)
```
- Least element: `0 + a = a` by identity (2), hence `0 ⊆ a`.
∎

The unit `1` need not be the greatest element: in the taxonomy refinement, `{*} + {x} = {*, x} ≠ {*}` for `x ≠ *`.

**Theorem (Sum implies Product).** For all `a, b ∈ D`, `ab ⊆ a + b`.
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

**Definition.** The *join* `a ∪ b` is the least `c ∈ D` such that `a ⊆ c` and `b ⊆ c`.

**Theorem (Join is Sum).** For all `a, b ∈ D`, `a ∪ b = a + b`.
*Proof.*
`a + b` is an upper bound of `a` and `b`:
```
a + (a + b) = (a + a) + b    (1)
            = a + b          (4)

b + (a + b) = (a + b) + b    (3)
            = a + (b + b)    (1)
            = a + b          (4)
```
It is the least one: let `a ⊆ c` and `b ⊆ c`. Then
```
(a + b) + c = a + (b + c)    (1)
            = a + c          (b ⊆ c)
            = c              (a ⊆ c)
```
hence `a + b ⊆ c`.
∎

So `(D, ⊆)` is a join-semilattice with least element `0`, and `+` is its join.

**Theorem (Sum and Product Monotonicity).** For all `a, b, c ∈ D`, if `a ⊆ b`, then `a + c ⊆ b + c` and `ac ⊆ bc`.
*Proof.* Assume `a ⊆ b`. Then
```
(a + c) + (b + c) = (a + b) + (c + c)    (1, 3)
                  = b + c                (a ⊆ b, 4)
```
and
```
bc = cb          (7)
   = c(a + b)    (a ⊆ b)
   = ca + cb     (9)
   = ac + bc     (7)
```
∎

**Theorem (Closure).** Let `c ∈ D`. For all `a, b ∈ D`:

- if `a ⊆ c` and `b ⊆ c`, then `a + b ⊆ c` and `ab ⊆ c`,
- if `c ⊆ a` and `c ⊆ b`, then `c ⊆ a + b` and `c ⊆ ab`.

*Proof.*
Assume `a ⊆ c` and `b ⊆ c`.
Then `a + b ⊆ c`, since `a + b` is the least upper bound of `a` and `b` by Join is Sum.
Moreover `ab ⊆ a + b` by *Sum implies Product*, so `ab ⊆ c` by transitivity.

Assume `c ⊆ a` and `c ⊆ b`.
Since `a + b` is an upper bound of `a` by Join is Sum, `c ⊆ a ⊆ a + b`, so `c ⊆ a + b` by transitivity.
Moreover
```
c = cc    (8)
  ⊆ ac    (Product Monotonicity, c ⊆ a)
  = ca    (7)
  ⊆ ba    (Product Monotonicity, c ⊆ b)
  = ab    (7)
```
so `c ⊆ ab` by transitivity.
∎

**Definition.** The *meet* `a ∩ b`, if it exists, is the greatest `c ∈ D` such that `c ⊆ a` and `c ⊆ b`.
By antisymmetry, it is unique if it exists.

**Corollary.** `a ∩ b ⊆ ab` whenever `a ∩ b` exists, by Closure.

**Theorem.** For all `a, b ∈ D`, `ab = a ∩ b` iff `ab ⊆ a` and `ab ⊆ b`.
*Proof.*
(⟹) `a ∩ b` is a lower bound of `a` and `b` by definition.
(⟸) `ab` is a lower bound of `a` and `b`, and every lower bound `c` of `a` and `b` satisfies `c ⊆ ab` by Closure.
So `ab` is the greatest lower bound, and `ab = a ∩ b` by uniqueness.
∎

<!--
Maps and Polynomials
====================

## Cartesian Products

**Definition (Cartesian Product).** Let `X` and `Y` be observation algebras. The *Cartesian product* `X × Y` is the set of pairs `(x, y)` with `x ∈ X` and `y ∈ Y`, with
```
(x, y) + (x', y') := (x + x', y + y')      0 := (0, 0)
(x, y) ⋅ (x', y') := (x ⋅ x', y ⋅ y')      1 := (1, 1)
```
We write `Xⁿ` for the Cartesian product of `n` copies of `X`.

**Theorem.** `X × Y` is an observation algebra.
*Proof.* Each axiom holds componentwise, since it holds in `X` and in `Y`.
For example, `(x, y) ⋅ (0, 0) = (x ⋅ 0, y ⋅ 0) = (0, 0)` by (10).
∎

**Theorem.** The information ordering on `X × Y` is componentwise: `(x, y) ⊆ (x', y')` iff `x ⊆ x'` and `y ⊆ y'`.
*Proof.*
```
(x, y) ⊆ (x', y')  ⟺  (x + x', y + y') = (x', y')
                   ⟺  x + x' = x'  and  y + y' = y'
                   ⟺  x ⊆ x'  and  y ⊆ y'
```
∎

The *projections* `π₁ : X × Y → X` and `π₂ : X × Y → Y`, with `π₁(x, y) = x` and `π₂(x, y) = y`, are homomorphisms, since all operations are componentwise.

An element of `X × Y` is a pair of collections of observations, one in each algebra, kept side by side.
Note that `(x, 0)` is not `0`: it has observations in `X` and none in `Y`.

## Maps

We will study functions between observation algebras, which we call *maps*.
Let `X` and `Y` be observation algebras. A map `f : X → Y` is called

- *monotone* if `x ⊆ y` implies `f(x) ⊆ f(y)`,
- *additive* if `f(x + y) = f(x) + f(y)`,
- *multiplicative* if `f(x ⋅ y) = f(x) ⋅ f(y)`,
- *normal* if `f(0) = 0`,
- *unital* if `f(1) = 1`,

for all `x, y ∈ X`.
A map `f : Xⁿ → Y` of several arguments is a map from the Cartesian product.
For maps `g, h : X → Y` we write `g + h` and `g ⋅ h` for the operations `x ↦ g(x) + h(x)` and `x ↦ g(x) ⋅ h(x)`.

**Remark.**
Additivity does not imply normality: a constant map `f(x) = c` where `c ≠ 0` is additive by (4), but `f(0) = c`.
The operations `+` and `⋅` are monotone binary operations by *Sum and Product Monotonicity* and (3, 7).
The operation `+` is additive by (1, 3, 4), and `⋅` is additive by (7, 9), multiplicative by (5, 7, 8) and normal by (10).
The operation `+` is multiplicative only if `x + yz = (x + y)(x + z)`, which with `y = 0` gives `x = x(x + z)`. This fails in the taxonomy refinement: `{*} ⋅ ({*} + {x}) = {*, x} ≠ {*}` for `x ≠ *`.

**Theorem.** Every additive map is monotone.
*Proof.* Let `x ⊆ y`, so `x + y = y`. Then `f(y) = f(x + y) = f(x) + f(y)`, hence `f(x) ⊆ f(y)`.
For several arguments, change one argument at a time and use transitivity.
∎

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

We use `≡` for syntactic identity: `x ≡ y` when `x` and `y` are the same polynomial expression.
We use `=` for equality in the algebra at hand: `x = y` when `x` and `y` denote the same element.

We write
```
f : Aⁿ → A
f(x₁, …, xₙ) = p
```
_ for the operation that substitutes its arguments for the variables of `p` and evaluates the result in `A`, and call `f` the *operation induced by `p`*.
We often say and use *polynomial* when we technically mean the operation induced by it.
We write `p(x₁, …, xₙ)` for the value of `p` at `x₁, …, xₙ ∈ A`.

### Monomials

A *monomial* is a product of variables and constants.

**Theorem (Distributive Form):** Every `Γ`-polynomial that uses no operations from `Γ` is equal to a sum of monomials `m₁ + ⋯ + mₖ`, where the empty sum is `0`.
This is also known as the *sum-of-products form*.
*Proof.* By induction on the polynomial.

- A variable or a constant is a monomial.
- For a sum, `(m₁ + ⋯ + mₖ) + (m'₁ + ⋯ + m'ₗ)` is a sum of monomials by (1).
- For a product, `(m₁ + ⋯ + mₖ)(m'₁ + ⋯ + m'ₗ)` is the sum of all `mᵢm'ⱼ` by (7, 9), and each `mᵢm'ⱼ` is a monomial. If either sum is empty, the product is `0` by (7, 10).
∎

**Lemma (Names on Atoms).** Every `x ∈ Obs` can be written using only named atoms `p:s`, `{}`, `[]`, and sums and products thereof.
*Proof.* By induction on the construction of `x`.

- An atom `s` is the named atom `ε:s`, by Naming Identity.
- `{}` and `[]` need no rewriting, and products and sums follow by induction.
- For `a:x` push `a` inward:
```
a:{y, z} = {a:y, a:z}      (Named-Sum Distributivity)
a:[y, z] = [a:y, a:z]      (Named-Product Distributivity)
a:{}     = {}              (Named Empty Sum)
a:[]     = []              (Named Empty Product)
a:(p:s)  = (a.p):s         (Naming Associativity)
```
∎

A *record* is a product of named variables and named atoms in `Obs`.

**Theorem (Distributive Form over `Obs`).** If `Γ` consists of only the naming operations over `Attr`, every `Γ`-polynomial over `Obs` is a sum of records.


<!--


#### Monotone Polynomials

**Theorem (Monotone Polynomials):** If every `γ ∈ Γ` is monotone, then every polynomial operation is monotone.

*Proof.* Let `x ⊆ x'` in `Aⁿ`, ordered componentwise. We show `p(x) ⊆ p(x')` by induction on `p`.
For constants and variables this is immediate.
If `p(x) ⊆ p(x')` and `q(x) ⊆ q(x')`, then by *Sum and Product Monotonicity* and transitivity
```
p(x) + q(x) ⊆ p(x') + q(x) ⊆ p(x') + q(x')
p(x) ⋅ q(x) ⊆ p(x') ⋅ q(x) ⊆ p(x') ⋅ q(x')
```
and `γ(p₁(x), …, p_k(x)) ⊆ γ(p₁(x'), …, p_k(x'))` since `γ` is monotone.
∎

**Corollary:** If `f` is monotone, then `f(x) + f(y) ⊆ f(x + y)`.

*Proof.* `x ⊆ x + y` and `y ⊆ x + y`, so `f(x) ⊆ f(x + y)` and `f(y) ⊆ f(x + y)`, and `+` is the join.
∎

#### Additive operations

A unary operation `f : A → A` is *affine* if there are `c₀, c₁ ∈ A` such that `f(x) = c₀ + c₁x` for all `x ∈ A`.

**Lemma (Affine closure):** Constant operations and the identity are affine, and if `g` and `h` are affine, so are `g + h` and `g ⋅ h`.

*Proof.* A constant `c` is `c + 0 ⋅ x` by (2, 3, 7, 10), and the identity is `0 + 1 ⋅ x` by (2, 6).
Let `g(x) = c₀ + c₁x` and `h(x) = d₀ + d₁x`. Then
```
g(x) + h(x) = (c₀ + d₀) + (c₁ + d₁)x        (1, 3, 7, 9)
```
and
```
g(x) ⋅ h(x) = (c₀ + c₁x)(d₀ + d₁x)
            = c₀d₀ + c₀d₁x + c₁d₀x + c₁d₁xx        (5, 7, 9)
            = c₀d₀ + c₀d₁x + c₁d₀x + c₁d₁x         (8)
            = c₀d₀ + (c₀d₁ + c₁d₀ + c₁d₁)x         (1, 7, 9)
```
∎

**Lemma (Affine operations are additive):** Every affine operation is additive.

*Proof.* Let `f(x) = c₀ + c₁x`. Then
```
f(x + y) = c₀ + c₁(x + y)
         = c₀ + c₁x + c₁y                  (9)
         = (c₀ + c₁x) + (c₀ + c₁y)         (1, 3, 4)
         = f(x) + f(y)
```
∎

**Theorem (Additivity):** Let `g : A → A` be additive and `c ∈ A`. Then

1. `g + h` is additive for every additive `h`,
2. `x ↦ g(x) ⋅ c` is additive,
3. `x ↦ γ(c₁, …, g(x), …, c_k)` is additive for every additive operation `γ : Aᵏ → A` and all constants `cᵢ`.

*Proof.*
1.
```
g(x + y) + h(x + y) = g(x) + g(y) + h(x) + h(y)            (g, h additive)
                    = (g(x) + h(x)) + (g(y) + h(y))        (1, 3)
```
2.
```
g(x + y) ⋅ c = (g(x) + g(y)) ⋅ c        (g additive)
             = g(x) ⋅ c + g(y) ⋅ c      (7, 9)
```
3.
```
γ(c₁, …, g(x + y), …, c_k) = γ(c₁, …, g(x) + g(y), …, c_k)                          (g additive)
                           = γ(c₁, …, g(x), …, c_k) + γ(c₁, …, g(y), …, c_k)        (γ additive)
```
∎

The theorem does not cover `g ⋅ h` when neither factor is constant. The next lemma says exactly when such a product is additive.

**Lemma (Cross terms):** Let `g, h : A → A` be additive, and `f = g ⋅ h`. Then `f` is additive iff for all `x, y ∈ A`
```
g(x) h(y) + g(y) h(x) ⊆ f(x) + f(y)
```

*Proof.*
```
f(x + y) = (g(x) + g(y))(h(x) + h(y))                            (g, h additive)
         = g(x) h(x) + g(x) h(y) + g(y) h(x) + g(y) h(y)         (7, 9)
         = f(x) + f(y) + g(x) h(y) + g(y) h(x)                   (1, 3)
```
So `f(x + y) = f(x) + f(y)` iff `g(x) h(y) + g(y) h(x) ⊆ f(x) + f(y)`, by the definition of `⊆`.
∎

**Corollary:** If `g` is additive, then `g ⋅ g` is additive.

*Proof.* `g ⋅ g = g` by (8).
∎

**Example:** On the half-open intervals over `ℤ ∪ {-∞, +∞}`, the shift `σ` is additive, but `f(x) = x ⋅ σ(x)` is not.
For `x = [0, 1)` and `y = [1, 2)`,
```
f(x) = [0, 1) ∩ [1, 2) = ∅
f(y) = [1, 2) ∩ [2, 3) = ∅
f(x + y) = [0, 2) ∩ [1, 3) = [1, 2)
```
The cross term `y ⋅ σ(x) = [1, 2)` is not contained in `f(x) + f(y) = ∅`.

### Homomorphisms

**Definition:** A *homomorphism* is a map that is additive, multiplicative, normal and unital.
A homomorphism `A → A` is called an *endomorphism*.
For example, the naming operations `a:` of the `Obs` algebra, and the shift on the half-open intervals over `ℤ ∪ {-∞, +∞}`.

**Corollary:** Every homomorphism is monotone.

Homomorphisms preserve the structure of observation algebras, and therefore commute with polynomials.

#### Homomorphisms and polynomials

Let `X` and `Y` be observation algebras, and let `η : X → Y` be an additive and multiplicative map.
Let `Γ` be a set of operations on `X`, and assign to each `γ : Xᵏ → X` in `Γ` an operation `γ' : Yᵏ → Y` with the same number of arguments, such that `η` *respects* `γ`:
```
η(γ(x₁, …, x_k)) = γ'(η(x₁), …, η(x_k))    for all x₁, …, x_k ∈ X
```

For a polynomial `p` over `X`, the *image* `η[p]` is the polynomial over `Y` that replaces every constant `c` by `η(c)` and every `γ` by `γ'`:
```
η[xᵢ]               ≡ xᵢ
η[c]                ≡ η(c)
η[p + q]            ≡ η[p] + η[q]
η[p ⋅ q]            ≡ η[p] ⋅ η[q]
η[γ(p₁, …, p_k)]    ≡ γ'(η[p₁], …, η[p_k])
```

**Theorem (Homomorphisms commute with polynomials):** For every polynomial `p` in `x₁, …, xₙ` and all `x₁, …, xₙ ∈ X`:
```
η(p(x₁, …, xₙ)) = η[p](η(x₁), …, η(xₙ))
```

*Proof.* By induction on `p`. Write `x` for `x₁, …, xₙ` and `η(x)` for `η(x₁), …, η(xₙ)`.

- Variables: `η(xᵢ) = η[xᵢ](η(x))`.
- Constants: `η(c) = η[c](η(x))`, by the definition of `η[c]`.
- Sums:
```
η(p(x) + q(x)) = η(p(x)) + η(q(x))                (η additive)
               = η[p](η(x)) + η[q](η(x))          (induction)
               = η[p + q](η(x))
```
- Products:
```
η(p(x) ⋅ q(x)) = η(p(x)) ⋅ η(q(x))                (η multiplicative)
               = η[p](η(x)) ⋅ η[q](η(x))          (induction)
               = η[p ⋅ q](η(x))
```
- Operations from `Γ`:
```
η(γ(p₁(x), …, p_k(x))) = γ'(η(p₁(x)), …, η(p_k(x)))              (η respects γ)
                       = γ'(η[p₁](η(x)), …, η[p_k](η(x)))        (induction)
                       = η[γ(p₁, …, p_k)](η(x))
```
∎

The proof does not need `η` to be normal or unital: `0` and `1` are constants, and are mapped to `η(0)` and `η(1)`.
If `η` is a homomorphism, then `η[0] = 0` and `η[1] = 1`, so a polynomial without other constants, using only operations from `Γ` with `γ' = γ`, is its own image.

**Example:** The shift `σ` is an endomorphism of the half-open intervals over `ℤ ∪ {-∞, +∞}`. For `p(x) = x ⋅ [0, 5)`,
```
σ[p](y) = y ⋅ [1, 6)
```
so `σ(x ∩ [0, 5)) = σ(x) ∩ [1, 6)`: restricting and then shifting is the same as shifting and then restricting to the shifted range.

-->
