-- Copyright (c) 2019 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Scott Morrison

import category_theory.limits.limits

universes v u

open category_theory
open category_theory.functor

namespace category_theory.limits

variables {C : Sort u} [𝒞 : category.{v+1} C]
include 𝒞

instance [has_colimits.{v} C] : has_limits.{v} Cᵒᵖ :=
{ has_limits_of_shape := λ J 𝒥, by exactI
  { has_limit := λ F,
    { cone := cone_of_cocone_left_op (colimit.cocone F.left_op),
      is_limit :=
      { lift := λ s, (colimit.desc F.left_op (cocone_left_op_of_cone s)).op,
        fac' := λ s j,
        begin
          rw [cone_of_cocone_left_op_π_app, colimit.cocone_ι, ←op_comp,
              colimit.ι_desc, cocone_left_op_of_cone_ι_app, has_hom.hom.op_unop],
          refl, end,
        uniq' := λ s m w,
        begin
          have u := (colimit.is_colimit F.left_op).uniq (cocone_left_op_of_cone s) (m.unop),
          convert congr_arg (λ f : _ ⟶ _, f.op) (u _), clear u,
          intro j,
          dsimp,
          convert congr_arg (λ f : _ ⟶ _, f.unop) (w (unop j)), clear w,
          dsimp,
          simp,
          refl,
        end } } } }

instance [has_limits.{v} C] : has_colimits.{v} Cᵒᵖ :=
{ has_colimits_of_shape := λ J 𝒥, by exactI
  { has_colimit := λ F,
    { cocone := cocone_of_cone_left_op (limit.cone F.left_op),
      is_colimit :=
      { desc := λ s, (limit.lift F.left_op (cone_left_op_of_cocone s)).op,
        fac' := λ s j,
        begin
          rw [cocone_of_cone_left_op_ι_app, limit.cone_π, ←op_comp,
              limit.lift_π, cone_left_op_of_cocone_π_app, has_hom.hom.op_unop],
          refl, end,
        uniq' := λ s m w,
        begin
          have u := (limit.is_limit F.left_op).uniq (cone_left_op_of_cocone s) (m.unop),
          convert congr_arg (λ f : _ ⟶ _, f.op) (u _), clear u,
          intro j,
          dsimp,
          convert congr_arg (λ f : _ ⟶ _, f.unop) (w (unop j)), clear w,
          dsimp,
          simp,
          refl,
        end } } } }

end category_theory.limits
