---
title:  Category Theory
...

This is an imprecise collection of notes about category theory, using an experimental notation that mixes the traditional set-theory oriented notation for functions with a more programming language oriented notation.

## Notation

- Objects are mapped using angled brackets, morphisms are mapped using parentheses

## Definitions

::: Definition :::
# Category
A **category** `𝓒` consists of the following components:

1. **Objects**: Denoted by uppercase letters, e.g., `A`, `B`, `C`. The set of all objects of `𝓒` is written `Obj(𝓒)`.
2. **Morphisms**: Denoted by lowercase letters. A morphism `f` from object `A` to object `B` is written as `f: A → B`.  The set of all morphisms of `𝓒` is written `Mor(𝓒)` or `Hom(𝓒)`. Morphisms are also called **arrows**.
3. **Composition**: Given morphisms `f: A → B` and `g: B → C`, their composition is another morphism, denoted `g ∘ f: A → C`. The composition operator satisfies associativity, meaning for any morphism `h: C → D` it holds true that `(h ∘ g) ∘ f = h ∘ (g ∘ f)`. Alternatively, composition can be written using forward composition, `f ▹ g: A → C`.
4. **Identity morphism**: For each object `A`, there exists an identity morphism `id<A>` such that for any morphism `f: A → B`, we have `f ▹ id<B> = f = id<A> ▹ f`.
:::


::: Definition :::
# Homset
For two objects `A,B` in a category `𝓒`, the set of morphisms from `A` to `B` is called the homset (or arrowset) from `A` to `B`. We denote this set by `A→B`.
In other words, the following two ways of denoting a morphism are equivalent: `m ∈ A→B  ≡  m: A → B`.
:::

::: Definition :::
# Isomorphism
Given a category `𝓒`, a morphism `f: A → B` is called an **isomorphism** if there exists another morphism `g: B → A` such that

```
 f ▹ g = id<A>
 g ▹ f = id<B>
```

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
Given functors `F, G: 𝓒 → 𝓓`, a natural transformation `η: F ⇒ G` assigns to each object `A` in `𝓒` a morphism `η<A>: F<A> → G<A>` in `𝓓` such that for every morphism `m: A → B` in `𝓒`, the following 
equation holds: `η<A> ▹ G(m) = F(m) ▹ η<B>`.
This is often described visually as that this square 'commutes':
```
F<A> ---F(m)---> F<B>
 |                |
η<A>             η<B>
 |                |
 v                v
G<A> ---G(m)---> G<B>
```

Natural transformations are denoted with greek letters.
:::

::: Definition :::
# Product and Coproduct
A **product** of two objects A and B is the object C equipped with two morphisms (called projections) p: C → A and q: C → B 
such that for any other object C' equipped with two projections p': C' → A and q': C' → B there is a unique morphism m: C' → C that factorizes those projections: 

 p' = p ∘ m
 q' = q ∘ m

Dually, a **coproduct** of two objects A and B is the object C equipped with two morphisms (called injections) i: A → C and j: B → C 
such that for any other object C' equipped with two injections i': A → C' and j': B → C' there is a unique morphism m: C → C' that factorizes those injections: 

 i' = m ∘ i
 j' = m ∘ j
:::

::: Definition :::
# Product Category
Given two categories `𝓒` and `𝓓`, the product category `𝓒 ⨯ 𝓓` is defined as follows.

* **Objects**: `Obj(𝓒⨯𝓓) = Obj(𝓒) ⨯ Obj(𝓓)`
* **Morphisms**: For every two objects (A,B) and (C,D),  `(A,B)→(C,D) = A→C ⨯ B→D`
* **Composition**: For every two morphisms (f,g) and (h,i),  `(f,g) ▹ (h,i) = (f ▹ h, g ▹ i)`
* **Identity morphisms**: For every object (A,B),  `id<A,B> = (id<A>, id<A>)`

This forms a category.

_Proof._

. (Associativity) For any morphisms (f, f'), (g, g'), and (h, h') in 𝓒 ⨯ 𝓓, 

```
((f, f') ▹ (g, g')) ▹ (h, h') = (f, f') ▹ ((g, g') ▹ (h, h')).
((f, f') ▹ (g, g')) ▹ (h, h') = (f ▹ g, f' ▹ g') ▹ (h, h')     (definition composition)
                              = ((f ▹ g) ▹ h, (f' ▹ g') ▹ h')  (definition composition)
(f, f') ▹ ((g, g') ▹ (h, h')) = (f ▹ (g ▹ h), f' ▹ (g' ▹ h'))  (definition composition)
                              = ((f ▹ g) ▹ h, (f' ▹ g') ▹ h')  (associativity composition)
```

. (Identity) For any object (A, B) in 𝓒 ⨯ 𝓓 and any morphism (f, f') coming into (A, B) and any morphism (g, g') going out of (A, B),


```
(f, f') ▹ id<A,B> = (f, f') ▹ (id<A>, id<B>) = (f ▹ id<A>, f' ▹ id<B>) = (f, f')
id<A,B> ▹ (g, g') = (id<A>, id<B>) ▹ (g, g') = (id<A> ▹ g, id<B> ▹ g') = (g, g')
```
:::

::: Definition :::
# Bifunctor
Given three categories 𝓒, 𝓓 and 𝓔, a functor F: 𝓒 ⨯ 𝓓 → 𝓔 is called a *bifunctor*.
:::

::: Definition :::
# Dual Category or Opposite Category
Every category 𝓒 has an opposite category, denoted 𝓒⁻, which has the same objects as 𝓒, but has the arrows reversed.

1. **Objects**: every object A in 𝓒⁻ is an object in 𝓒
2. **Morphisms**: a morphism `f⁻: A → B` in 𝓒⁻ is a morphism `f: B → A` in 𝓒. Composition `▹⁻` between `f⁻` and `g⁻: B → C` is defined `f⁻ ▹⁻ g⁻ = (g▹f)⁻`.
:::


::: Definition :::
# Contravariant Functor
Given categories C and D, a functor F: C⁻ → D is called a *contravariant functor*.
:::

::: Definition :::
# Profunctor
Given categories C and D, a functor F: C⁻ ⨯ D → Set is called a *profunctor*.
:::

## Examples

::: Definition :::
# The Monoid Category 
A monoid M is characterized by a set of values M, an identity value 0 and an operator + : M → M → M, such that the following conditions are met.

* (Associativity) For every three values x, y and x in M,  (x + y) + z = x + (y + z).
* (Identity) For every value x in M,  x + 0 = x  and  0 + x = x.

This structure forms a category with one object, named 1, and a morphism x: 1 → 1 for every value x in M.
Composition is defined as  x ∘ y = x+y.

_Proof._

* (Associativity) To prove: for any morphisms x, y, and z in Mor,  (x ∘ y) ∘ z = x ∘ (y ∘ z).

```
 (x ∘ y) ∘ z  = x+y ∘ z   = (x+y)+z   (definition composition)
 x ∘ (y ∘ z)  = x ∘ (y+z) = x+(y+z)   (definition composition)
                          = (x+y)+z   (associativity of +)
```

* (Identity) To prove: for any morphism x in Mor,  x ∘ 0 = x  and  0 ∘ x = x.

```
 x ∘ 0  = x+0  (definition composition)
        = x    (definition monoid identity)
 0 ∘ x  = 0+x  (definition composition)
        = x    (definition monoid identity)
```

:::

[#ex-cat]
# The Category of Categories
The category *Cat* where objects are categories and morphisms are functors between categories, is a category.
Functors F and G are composable by composing the corresponding functions:

 (F ∘ G) a = F (G a)
 (map~F~ ∘ map~G~) f = map~F~ (map~G~ f)

Every category C has an identity functor I to itself, which is given by

 I: Obj~C~ → Obj~C~, I a = a
 map~I~: Mor~C~ → Mor~C~, map~I~ f = f

_Proof._

[lowerroman]
. (Associativity) Composing functors is associative, because composing the underlying functions is associative.
. (Identity) For any object C in Obj~Cat~ and any functor F going out of C and any functor G coming into a, let I be the identity functor of C. Then

 F ∘ I = F 
 I ∘ G = G

because the underlying functions of I are identity functions.


[#ex-set]
# The Set Category
The category *Set* is the category where objects are sets and morphisms are functions between sets.


[#ex-fp]
# The FP Category

The category *FP*, with objects being types and morphisms being functions, forms a category.

Composition of two functions f and g in Mor~FP~ is defined as  (f ∘ g) x = f (g x).

For any object a in Obj~FP~, id~a~ is defined as the function  id~a~ x = x.

Because the definition of id~a~ is independent of a, we usually abbreviate this function to simply id when dealing with the FP category.

_Proof._

To prove the equivalence of two functions, it suffices to show that they yield the same output for the same input.

[lowerroman]
. (Associativity) To prove: for any morphisms f, g, and h in Mor~FP~,  (f ∘ g) ∘ h = f ∘ (g ∘ h).

[{eqtable}] 
|#
| ((f ∘ g) ∘ h) x  | = (f ∘ g) (h x)   | (definition composition)
|                  | = f (g (h x))     | (definition composition)
|#

[{eqtable}] 
|#
| (f ∘ (g ∘ h)) x  | = f ∘ (g (h x))   | (definition composition)
|                  | = f (g (h x))     | (definition composition)
|#

[lowerroman,start=2]
. (Identity) To prove: for any object a in Obj~FP~ and any morphism f going out of a,  f ∘ id~a~ = f 
   and any morphism g coming into a  id~a~ ∘ g = g.

[{eqtable}] 
|#
| (f ∘ id~a~) x  | = f (id~a~ x)  | (definition composition)
|                | = f x          | (definition id~a~)
|                |                |
|(id~a~ ∘ g) x   | = id~a~ (g x)  | (definition composition)
|                | = g x          | (definition id~a~)
|#

∎

[#ex-List-functor]
# The List Functor

The *List* type constructor forms an endofunctor in the category FP.

[{eqtable}]
|#
| List : Obj~FP~ → Obj~FP~                              |
| List a = Nil \| Cons a (List a)                       |
| map~List~ : Mor~FP~ → Mor~FP~                         | Or, specialized to FP,  map~List~ : (a → b) → (List a → List b)
| map~List~ f Nil = Nil                                 |
| map~List~ f (Cons x xs) = Cons (f x) (map~List~ f xs) |
|#

_Proof._

[lowerroman]
. To prove: for any two morphisms f and g in Mor~FP~,  map~List~ (f ∘ g) = map~List~ f ∘ map~List~ g.

We prove that these two expressions are the same for all possible inputs, namely Nil and Cons x xs.

[{eqtable}]
|#
| map~List~ (f ∘ g) Nil            | = Nil                            |
|                                  |                                  |
| (map~List~ f ∘ map~List~ g) Nil  | = map~List~ f (map~List~ g Nil)  | (definition composition)
|                                  | = map~List~ f Nil                | (definition map~List~)
|                                  | = Nil                            | (definition map~List~)
|#
  
[{eqtable}]
|#
| map~List~ (f ∘ g) (Cons x xs)           | = Cons ((f ∘ g) x) (map~List~ (f ∘ g) xs)            | (definition map~List~)
|                                         |                                                      |
| (map~List~ f ∘ map~List~ g) (Cons x xs) | = map~List~ f (map~List~ g (Cons x xs))              | (definition composition)
|                                         | = map~List~ f (Cons (g x) (map~List~ g xs))          | (definition map~List~)
|                                         | = Cons (f (g x)) (map~List~ f (map~List~ g xs))      | (definition map~List~)
|                                         | = Cons ((f ∘ g) x) ((map~List~ f ∘ map~List~ g) xs)  | (definition composition)
|#

All we have left to prove is that map~List~ (f ∘ g) xs = (map~List~ f ∘ map~List~ g) xs.
Because it is true for xs = Nil, it follows by induction that the statement is true for all xs.

[lowerroman,start=2]
. To prove: for any object a in Obj~FP~,  map~List~ id~a~ = id~List a~. 

We prove that these two expressions are the same for all possible inputs, namely Nil and Cons x xs.

[{eqtable}]
|#
| map~List~ id~a~ Nil = Nil  | (definition map~List~)
|                            |
| id~List a~ Nil = Nil       | (definition id~List a~)
|#

[{eqtable}]
|#
| map~List~ id~a~ (Cons x xs)  | = Cons (id~a~ x) (map~List~ id~a~ xs)  | (definition map~List~)
|                              | = Cons x (map~List~ id~a~ xs)          | (definition id~a~)
|                              |                                        |
| id~List a~ (Cons x xs)       | = Cons x xs                            | (definition id~List a~)
|#

All we have left to prove is that map~List~ id~a~ xs = xs.
Because it is true for xs = Nil, it follows by induction that the statement is true for all xs.

∎

[#ex-haskell-functor]
# Haskell Functor

Any Haskell type constructor F that has an instance of the link:https://wiki.haskell.org/Functor[Haskell Functor class] forms an endofunctor in FP.

_Proof._

We are given a type constructor F with one argument, and a function  fmap : (a → b) → (F a → F b),
where fmap obeys the following laws:

 fmap id = id
 fmap (f ∘ g) = fmap f ∘ fmap g

This gives us

[{eqtable}]
|#
| F : Obj~FP~ → Obj~FP~       | 
| map~F~ : Mor~FP~ → Mor~FP~  | 
| map~F~  = fmap              |
|#


[lowerroman]
. To prove: for any two morphisms f and g in Mor~FP~,  map~F~ (f ∘ g) = map~F~ f ∘ map~F~ g.

[{eqtable}]
|#
| map~F~ (f ∘ g) | = fmap (f ∘ g)         | (definition map~F~)
|                | = fmap f ∘ fmap g      | (Haskell Functor Law)
|                | = map~F~ f ∘ map~F~ g  | (definition map~F~)
|#

[lowerroman,start=2]
. To prove: for any object a in Obj~FP~,  map~F~ id~a~ = id~F a~.

[{eqtable}]
|#
| map~F~ id~a~ | = fmap id~a~  | (definition map~F~)
|              | = id~a~       | (Haskell Functor Law)
|#

[#ex-haskell-bifunctor]
# Haskell Bifunctor

Any Haskell type constructor F that has an instance of the link:https://hackage.haskell.org/package/base-4.18.0.0/docs/Data-Bifunctor.html[Haskell Bifunctor class] forms a bifunctor in FP.

_Proof._

We are given a type constructor F taking 2 parameters, and a function 

 bimap: (a → b) → (c → d) → (F a c → F b d) 

where bimap obeys the following laws:

 bimap id id = id
 bimap  (f ∘ g) (h ∘ i) = bimap f h ∘ bimap g i

Note that 
[{eqtable}]
|#
| F : Obj~FP~ → Obj~FP~ → Obj~FP~ | = F : Obj~FP~ ⨯ Obj~FP~ → Obj~FP~  | (uncurrying)
|                                 | = F : Obj~FP⨯FP~ → Obj~FP~         | (definition product category)
|#

Furthermore, we have that 
[{eqtable}]
|#
| bimap : (a → b) → (c → d) → (F a c → F b d) | = bimap : Mor~FP~ → Mor~FP~ → Mor~FP~ |
|                                             | = bimap : Mor~FP~ ⨯ Mor~FP~ → Mor~FP~ | (uncurrying)
|                                             | = bimap : Mor~FP⨯FP~ → Mor~FP~        | (definition product category)
|#

which means that bimap indeed gives us a function for map~F~.
It can be observed that map~F~ obeys the functor axioms from the bimap laws listed above.

[#ex-prelist]
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

[#ex-product-functor-fp]
# The Product Functor in FP
The type constructor

 Pair: FP ⨯ FP → FP
 Pair a b = Pair a b

forms a bifunctor under

 map~Pair~ (f, g) (Pair a b) = Pair (f a) (g b)

[#ex-sum-functor-fp]
# The Sum Functor in FP
The type constructor

 Either: FP ⨯ FP → FP
 Either a b = Left a | Right b

forms a bifunctor under

 map~Either~ (f, g) (Left a) = Left (f a)
 map~Either~ (f, g) (Right b) = Right (g b)

[#ex-haskell-contravariant-functor]
# Haskell Contravariant Functor
Any type constructor that has an instance of link:https://hackage.haskell.org/package/base-4.18.0.0/docs/Data-Functor-Contravariant.html[Contravariant]
forms a contravariant endofunctor in FP.

_Proof._ TODO

[#ex-haskell-profunctor]
# Haskell Profunctor
Any type constructor that has an instance of link:https://hackage.haskell.org/package/profunctors-5.6.2/docs/Data-Profunctor.html[Profunctor]
forms a profunctor in FP.

_Proof._ TODO

[#ex-hom-functor]
# Hom-functor
Given a category C, the Hom-functor F: C^op^ ⨯ C → C is given by 

 F: Obj~C^op^~ ⨯ Obj~C~ → Obj~Set~  
 F (a, b) = Mor~C~ a b

 map~F~: Mor~C^op^~ ⨯ Mor~C~ → Mor~Set~  
 map~F~: ((a' → a), (b → b')) → mor~C~ a b → Mor~C~ a' b'  
 map~F~ (f, g) h = g ∘ h ∘ f
