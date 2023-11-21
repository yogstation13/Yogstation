/*/obj/effect/proc_holder/zombie/spit
	name = "Spit Neurotoxin"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	button_icon_state = "alien_neurotoxin_0"
	active = FALSE
	cooldown_time = 1 MINUTES


/obj/effect/proc_holder/zombie/spit/fire(mob/living/carbon/user)
	if(active)
		remove_ranged_ability(span_notice("You close your neurotoxin reserves."))
	else
		add_ranged_ability(user, span_notice("You open your neurotoxin reserves. <B>Left-click to fire at a target!</B>"), TRUE)

/obj/effect/proc_holder/zombie/spit/update_icon(updates=ALL)
	. = ..()
	action.button_icon_state = "alien_neurotoxin_[active]"
	action.build_all_button_icons()

/obj/effect/proc_holder/zombie/spit/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return FALSE
	if(!isinfected(owner) || owner.stat != CONSCIOUS)
		remove_ranged_ability()
		return FALSE

	var/mob/living/carbon/user = owner

	if(!ready)
		to_chat(user, span_warning("You cannot currently spit. You can spit again in [(cooldown_ends - world.time) / 10] seconds"))
		remove_ranged_ability()
		return FALSE

	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!U || !T)
		return FALSE

	user.visible_message("<span class='danger'>[user] spits neurotoxin!", span_alertalien("You spit neurotoxin."))
	var/obj/projectile/bullet/neurotoxin/spitter/A = new /obj/projectile/bullet/neurotoxin/spitter(user.loc)
	A.preparePixelProjectile(target, user, params)
	A.fire()
	user.newtonian_move(get_dir(U, T))
	start_cooldown()

	return TRUE

/obj/projectile/bullet/neurotoxin/spitter
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 2
	damage_type = TOX
	paralyze = 50

/obj/projectile/bullet/neurotoxin/spitter/on_hit(atom/target, blocked = FALSE)
	if(isinfected(target))
		paralyze = 0
		nodamage = TRUE
	return ..()
*/
