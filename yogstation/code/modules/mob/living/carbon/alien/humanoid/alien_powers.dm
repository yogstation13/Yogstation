/obj/effect/proc_holder/alien/regurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach."
	plasma_cost = 0
	action_icon_state = "alien_barf"

/obj/effect/proc_holder/alien/regurgitate/fire(mob/living/carbon/user)
	if(user.stomach_contents.len)
		for(var/atom/movable/A in user.stomach_contents)
			user.stomach_contents.Remove(A)
			A.forceMove(user.drop_location())
			if(isliving(A))
				var/mob/M = A
				M.reset_perspective()
		user.visible_message(span_alertealien("[user] hurls out the contents of their stomach!"))

/obj/effect/proc_holder/alien/neurotoxin_bite
	name = "Neurotoxin Bite"
	desc = "Bites the target with a paralyzing neurotoxin."
	plasma_cost = 60

	action_icon_state = "alien_neurotoxin_bite_button"

	var/reagent_to_inject = /datum/reagent/consumable/ethanol/neurotoxin_alien //Friendly var editing support in case admins want to do a funny.
	var/reagent_amount_to_inject = 5

/obj/effect/proc_holder/alien/neurotoxin_bite/fire(mob/living/carbon/user)
	. = ..()
	if(active)
		remove_ranged_ability(
			span_notice("You empty your neurotoxin glands.")
		)
	else
		add_ranged_ability(
			user,
			span_notice("You prepare your neurotoxin glands. <B>Left-click to bite a nearby target!</B>"),
			TRUE
		)

/obj/effect/proc_holder/alien/neurotoxin_bite/on_lose(mob/living/carbon/user)
	remove_ranged_ability()
	. = ..()

/obj/effect/proc_holder/alien/neurotoxin_bite/add_ranged_ability(mob/living/user,msg,forced)
	. = ..()
	if(isalienadult(user))
		var/mob/living/carbon/alien/humanoid/A = user
		A.drooling = 1
		A.update_icons()

/obj/effect/proc_holder/alien/neurotoxin_bite/remove_ranged_ability(msg)
	if(isalienadult(ranged_ability_user))
		var/mob/living/carbon/alien/humanoid/A = ranged_ability_user
		A.drooling = 0
		A.update_icons()
	. = ..()

/obj/effect/proc_holder/alien/neurotoxin_bite/InterceptClickOn(mob/living/caller, params, atom/target)

	. = ..()

	if(.)
		return

	if(!iscarbon(ranged_ability_user) || ranged_ability_user.stat) // Dead or invalid.
		remove_ranged_ability()
		return

	if(!target || !iscarbon(target) || !isturf(target.loc) || !isturf(ranged_ability_user.loc) || get_dist(ranged_ability_user,target) > 1)
		return //Can't use on an invalid target.

	var/mob/living/carbon/user_carbon = ranged_ability_user
	var/mob/living/carbon/target_carbon = target

	if(target_carbon.reagents)
		target_carbon.reagents.add_reagent(reagent_to_inject, reagent_amount_to_inject)

	remove_ranged_ability()

	//Effects
	user_carbon.do_attack_animation(target_carbon, ATTACK_EFFECT_BITE)
	playsound(user_carbon, 'sound/weapons/bite.ogg', 40, 1, 1)
	user_carbon.visible_message(
		"<span class='danger'>[user_carbon] bites [target_carbon]!",
		span_alertalien("You bite [target_carbon], injecting them with neurotoxin.")
	)

	return TRUE