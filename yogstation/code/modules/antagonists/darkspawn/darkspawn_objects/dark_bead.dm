//Formed by the Devour Will ability.
/obj/item/dark_bead
	name = "dark bead"
	desc = "A glowing black orb. It's fading fast."
	icon = 'yogstation/icons/obj/darkspawn_items.dmi'
	icon_state = "dark_bead"
	item_state = "disintegrate"
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE | INDESTRUCTIBLE
	item_flags = DROPDEL
	w_class = 5
	light_color = "#21007F"
	light_power = 0.3
	light_range = 2
	var/eating = FALSE //If we're devouring someone's will
	var/datum/action/innate/darkspawn/devour_will/linked_ability //The ability that keeps data for us
	var/full_restore = TRUE

/obj/item/dark_bead/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	animate(src, alpha = 50, time = 50)
	QDEL_IN(src, 50)

/obj/item/dark_bead/Destroy(force)
	if(isliving(loc) && !eating && !force)
		to_chat(loc, "<span class='warning'>You were too slow! [src] faded away...</span>")
	if(!eating || force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/item/dark_bead/attack(mob/living/carbon/L, mob/living/user)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	if(!darkspawn || eating || L == user) //no eating urself ;)))))))
		return
	if(!istype(L, /mob/living/carbon))
		to_chat(user, "<span calss='warning'>[L]'s mind is not powerful enough to be of use.</span>")
		return
	linked_ability = darkspawn.has_ability("devour_will")
	if(!linked_ability) //how did you even get this?
		qdel(src)
		return
	if(!L.mind || isdarkspawn(L))
		to_chat(user, "<span class='warning'>You cannot drain allies or the mindless.</span>")
		return
	if(!L.health || L.stat)
		to_chat(user, "<span class='warning'>[L] is too weak to drain.</span>")
		return
	if(linked_ability.victims[L])
		to_chat(user, "<span class='warning'>[L] must be given time to recover from their last draining.</span>")
		return
	if(linked_ability.last_victim == L.ckey)
		to_chat(user, "<span class='warning'>[L]'s mind is still too scrambled. Drain someone else first.</span>")
		return
	if(isveil(L))
		full_restore = FALSE
		to_chat(user, "<span class='warning'>[L] has been veiled and will not produce as much psi as an unmodified victim.</span>")
	eating = TRUE
	if(user.loc != L)
		user.visible_message("<span class='warning'>[user] grabs [L] and leans in close...</span>", "<span class='velvet bold'>cera qo...</span><br>\
		<span class='danger'>You begin siphoning [L]'s mental energy...</span>")
		to_chat(L, "<span class='userdanger'><i>AAAAAAAAAAAAAA-</i></span>")
		L.Stun(50)
		L.silent += 4
		playsound(L, 'yogstation/sound/magic/devour_will.ogg', 65, FALSE) //T A S T Y   S O U L S
		if(!do_mob(user, L, 30))
			user.Knockdown(30)
			to_chat(L, "<span class='boldwarning'>All right. You're all right.</span>")
			L.Knockdown(30)
			qdel(src, force = TRUE)
			return
	else
		L.visible_message("<span class='userdanger italics'>[L] suddenly howls and clutches as their face as violet light screams from their eyes!</span>", \
		"<span class='userdanger italics'>AAAAAAAAAAAAAAA-</span>")
		to_chat(user, "<span class='velvet'><b>cera qo...</b><br>You begin siphoning [L]'s will...</span>")
		L.Stun(50)
		playsound(L, 'yogstation/sound/magic/devour_will_long.ogg', 65, FALSE)
		if(!do_mob(user, L, 50))
			user.Knockdown(50)
			to_chat(L, "<span class='boldwarning'>All right. You're all right.</span>")
			L.Knockdown(50)
			qdel(src, force = TRUE)
			return
	user.visible_message("<span class='warning'>[user] gently lowers [L] to the ground...</span>", "<span class='velvet'><b>...aranupdejc</b><br>\
	You devour [L]'s will. Your Psi has been [!full_restore ? "partially restored." : "fully restored.\n\
	Additionally, you have gained one lucidity. Use it to purchase and upgrade abilities."]<br>\
	<span class='warning'>[L] is now severely weakened and will take some time to recover.</span> \
	<span class='warning'>Additionally, you can not drain them again without first draining someone else.</span>")
	playsound(L, 'yogstation/sound/magic/devour_will_victim.ogg', 50, FALSE)
	if(full_restore)
		darkspawn.psi = darkspawn.psi_cap
		darkspawn.lucidity++ //no getting free lucidity from veils that wouldn't be fun. They'll still count towards winning though.
	else
		darkspawn.psi += 20
	if(linked_ability.victims[L] == FALSE)
		to_chat(user, "<span class ='warning'> You have already drained this individual previously, and their lucidity will not contribute any more to the sacrament!</span>")
	else
		to_chat(user, "<span class ='velvet'> This individual's lucidity brings you one step closer to the sacrament...</span>")
		darkspawn.lucidity_drained++
	darkspawn.update_psi_hud()
	linked_ability.victims[L] = TRUE
	linked_ability.last_victim = L.ckey
	to_chat(L, "<span class='userdanger'>You suddenly feel... empty. Thoughts try to form, but flit away. You slip into a deep, deep slumber...</span>")
	L.playsound_local(L, 'yogstation/sound/magic/devour_will_end.ogg', 75, FALSE)
	L.Unconscious(15)
	L.apply_effect(EFFECT_STUTTER, 20)
	L.apply_status_effect(STATUS_EFFECT_BROKEN_WILL)
	addtimer(CALLBACK(linked_ability, /datum/action/innate/darkspawn/devour_will/.proc/make_eligible, L), 600)
	qdel(src, force = TRUE)
	return TRUE
