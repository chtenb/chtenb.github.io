---
toc-override: true
---

Category Theory
===============

This is an imprecise collection of notes about category theory, using an experimental notation that mixes the traditional set-theory oriented notation for functions with a more programming language oriented notation.

## Notation

- Objects are mapped using angled brackets, morphisms are mapped using parentheses

## Definitions

::: Definition :::
# Category
A **category** `𝓒` consists of the following components:

1. **Objects**: Denoted by uppercase letters, e.g., `A`, `B`, `C`. The set of all objects of `𝓒` is written `Obj(𝓒)`.
2. **Morphisms**: Also called *arrows*. Denoted by lowercase letters. A morphism `f` from object `A` to object `B` is written as `f: A → B`.  The set of all morphisms of `𝓒` is written `Mor(𝓒)` or `Hom(𝓒)`. Morphisms are also called **arrows**.
3. **Composition**: Given morphisms `f: A → B` and `g: B → C`, their composition is another morphism, denoted `g ∘ f: A → C`. The composition operator satisfies associativity, meaning for any morphism `h: C → D` it holds true that `(h ∘ g) ∘ f = h ∘ (g ∘ f)`. Alternatively, composition can be written using forward composition, `f ▹ g: A → C`.
4. **Identity morphism**: For each object `A`, there exists an identity morphism `id<A>` such that for any morphism `f: A → B`, we have `f ▹ id<B> = f = id<A> ▹ f`.
:::


::: Definition :::
# Homsets/Arrowsets
For two objects `A,B` in a category `𝓒`, the set of morphisms from `A` to `B` is called the homset, or arrowset, from `A` to `B`. We denote this set by `A→B`.
In other words, the notation `m ∈ A→B` is equivalent to `m: A → B`.
:::


::: Definition :::
# Inverses
Given a category `𝓒` and a morphism `f: A → B`. 

* Any morphism `g: B → A` is called a **pre-inverse** of `f` if and only if `g ▹ f = id<B>`.
* Any morphism `g: B → A` is called a **post-inverse** of `f` if and only if `f ▹ g = id<A>`.
* Any morphism `g: B → A` is called an **inverse** of `f` if and only if it is both a pre-inverse and a post-inverse to `f`.
:::

::: Definition :::
# Isomorphism
Given a category `𝓒`, a morphism `f: A → B` is called an **isomorphism** if there exists an inverse morphism to `f`.
:::

::: Definition :::
# Functor
A **functor** `F` from category `𝓒` to category `𝓓`, denoted `F: 𝓒 → 𝓓`, consists of two mappings:

1. **On Objects**: For each object `A` in `𝓒`, there is an object `F<A>` in `𝓓`.
2. **On Morphisms**: For each morphism `f: A → B` in `𝓒`, there is a morphism `F(f): F<A> → F<B>` in `𝓓` such that:
   - **Preserves Identity**: `F(id<A>) = id<F<A>>`.
   - **Preserves Composition**: For morphisms `f: A → B` and `g: B → C` in `C`, `F<g ∘ f> = F<g> ∘ F<f>`.


If `𝓒` and `𝓓` are the same category, `F` is called an **endofunctor**.
:::

::: Definition :::
# Natural Transformations
Natural transformations are denoted with greek letters.
Given functors `F, G: 𝓒 → 𝓓`, a natural transformation `η: F ⇒ G` assigns to each object `A` in `𝓒` a morphism `η<A>: F<A> → G<A>` in `𝓓` such that for every morphism `m: A → B` in `𝓒`, the following 
equation holds `η<A> ▹ G(m) = F(m) ▹ η<B>`.
This is often described visually as that this square 'commutes':
```
F<A> ---F(m)---> F<B>
 |                |
η<A>             η<B>
 |                |
 v                v
G<A> ---G(m)---> G<B>
```
If `η<A>` is an isomorphism in `𝓓` for every `A` in `𝓒`, `η` is called a *natural isomorphism*.
:::

::: Definition :::
# Product Category
Given two categories `𝓒` and `𝓓`, the product category `𝓒 ⨯ 𝓓` is defined as follows.

1. **Objects**: `Obj(𝓒⨯𝓓) = Obj(𝓒) ⨯ Obj(𝓓)`
2. **Morphisms**: For every two objects `(A,B)` and `(C,D)`,  `(A,B)→(C,D) = A→C ⨯ B→D`
3. **Composition**: For every two morphisms `(f,g)` and `(h,i)`,  `(f,g) ▹ (h,i) = (f ▹ h, g ▹ i)`
4. **Identity morphisms**: For every object `(A,B)`,  `id<A,B> = (id<A>, id<A>)`

This forms a category.

_Proof._

(Associativity) For any morphisms `(f, f')`, `(g, g')`, and `(h, h')` in `𝓒 ⨯ 𝓓`, 

```
((f, f') ▹ (g, g')) ▹ (h, h') = (f, f') ▹ ((g, g') ▹ (h, h')).
((f, f') ▹ (g, g')) ▹ (h, h') = (f ▹ g, f' ▹ g') ▹ (h, h')     (definition composition)
                              = ((f ▹ g) ▹ h, (f' ▹ g') ▹ h')  (definition composition)
(f, f') ▹ ((g, g') ▹ (h, h')) = (f ▹ (g ▹ h), f' ▹ (g' ▹ h'))  (definition composition)
                              = ((f ▹ g) ▹ h, (f' ▹ g') ▹ h')  (associativity composition)
```

(Identity) For any object `(A, B)` in `𝓒 ⨯ 𝓓` and any morphism `(f, f')` coming into `(A, B)` and any morphism `(g, g')` going out of `(A, B)`,


```
(f, f') ▹ id<A,B> = (f, f') ▹ (id<A>, id<B>) = (f ▹ id<A>, f' ▹ id<B>) = (f, f')
id<A,B> ▹ (g, g') = (id<A>, id<B>) ▹ (g, g') = (id<A> ▹ g, id<B> ▹ g') = (g, g')
```
∎
:::

::: Definition :::
# Bifunctor
Given three categories `𝓒`, `𝓓` and `𝓔`, a functor `F: 𝓒 ⨯ 𝓓 → 𝓔` is called a *bifunctor*.
:::

::: Definition :::
# Dual Category or Opposite Category
Every category `𝓒` has an opposite category, denoted `𝓒⁻`, which has the same objects as `𝓒`, but has the arrows reversed.

1. **Objects**: every object `A` in `𝓒⁻` is an object in `𝓒`
2. **Morphisms**: a morphism `f⁻: A → B` in `𝓒⁻` is a morphism `f: B → A` in `𝓒`. Composition `▹⁻` between `f⁻` and `g⁻: B → C` is defined `f⁻ ▹⁻ g⁻ = (g▹f)⁻`.
:::

::: Definition :::
# Contravariant Functor
Given categories `𝓒` and `𝓓`, a functor `F: 𝓒⁻ → 𝓓` is called a *contravariant functor*.
:::

::: Definition :::
# Covariant Homfunctor
For a fixed object `A` in a category `𝓒`, the covariant Homfunctor (or covariant arrow functor) on `A`, `A→: 𝓒 → Set`, is defined as follows.

1. **On Objects**: For each object `B` in `𝓒`, `A→<B> = A→B`.
2. **On Morphisms**: Each morphism `f: B → C` in `𝓒`, is mapped to a function between homsets `A→(f): (A→B) → (A→C)`, `m ↦ m ▹ f`.
:::

::: Definition :::
# Contravariant Homfunctor
For a fixed object `A` in a category `𝓒`, the contravariant Homfunctor (or contravariant arrow functor) on `A`, `→A: 𝓒 → Set`, is defined as follows.

1. **On Objects**: For each object `B` in `𝓒`, `→A<B> = B→A`.
2. **On Morphisms**: Each morphism `f: B → C` in `𝓒`, is mapped to a function between homsets `A→(f): (C→A) → (B→A)`, `m ↦ f ▹ m`.
:::

::: Definition :::
# Homfunctor
For a category `𝓒`, it's Homfunctor (or *arrow functor*) `→: 𝓒⁻ × 𝓒 → Set` is defined as follows.

1. **On Objects**: For each object `<A₁,A₂>` in `𝓒⁻ × 𝓒`, `→<A₁,A₂> = A₁→A₂`.
2. **On Morphisms**: Each morphism `(f₁⁻,f₂): <A₁,A₂> → <B₁,B₂>` in `𝓒⁻ × 𝓒`, is mapped to a function between homsets,  `→(f₁⁻,f₂): (A₁→A₂) → (B₁→B₂)`, `m ↦ f₁ ▹ m ▹ f₂`.

_Proof._
```
i) Prove that →(id<A₁,A₂>) = id(→<A₁,A₂>).

→(id<A₁,A₂>) 
 = →(id<A₁>,id<A₂>)                         (def prod cat)
 = (m: A₁ → A₂) ↦ id<A₁> ▹ m ▹ id<A₂>     (def hom functor)
 = (m: A₁ → A₂) ↦ m                        (def id)
 = id<A₁→A₂>                                (def id in Set)
 = id(→<A₁,A₂>)                             (def hom functor)

ii) Let (f₁⁻,f₂) : <A₁,A₂> → <B₁,B₂> and (g₁⁻,g₂) : <B₁,B₂> → <C₁,C₂> two morphisms in C⁻ × C. Prove that →((f₁⁻,f₂) ▹ (g₁⁻,g₂)) = →(f₁⁻,f₂) ▹ →(g₁⁻,g₂).

→((f₁⁻,f₂) ▹ (g₁⁻,g₂)) 
 = →(f₁⁻▹⁻g₁⁻, f₂▹g₂)                                  (def prod cat)
 = →((g₁▹f₁)⁻, f₂▹g₂)                                  (def op cat)
 = (m:A₁→A₂) ↦ (g₁ ▹ f₁) ▹ m ▹ (f₂ ▹ g₂)             (def hom functor)
 = (m:A₁→A₂) ↦ g₁ ▹ (f₁ ▹ m ▹ f₂) ▹ g₂               (assoc)
 = (m:A₁→A₂) ↦ g₁ ▹ (n ↦ f₁ ▹ n ▹ f₂)(m) ▹ g₂       (eta expansion)
 = (m:A₁→A₂) ↦ g₁ ▹ →(f₁⁻,f₂)(m) ▹ g₂                 (def hom functor)
 = (m:A₁→A₂) ↦ (n ↦ g₁ ▹ n ▹ g₂)(→(f₁⁻,f₂)(m))        (eta expansion)
 = (m:A₁→A₂) ↦ (→(f₁⁻,f₂) ▹ (n ↦ g₁ ▹ n ▹ g₂))(m)    (def function composition)
 = (m:A₁→A₂) ↦ (→(f₁⁻,f₂) ▹ →(g₁⁻,g₂))(m)              (def hom functor)
 = →(f₁⁻,f₂) ▹ →(g₁⁻,g₂)                                (eta reduction)
```
∎
:::

::: Definition :::
# Product and Coproduct
A **product** of two objects `A` and `B` is the object `C` equipped with two morphisms (called projections) `p: C → A` and `q: C → B` 
such that for any other object `C'` equipped with two projections `p': C' → A` and `q': C' → B` there is a unique morphism `m: C' → C` that factorizes those projections: 

```
 p' = m ▹ p
 q' = m ▹ q
```

Dually, a **coproduct** of two objects `A` and `B` is the object `C` equipped with two morphisms (called injections) `i: A → C` and `j: B → C` 
such that for any other object `C'` equipped with two injections `i': A → C'` and `j': B → C'` there is a unique morphism `m: C → C'` that factorizes those injections: 

```
 i' = i ▹ m
 j' = j ▹ m
```
:::

::: Definition :::
# Left and Right Adjoint Functors
Let `L: 𝓒 → 𝓓`, `R: 𝓓 → 𝓒` functors such that for all `A` in `𝓒` there is a natural isomorphism between `R ▹ A→ : 𝓓 → Set` and  `L<A>→ : 𝓓 → Set`
and for all `B` in `𝓓` there is a natural isomorphism between `L ▹ →B : 𝓒 → Set` and `→R<B> : 𝓒 → Set`.
Then `L` is called the left-adjoint of `R`, and `R` is called the right-adjoint of `L`.
:::


## Examples

::: Example :::
# The Monoid Category 
A monoid `M` is characterized by a set of values `M`, an identity value `0` and an operator `+ : M → M → M`, such that the following conditions are met.

1. (Associativity) For every three values `x, y` and `z` in `M`,  `(x + y) + z = x + (y + z)`.
2. (Identity) For every value `x` in `M`,  `x + 0 = x`  and  `0 + x = x`.

This structure forms a category with one object, named `1`, and a morphism `x: 1 → 1` for every value `x` in `M`.
Composition is defined as  `x ∘ y = x + y`.

_Proof._

(Associativity) To prove: for any morphisms `x, y`, and `z`,  `(x ∘ y) ∘ z = x ∘ (y ∘ z)`.

```
 (x ∘ y) ∘ z  = x + y ∘ z   = (x + y) + z   (definition composition)
 x ∘ (y ∘ z)  = x ∘ (y + z) = x + (y + z)   (definition composition)
                            = (x + y) + z   (associativity of +)
```

(Identity) To prove: for any morphism `x`,  `x ∘ 0 = x`  and  `0 ∘ x = x`.

```
 x ∘ 0  = x + 0  (definition composition)
        = x      (definition monoid identity)
 0 ∘ x  = 0 + x  (definition composition)
        = x      (definition monoid identity)
```
∎

:::

::: Example :::
# The Category of Categories
The category *Cat* where objects are categories and morphisms are functors between categories, is a category.
Functors `F` and `G` are composable by composing the corresponding functions:

```
 (G ▹ F)<A> = F<G<A>>
 (G ▹ F)(m) = F(G(m))
```

Every category `𝓒` has an identity functor `I` to itself, which is given by

```
 I: Obj(𝓒) → Obj(𝓒), I<A> = A
 I: Mor(𝓒) → Mor(𝓒), I(m) = m
```

_Proof._

(Associativity) Composing functors is associative, because composing the underlying functions is associative.
(Identity) For any object `𝓒` in Obj(Cat) and any functor `F` going out of `𝓒` and any functor `G` coming into `𝓒`, let `I` be the identity functor of `𝓒`. Then

```
 F ∘ I = F 
 I ∘ G = G
```

because the underlying functions of `I` are identity functions.
∎
:::


::: Example :::
# The Set Category
The category *Set* is the category where objects are sets and morphisms are functions between sets.
When programming with total (non-throwing, terminating) functions, this is the category you operate in.
Types can be seen as the set of all possible values they hold, and functions map types to other types.
For example, `Bool` and `Int` are objects, and `isOdd : Int → Bool` is a morphism.
:::

::: Example :::
# The Product Functor in Set
The type constructor

```
 Pair: Set ⨯ Set → Set
 Pair<A,B> = Pair(A,B)
```

forms a bifunctor under

```
 Pair(f,g) Pair(x,y) = Pair(f(x),g(y))
```
_Proof._
TODO
:::

::: Example :::
# The Sum Functor in Set
The type constructor

```
 Either: Set ⨯ Set → Set
 Either<A,B> = Left(A) | Right(B)
```

forms a bifunctor under

```
 Either(f,g) Left(x) = Left(f(x))
 Either(f,g) Right(y) = Right(g(y))
```

_Proof._
TODO
:::

::: Example :::
# The List Functor

The *List* type constructor forms an endofunctor in the category Set.

```
 List : Set → Set
 List<A> = Nil | Cons(A, List<A>)
 List : (A → B) → (List<A> → List<B>)
 List(f) = Nil ↦ Nil                                 
         | Cons(x, xs) ↦ Cons(f(x), List(f)(xs))
```

_Proof._

(Associativity) To prove: For any morphisms `f: A → B` and `g: B → C`, `List(f ▹ g) = List(f) ▹ List(g)`.
We prove that these two expressions are the same for all possible inputs, namely `Nil` and `Cons(x,xs)`.

Case `Nil`:
```
List(f ▹ g)(Nil) = Nil                           (List functor definition on Nil)
(List(f) ▹ List(g))(Nil) = List(g)(List(f)(Nil)) (Definition composition)
                         = List(g)(Nil)          (List functor definition on Nil)
                         = Nil                   (List functor definition on Nil)
```
Both expressions evaluate to `Nil`.

Case `Cons(x, xs)`:
```
List(f ▹ g)(Cons(x, xs)) = Cons((f ▹ g)(x), List(f ▹ g)(xs))     (List functor definition on Cons)
                         = Cons(g(f(x)), List(f ▹ g)(xs)))       (Definition composition)

(List(f) ▹ List(g))(Cons(x, xs)) = List(g)(List(f)(Cons(x, xs)))             (Definition composition)
                                 = List(g)(Cons(f(x), List(f)(xs)))          (List functor definition on Cons)
                                 = Cons(g(f(x)), List(g)(List(f)(xs)))       (List functor definition on Cons)
                                 = Cons(g(f(x)), (List(f) ▹ List(g))(xs))    (Definition composition)
                                 = Cons(g(f(x)), (List(f ▹ g))(xs))          (Induction)
```
Both expressions simplify to `Cons(g(f(x)), (List(f ▹ g))(xs))`.

(Identity) To prove: For any object `A` in Set, `List(id<A>) = id<List<A>>`.

Case `Nil`:
```
id<List<A>>(Nil) = Nil          (Identity function on List<A>)
List(id<A>)(Nil) = Nil          (List functor definition on Nil)
```

Case `Cons(x, xs)`:
```
id<List<A>>(Cons(x, xs)) = Cons(x, xs)                      (Identity definition on List<A>)
List(id<A>)(Cons(x, xs)) = Cons(id<A>(x), List(id<A>)(xs))  (List functor definition on Cons)
                         = Cons(x, List(id<A>)(xs))         (Identity morphism definition)
                         = Cons(x, id<List<A>>(xs))         (Induction)
                         = Cons(x, xs)                      (Identity definition on List<A>)
```
Both expressions simplify to `Cons(x, xs)`.
∎
:::

::: Example :::
# Haskell Functor

Any Haskell type constructor `F` that has an instance of the [Haskell Functor class](https://wiki.haskell.org/Functor) forms an endofunctor in Set (ignoring exceptions and non-termination).

_Proof._

We are given a type constructor `F` with one argument, and a function `fmap : (a → b) → (F a → F b)`,
where fmap obeys the following laws:

```
 fmap id = id
 fmap (f ∘ g) = fmap f ∘ fmap g
```

This gives us

```
 F : Obj(Set) → Obj(Set)
 F<A> = F A
 F : Mor(Set) → Mor(Set)
 F(f) = fmap f
```

(Associativity) To prove: for any two morphisms `f` and `g` in Set, `F(f ∘ g) = F(f) ∘ F(g)`.

```
 F(f ∘ g) = fmap (f ∘ g)    (definition F)
          = fmap f ∘ fmap g (Haskell Functor Law)
          = F(f) ∘ F(g)     (definition F)
```

(Identity) To prove: for any object `A` in Set, `F(id<A>) = id<F<A>>`.

```
 id<F<A>> = id          (definition Haskell id)
 F(id<A>) = fmap id<A>  (definition F)
          = fmap id     (definition Haskell id)
          = id          (Haskell Functor Law)
```
:::


<!--
::: Example :::
# The PreList Bifunctor
The PreList type constructor given below forms a bifunctor from FP ⨯ FP to FP.

 PreList : Obj~FP~ → Obj~FP~ → Obj~FP~
 PreList a b = Nil | Cons a b

_Proof._

Note that by uncurrying we have

 PreList : Obj~FP⨯FP~ → Obj~FP~.

which gives us the required object mapping.
Furthermore, define map~PreList~ : Mor~FP⨯FP~ → Mor~FP~ as

 map~PreList~ (f, g) Nil = Nil
 map~PreList~ (f, g) (Cons a b) = Cons (f a) (g b)

[lowerroman]
. To prove: for any two morphisms f and g in Mor~FP⨯FP~,  map~PreList~ (f ∘ g) = map~PreList~ f ∘ map~PreList~ g.

[{eqtable}]
|#
| map (f ∘ g) Nil     | = Nil                | (definition map~PreList~)
| (map f ∘ map g) Nil | = map f (map g Nil)  | (definition composition)
|                     | = map f Nil          | (definition map~PreList~)
|                     | = Nil                | (definition map~PreList~)
|#

[{eqtable}]
|#
| map ((f, f') ∘ (g, g')) (Cons x y)    | = map (f ∘ g, f' ∘ g') (Cons x y)      | (definition product category)
|                                        | = Cons ((f ∘ g) x) ((f' ∘ g') y)       | (definition map~PreList~)
|                                        | = Cons (f (g x)) (f' (g' y))           | (definition composition)
|                                        |                                        |
| (map (f, f') ∘ map (g, g')) (Cons x y) | = map (f, f') (map (g, g') (Cons x y)) | (definition composition)
|                                        | = map (f, f') (Cons (g x) (g' y))      | (definition map~PreList~)
|                                        | = Cons (f (g x)) (f' (g' y))           | (definition map~PreList~)
|#

[lowerroman,start=2]
. To prove: for any object (a, b) in Obj~FP⨯FP~,  map~PreList~ id~(a,b)~ = id~PreList (a,b)~.

[{eqtable}]
|#
| map id Nil        | = Nil                 | (definition map~PreList~)
| map id (Cons x y) | = Cons (id x) (id y)  | (definition map~PreList~)
|                   | = Cons x y            | (definition id)
|#

∎
:::
-->


