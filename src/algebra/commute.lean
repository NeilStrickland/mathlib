/-
Copyright (c) 2019 Neil Strickland. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Neil Strickland

Commuting pairs of elements in not-necessarily-commutative monoids,
groups and (semi) rings.  Centralizers as submonoids, subgroups or
subrings.

Usage example: suppose that a, b and c are elements of a ring, and
that `hb : commute a b` and `hc : commute a c`.  Then
`hb.pow_left 5` proves `commute (a ^ 5) b` and
`(hb.pow 2).add (hb.mul hc)` proves `commute a (b ^ 2 + b * c)`.
Lean does not immediately recognise these terms as equations,
so for rewriting we need syntax like `rw [(hb.pow_left 5).eq]`
rather than just `rw [hb.pow_left 5]`.
-/

import algebra.group_power
  group_theory.submonoid group_theory.subgroup
  ring_theory.subring

section semigroup

variables {S : Type*} [semigroup S]

@[reducible] def commute (a b : S) : Prop := a * b = b * a

theorem commute.eq {a b : S} (h : commute a b) : a * b = b * a := h

@[refl] theorem commute.refl (a : S) : commute a a := by { unfold commute }

@[symm] theorem commute.symm {a b : S} : commute a b → commute b a :=
λ h, h.symm

theorem commute.mul {a b c : S} :
 commute a b → commute a c → commute a (b * c) :=
λ hab hac,
  by { dsimp [commute] at *,
       rw [mul_assoc, ← hac, ← mul_assoc b, ← hab, mul_assoc] }

theorem commute.mul_left {a b c : S} :
 commute a c → commute b c → commute (a * b) c :=
λ hac hbc, (hac.symm.mul hbc.symm).symm

def centralizer (a : S) : set S := { x | commute a x }

theorem mem_centralizer (a : S) {x : S} : x ∈ centralizer a ↔ commute a x :=
iff.refl _

def set_centralizer (T : set S) : set S :=
  { x | ∀ (a : S), a ∈ T → commute a x }

theorem mem_set_centralizer (T : set S) {x : S} :
  x ∈ set_centralizer T ↔ ∀ (a : S), a ∈ T → commute a x :=
iff.refl _

end semigroup

section monoid

variables {M : Type*} [monoid M]

theorem commute.one (a : M) : commute a 1 :=
by { dsimp [commute], rw [one_mul, mul_one] }

theorem commute.one_left (a : M) : commute 1 a := (commute.one a).symm

section

open is_monoid_hom (map_mul map_one)

theorem commute.inv_hom {G : Type*} [group G] {f : G → M} [is_monoid_hom f]
  {a : M} {b : G} (h : commute a (f b)) : commute a (f b⁻¹) :=
calc a * (f b⁻¹) = (f b⁻¹) * (f b * a) * (f b⁻¹) : by rw [← mul_assoc, ← map_mul f, mul_left_inv, map_one f, one_mul]
             ... = (f b⁻¹) * a                   : by rw [h.eq.symm, mul_assoc, mul_assoc a, ← map_mul f, mul_right_inv, map_one f, mul_one]

theorem commute.inv_hom_left {G : Type*} [group G] {f : G → M} [is_monoid_hom f]
  {a : G} {b : M} (h : commute (f a) b) : commute (f a⁻¹) b :=
h.symm.inv_hom.symm

theorem commute.inv_hom_inv_hom {G₁ : Type*} [group G₁] {f₁ : G₁ → M} [is_monoid_hom f₁]
  {G₂ : Type*} [group G₂] {f₂ : G₂ → M} [is_monoid_hom f₂]
  {a : G₁} {b : G₂} (h : commute (f₁ a) (f₂ b)) : commute (f₁ a⁻¹) (f₂ b⁻¹) :=
h.inv_hom.inv_hom_left

end

theorem commute.inv_units {a : M} {b : units M} (h : commute a ↑b) : commute a ↑b⁻¹ := h.inv_hom

theorem commute.inv_units_left {a : units M} {b : M} (h : commute ↑a b) : commute ↑a⁻¹ b := h.inv_hom_left

theorem commute.pow {a b : M} (hab : commute a b) : ∀ (n : ℕ), commute a (b ^ n)
| 0 := by { rw [pow_zero], exact commute.one a }
| (n + 1) := by { rw [pow_succ], exact hab.mul (commute.pow n) }

theorem commute.pow_left {a b : M} (hab : commute a b) (n : ℕ) : commute (a ^ n) b :=
(hab.symm.pow n).symm

theorem commute.pow_pow {a b : M} (hab : commute a b) (n m : ℕ) :
 commute (a ^ n) (b ^ m) :=
commute.pow (commute.pow_left hab n) m

theorem commute.self_pow (a : M) (n : ℕ) : commute a (a ^ n) :=
(commute.refl a).pow n

theorem commute.pow_self (a : M) (n : ℕ) : commute (a ^ n) a :=
(commute.refl a).pow_left n

theorem commute.pow_pow_self (a : M) (n m : ℕ) : commute (a ^ n) (a ^ m) :=
(commute.refl a).pow_pow n m

instance centralizer.is_submonoid (a : M) : is_submonoid (centralizer a) :=
{ one_mem := commute.one a,
  mul_mem := λ x y hx hy, hx.mul hy }

instance set_centralizer.is_submonoid (S : set M) : is_submonoid (set_centralizer S) :=
{ one_mem := λ a h, commute.one a,
  mul_mem := λ x y hx hy a h, (hx a h).mul (hy a h) }

end monoid

section comm_monoid

variables {M : Type*} [comm_monoid M]

theorem commute.all (a b : M) : commute a b := mul_comm a b

end comm_monoid

section group

variables {G : Type*} [group G]

theorem commute.inv {a b : G} (hab : commute a b) : commute a b⁻¹ :=
@commute.inv_hom _ _ _ _ id _ a b hab

theorem commute.inv_left {a b : G} (hab : commute a b) : commute a⁻¹ b :=
hab.symm.inv.symm

theorem commute.inv_inv {a b : G} (hab : commute a b) : commute a⁻¹ b⁻¹ :=
hab.inv.symm.inv.symm

theorem commute.gpow {a b : G} (hab : commute a b) (n : ℤ) : commute a (b ^ n) :=
begin
  cases n,
  { rw [gpow_of_nat], exact hab.pow n },
  { rw [gpow_neg_succ], exact (hab.pow n.succ).inv }
end

theorem commute.gpow_left {a b : G} (hab : commute a b) (n : ℤ) :
  commute (a ^ n) b :=
(hab.symm.gpow n).symm

theorem commute.gpow_gpow {a b : G} (hab : commute a b) (n m : ℤ) :
  commute (a ^ n) (b ^ m) :=
(hab.gpow m).gpow_left n

theorem commute.self_gpow (a : G) (n : ℤ): commute a (a ^ n) :=
(commute.refl a).gpow n

theorem commute.gpow_self (a : G) (n : ℤ): commute (a ^ n) a :=
(commute.refl a).gpow_left n

theorem commute.gpow_gpow_self (a : G) (n m : ℤ): commute (a ^ n) (a ^ m) :=
(commute.refl a).gpow_gpow n m

instance centralizer.is_subgroup (a : G) : is_subgroup (centralizer a) :=
{ inv_mem := λ x hx, hx.inv, .. centralizer.is_submonoid a}

instance set_centralizer.is_subgroup (S : set G) : is_subgroup (set_centralizer S) :=
{ inv_mem := λ x hx a ha, (hx a ha).inv, .. set_centralizer.is_submonoid S }

end group

section semiring

variables {A : Type*} [semiring A]

theorem commute.zero (a : A) : commute a 0 :=
by { dsimp [commute], rw [mul_zero, zero_mul] }

theorem commute.zero_left (a : A) : commute 0 a := (commute.zero a).symm

theorem commute.add {a b c : A} (hab : commute a b) (hac : commute a c) :
  commute a (b + c) :=
by { dsimp [commute] at *, rw [mul_add, add_mul, hab, hac] }

theorem commute.add_left {a b c : A} (hac : commute a c) (hbc : commute b c) :
  commute (a + b) c :=
(hac.symm.add hbc.symm).symm

theorem commute.cast_nat (a : A) (n : ℕ) : commute a (n : A) :=
begin
  induction n with n ih,
  { rw [nat.cast_zero], exact commute.zero a },
  { rw [nat.cast_succ], exact ih.add (commute.one a) }
end

theorem commute.cast_nat_left (n : ℕ) (a : A) : commute (n : A) a :=
(commute.cast_nat a n).symm

end semiring

section ring

variables {A : Type*} [ring A]

theorem commute.neg {a b : A} (hab : commute a b) : commute a (- b) :=
begin
  dsimp [commute] at *,
  rw [← neg_mul_eq_mul_neg, hab, neg_mul_eq_neg_mul_symm ]
end

theorem commute.neg_left {a b : A} (hab : commute a b) : commute (- a) b :=
hab.symm.neg.symm

theorem commute.sub {a b c : A} (hab : commute a b) (hac : commute a c) :
  commute a (b - c) :=
hab.add hac.neg

theorem commute.sub_left {a b c : A} (hac : commute a c) (hbc : commute b c) :
  commute (a - b) c :=
(hac.symm.sub hbc.symm).symm

theorem commute.cast_int (a : A) (n : ℤ) : commute a (n : A) :=
begin
  cases n,
  { rw [int.cast_of_nat], exact commute.cast_nat a n},
  { rw [int.cast_neg_succ_of_nat], exact (commute.cast_nat a n.succ).neg }
end

theorem commute.cast_int_left (a : A) (n : ℤ) : commute (n : A) a :=
(commute.cast_int a n).symm

instance centralizer.is_subring (a : A) : is_subring (centralizer a) :=
{ zero_mem := commute.zero a,
  neg_mem := λ x hx, hx.neg,
  add_mem := λ x y hx hy, hx.add hy,
  .. centralizer.is_submonoid a }

instance set_centralizer.is_subring (S : set A) : is_subring (set_centralizer S) :=
{ zero_mem := λ a ha, commute.zero a,
  neg_mem := λ x hx a ha, (hx a ha).neg,
  add_mem := λ x y hx hy a ha, (hx a ha).add (hy a ha),
  .. set_centralizer.is_submonoid S }

end ring

theorem mul_pow_comm {M : Type*} [monoid M] {a b : M} (h : commute a b) :
 ∀ (n : ℕ), (a * b) ^ n = a ^ n * b ^ n
| 0 := by { rw[pow_zero, pow_zero, pow_zero, mul_one] }
| (n + 1) := by { rw[pow_succ, pow_succ, pow_succ, mul_pow_comm n,
                     mul_assoc, ← mul_assoc b, (h.symm.pow n).eq,
                     mul_assoc, mul_assoc] }

theorem mul_gpow_comm {G : Type*} [group G] {a b : G} (h : commute a b) :
 ∀ (n : ℤ), (a * b) ^ n = a ^ n * b ^ n
| (int.of_nat n) :=
    by { rw[gpow_of_nat, gpow_of_nat, gpow_of_nat, mul_pow_comm h n] }
| (int.neg_succ_of_nat n) :=
    by { rw[gpow_neg_succ, gpow_neg_succ, gpow_neg_succ],
         rw[mul_pow_comm h n.succ, mul_inv_rev],
         rw[(h.pow_pow n.succ n.succ).inv_inv.eq] }

theorem pow_neg {A : Type*} [ring A] (a : A) (n : ℕ) : (- a) ^ n = (-1) ^ n * a ^ n :=
begin
  rw [← neg_one_mul],
  exact mul_pow_comm (commute.one_left a).neg_left n
end
