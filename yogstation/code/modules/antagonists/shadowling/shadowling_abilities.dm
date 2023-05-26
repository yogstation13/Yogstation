#define EMPOWERED_THRALL_LIMIT 3

/datum/action/cooldown/spell/proc/shadowling_check(mob/living/carbon/human/H) //what the fuck was this shit
	if(!H || !istype(H)) 
		return FALSE
	if(H.dna && H.dna.species && H.dna.species.id == "shadowling" && is_shadow(H)) 
		return TRUE
	if(H.dna && H.dna.species && H.dna.species.id == "l_shadowling" && is_thrall(H)) 
		return TRUE
	if(!is_shadow_or_thrall(owner)) 
		to_chat(owner, span_warning("You can't wrap your head around how to do this."))

	if(is_thrall(owner)) 
		to_chat(owner, span_warning("You aren't powerful enough to do this."))

	if(is_shadow(owner)) 
		to_chat(owner, span_warning("Your telepathic ability is suppressed. Hatch or use Rapid Re-Hatch first."))
	return FALSE

/datum/action/cooldown/spell/pointed/sling
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	var/mob/living/user

/datum/action/cooldown/spell/pointed/sling/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(t))
		to_chat(caller, span_warning("You may only use this ability on living things!"))
		return FALSE
	user = caller
	target = t
	if(!shadowling_check(user))
		return FALSE
	
	return TRUE

/datum/action/cooldown/spell/pointed/sling/proc/revert_cast()
	unset_click_ability(owner)

/datum/action/cooldown/spell/pointed/sling/proc/start_recharge()
	build_all_button_icons()

/datum/action/cooldown/spell/pointed/sling/glare //Stuns and mutes a human target for 10 seconds
	name = "Glare"
	desc = "Disrupts the target's motor and speech abilities. Much more effective within two meters."
	panel = "Shadowling Abilities"
	button_icon_state = "glare"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/pointed/sling/glare/InterceptClickOn(mob/living/caller, params, atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!target_atom || !iscarbon(target_atom))
		revert_cast()
		return FALSE
	var/mob/living/carbon/target = target_atom
	if(!caller.getorganslot(ORGAN_SLOT_EYES))
		to_chat(owner, span_warning("You need eyes to glare!"))
		revert_cast()
		return FALSE
	if(target.stat)
		to_chat(owner, span_warning("[target] must be conscious!"))
		revert_cast()
		return FALSE
	if(is_shadow_or_thrall(target))
		to_chat(owner, span_warning("You cannot glare at allies!"))
		revert_cast()
		return FALSE
	var/mob/living/carbon/human/M = target
	usr.visible_message(span_warning("<b>[owner]'s eyes flash a purpleish-red!</b>"))
	var/distance = get_dist(target, owner)
	if (distance <= 2)
		target.visible_message(span_danger("[target] suddendly collapses..."))
		to_chat(target, span_userdanger("A purple light flashes across your vision, and you lose control of your movements!"))
		target.Paralyze(10 SECONDS)
		M.silent += 10
	else //Distant glare
		var/loss = 100 - (distance * 10)
		target.adjustStaminaLoss(loss)
		if(iscarbon(target))
			target.adjust_stutter(loss)
		else if(issilicon(target))
			target.adjust_stutter(distance)
		to_chat(target, span_userdanger("A purple light flashes across your vision, and exhaustion floods your body..."))
		target.visible_message(span_danger("[target] looks very tired..."))
	start_recharge()
	unset_click_ability(owner)
	return TRUE

/datum/action/cooldown/spell/aoe/veil //Puts out most nearby lights except for flares and yellow slime cores
	name = "Veil"
	desc = "Extinguishes most nearby light sources."
	panel = "Shadowling Abilities"
	button_icon_state = "veil"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	cooldown_time = 12 SECONDS //Short cooldown because people can just turn the lights back on
	aoe_radius = 5
	var/admin_override = FALSE //Requested by Shadowlight213. Allows anyone to cast the spell, not just shadowlings.
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/aoe/proc/extinguishItem(obj/item/I, cold = FALSE) //Does not darken items held by mobs due to mobs having separate luminosity, use extinguish_mob() or write your own proc.
	var/blacklisted_lights = list(/obj/item/flashlight/flare, /obj/item/flashlight/slime)
	if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		if(F.light_on || F.on)
			if(cold)
				if(is_type_in_list(F, blacklisted_lights))
					F.visible_message(span_warning("The sheer cold shatters [F]!"))
					qdel(F)
				else
					return
			if(is_type_in_list(I, blacklisted_lights))
				I.visible_message(span_danger("[I] dims slightly before scattering the shadows around it."))
				return F.light_power //Necessary because flashlights become 0-luminosity when held.  I don't make the rules of lightcode.
			F.on = FALSE
			F.set_light_on(FALSE)
			F.update_brightness()
	else if(istype(I, /obj/item/pda))
		var/obj/item/pda/P = I
		P.set_light_on(FALSE)
	I.set_light_on(FALSE)
	return I.luminosity

/datum/action/cooldown/spell/aoe/proc/extinguish_mob(mob/living/H, cold = FALSE)
	for(var/obj/item/F in H)
		if(cold)
			extinguishItem(F, TRUE)
		extinguishItem(F)
	if(iscarbon(H))
		var/mob/living/carbon/M = H
		var/datum/mutation/human/glow/G = M.dna.get_mutation(GLOWY)
		if(G)
			G.glowth.set_light(0, 0) // Set glowy to no light
			if(G.current_nullify_timer)
				deltimer(G.current_nullify_timer) // Stacks
			G.current_nullify_timer = addtimer(CALLBACK(src, PROC_REF(giveGlowyBack), M), 40 SECONDS, TIMER_STOPPABLE)

/datum/action/cooldown/spell/aoe/proc/giveGlowyBack(mob/living/carbon/M)
	if(!M)
		return
	var/datum/mutation/human/glow/G = M.dna.get_mutation(GLOWY)
	if(G)
		G.modify() // Re-sets glowy
		G.current_nullify_timer = null

/datum/action/cooldown/spell/aoe/veil/cast_on_thing_in_aoe(atom/target, atom/user)
	if(!shadowling_check(owner) && !admin_override)
		return
	to_chat(owner, span_shadowling("You silently disable all nearby lights."))
	var/turf/T = get_turf(owner)
	for(var/datum/light_source/LS in T.get_affecting_lights())
		var/atom/LO = LS.source_atom
		if(isitem(LO))
			extinguishItem(LO)
			continue
		if(istype(LO, /obj/machinery/light))
			var/obj/machinery/light/L = LO
			L.on = FALSE
			L.visible_message(span_warning("[L] flickers and falls dark."))
			L.update(0)
			L.set_light(0)
			continue
		if(istype(LO, /obj/machinery/computer) || istype(LO, /obj/machinery/power/apc))
			LO.set_light(0)
			LO.visible_message(span_warning("[LO] grows dim, its screen barely readable."))
			continue
		if(ismob(LO))
			extinguish_mob(LO)
		if(istype(LO, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/borg = LO
			if(!borg.lamp_cooldown)
				borg.smash_headlamp()
		if(istype(LO, /obj/machinery/camera))
			LO.set_light(0)
			if(prob(10))
				LO.emp_act(2)
			continue
		if(istype(LO, /obj/mecha))
			var/obj/mecha/M = LO
			M.set_light(0)
			M.lights = FALSE
		if(istype(LO, /obj/machinery/power/floodlight))
			var/obj/machinery/power/floodlight/FL = LO
			FL.change_setting(2) // Set floodlight to lowest setting
		if(istype(LO, /obj/structure/light_prism))
			qdel(LO)

	for(var/obj/structure/glowshroom/G in orange(7, user)) //High radius because glowshroom spam wrecks shadowlings
		if(G.light_power > 0)
			var/obj/structure/glowshroom/shadowshroom/S = new /obj/structure/glowshroom/shadowshroom(G.loc) //I CAN FEEL THE WARP OVERTAKING ME! IT IS A GOOD PAIN!
			S.generation = G.generation
			G.visible_message(span_warning("[G] suddenly turns dark!"))
			qdel(G)
	for(var/turf/open/floor/grass/fairy/F in view(7, user))
		if(F.light_power > 0)
			F.visible_message(span_warning("[F] suddenly turns dark!"))
			F.ChangeTurf(/turf/open/floor/grass/fairy/dark, flags = CHANGETURF_INHERIT_AIR)
	for(var/obj/structure/marker_beacon/M in view(7, user))
		M.deconstruct()

/datum/action/cooldown/spell/aoe/flashfreeze //Stuns and freezes nearby people - a bit more effective than a changeling's cryosting
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage while hampering their movement."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "icy_veins"

	panel = "Shadowling Abilities"
	sound = 'sound/effects/ghost2.ogg'
	aoe_radius = 3
	cooldown_time = 1 MINUTES
	var/special_lights = list(/obj/item/flashlight/flare, /obj/item/flashlight/slime)
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/aoe/flashfreeze/cast_on_thing_in_aoe(atom/target, atom/user)
	if(!shadowling_check(owner))
		return
	to_chat(owner, span_shadowling("You freeze the nearby air."))
	if(isturf(target))
		var/turf/T = target
		for(var/mob/living/carbon/M in T.contents)
			if(is_shadow_or_thrall(M))
				if(M == user) //No message for the user, of course
					continue
				else
					to_chat(M, span_danger("You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!"))
					continue
			to_chat(M, span_userdanger("A wave of shockingly cold air engulfs you!"))
			M.Stun(2)
			M.apply_damage(5, BURN)
			if(M.bodytemperature)
				M.adjust_bodytemperature(-100, 50)
			if(M.reagents)
				M.reagents.add_reagent(/datum/reagent/consumable/frostoil, 5) //some amount of a cryo sting fucked if I care
				M.reagents.add_reagent(/datum/reagent/shadowfrost, 5)
			extinguish_mob(M, TRUE)
		for(var/obj/item/F in T.contents)
			extinguishItem(F, TRUE)

/datum/action/cooldown/spell/pointed/enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Enthrall"
	desc = "Allows you to enslave a conscious, non-braindead, non-catatonic human to your will. This takes some time to cast."
	panel = "Shadowling Abilities"
	button_icon_state = "enthrall"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	cast_range = 1 //Adjacent to user
	var/enthralling = FALSE
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/pointed/enthrall/InterceptClickOn(mob/living/caller, params, atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/user = owner
	listclearnulls(SSticker.mode.thralls)
	if(!(user.mind in SSticker.mode.shadows)) return
	if(user.dna.species.id != "shadowling")
		if(SSticker.mode.thralls.len >= 5)
			return FALSE
	var/mob/living/target = target_atom
	if(!target.key || !target.mind)
		to_chat(user, span_warning("The target has no mind!"))
		return FALSE
	if(target.stat)
		to_chat(user, span_warning("The target must be conscious!"))
		return FALSE
	if(is_shadow_or_thrall(target))
		to_chat(user, span_warning("You can not enthrall allies!"))
		return FALSE
	if(!ishuman(target))
		to_chat(user, span_warning("You can only enthrall humans!"))
		return FALSE
	if(enthralling)
		to_chat(user, span_warning("You are already enthralling!"))
		return FALSE
	if(!target.client)
		to_chat(user, span_warning("[target]'s mind is vacant of activity."))
	enthralling = TRUE
	for(var/progress = 0, progress <= 3, progress++)
		switch(progress)
			if(1)
				to_chat(user, span_notice("You place your hands to [target]'s head..."))
				user.visible_message(span_warning("[user] places their hands onto the sides of [target]'s head!"))
			if(2)
				to_chat(user, span_notice("You begin preparing [target]'s mind as a blank slate..."))
				user.visible_message(span_warning("[user]'s palms flare a bright red against [target]'s temples!"))
				to_chat(target, span_danger("A terrible red light floods your mind. You collapse as conscious thought is wiped away."))
				target.Knockdown(12 SECONDS)
				if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
					if(ispreternis(target))
						to_chat(user, span_notice("Your servant's mind has been corrupted by other machinery. You begin to shut down the implant preventing your command - this will take some time..."))
						user.visible_message(span_warning("[user] growls in frustration, then dips their head with determination!"))
					else
						to_chat(user, span_notice("They are protected by an implant. You begin to shut down the nanobots in their brain - this will take some time..."))
						user.visible_message(span_warning("[user] pauses, then dips their head in concentration!"))
					to_chat(target, span_boldannounce("You feel your mental protection faltering!"))
					if(!do_mob(user, target, 65 SECONDS)) //65 seconds to remove a loyalty implant. yikes!
						to_chat(user, span_warning("The enthralling has been interrupted - your target's mind returns to its previous state."))
						to_chat(target, span_userdanger("You wrest yourself away from [user]'s hands and compose yourself!"))
						enthralling = FALSE
						return
					to_chat(user, span_notice("The nanobots composing the mindshield implant have been rendered inert. Now to continue."))
					user.visible_message(span_warning("[user] relaxes again."))
					for(var/obj/item/implant/mindshield/L in target)
						if(L)
							qdel(L)
					to_chat(target, span_boldannounce("Your mental protection unexpectedly falters, dims, dies."))
			if(3)
				to_chat(user, span_notice("You begin planting the tumor that will control the new thrall..."))
				user.visible_message(span_warning("A strange energy passes from [user]'s hands into [target]'s head!"))
				to_chat(target, span_boldannounce("You feel your memories twisting, morphing. A sense of horror dominates your mind."))
		if(!do_mob(user, target, 7 SECONDS)) //around 21 seconds total for enthralling, 86 for someone with a loyalty implant
			to_chat(user, span_warning("The enthralling has been interrupted - your target's mind returns to its previous state."))
			to_chat(target, span_userdanger("You wrest yourself away from [user]'s hands and compose yourself!"))
			enthralling = FALSE
			return
		enthralling = FALSE
		to_chat(user, span_shadowling("You have enthralled <b>[target.real_name]</b>!"))
		target.visible_message(span_big("[target] looks to have experienced a revelation!"), \
							   span_warning("False faces all d<b>ark not real not real not--</b>"))
		target.setOxyLoss(0) //In case the shadowling was choking them out
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			var/datum/mutation/human/glow/G = M.dna.get_mutation(GLOWY)
			if(G)
				M.dna.remove_mutation(GLOWY)
		target.mind.special_role = "thrall"
		var/obj/item/organ/internal/shadowtumor/ST = new
		ST.Insert(target, FALSE, FALSE)
		target.add_thrall()
		if(target.reagents.has_reagent(/datum/reagent/consumable/frostoil)) //Stabilize body temp incase the sling froze them earlier
			target.reagents.remove_reagent(/datum/reagent/consumable/frostoil)
			to_chat(target, span_notice("You feel warmer... It feels good."))
			target.bodytemperature = 310
	
	return TRUE

/datum/action/cooldown/spell/shadowling_hivemind //Lets a shadowling talk to its allies
	name = "Hivemind Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Shadowling Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "commune"

	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/shadowling_hivemind/cast(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!is_shadow(owner))
		to_chat(owner, span_warning("You must be a shadowling to do that!"))
		return
	var/text = sanitize(tgui_input_text(owner, "What do you want to say your thralls and fellow shadowlings?.", "Hive Chat", ""))
	if(!text)
		return
	var/my_message = "<span class='shadowling command_headset'><b>\[Shadowling\]</b><i> [owner.real_name]</i>: [text]</span></font>"
	for(var/mob/M in GLOB.mob_list)
		if(is_shadow_or_thrall(M))
			to_chat(M, my_message)
		if(M in GLOB.dead_mob_list)
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(owner)]'>(F)</a> [my_message]")
	log_say("[owner.real_name]/[owner.key] : [text]")

	return TRUE

/datum/action/cooldown/spell/shadowling_regenarmor //Resets a shadowling's species to normal, removes genetic defects, and re-equips their armor
	name = "Rapid Re-Hatch"
	desc = "Re-forms protective chitin that may be lost during cloning or similar processes."
	panel = "Shadowling Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "regen_armor"

	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/shadowling_regenarmor/cast(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return FALSE
	if(!is_shadow(user))
		to_chat(user, span_warning("You must be a shadowling to do this!"))
		return
	user.visible_message(span_warning("[user]'s skin suddenly bubbles and shifts around their body!"), \
						 span_shadowling("You regenerate your protective armor and cleanse your form of defects."))
	user.setCloneLoss(0)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(user), SLOT_WEAR_SUIT)
	user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(user), SLOT_HEAD)
	user.set_species(/datum/species/shadow/ling)

	return TRUE

/datum/action/cooldown/spell/collective_mind //Lets a shadowling bring together their thralls' strength, granting new abilities and a headcount
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	panel = "Shadowling Abilities"
	button_icon_state = "collective_mind"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	cooldown_time = 10 SECONDS //10 second cooldown to prevent spam
	spell_requirements = SPELL_REQUIRES_HUMAN

	var/blind_smoke_acquired = FALSE
	var/screech_acquired = FALSE
	var/reviveThrallAcquired = FALSE
	var/null_charge_acquired = FALSE

/datum/action/cooldown/spell/collective_mind/cast(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return FALSE
	if(!shadowling_check(user))
		return
	var/thralls = 0
	var/victory_threshold = SSticker.mode.required_thralls
	var/mob/M
	to_chat(user, span_shadowling("<b>You focus your telepathic energies abound, harnessing and drawing together the strength of your thralls.</b>"))
	for(M in GLOB.alive_mob_list)
		if(is_thrall(M))
			thralls++
			to_chat(M, span_shadowling("You feel hooks sink into your mind and pull."))
	if(!do_after(user, 3 SECONDS, user))
		to_chat(user, span_warning("Your concentration has been broken. The mental hooks you have sent out now retract into your mind."))
		return
	if(thralls >= CEILING(3 * SSticker.mode.thrall_ratio, 1) && !screech_acquired)
		screech_acquired = TRUE
		to_chat(user, span_shadowling("<i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms."))
		var/datum/action/cooldown/spell/aoe/unearthly_screech/screech = new(M)
		screech.Grant(M)
	if(thralls >= CEILING(5 * SSticker.mode.thrall_ratio, 1) && !blind_smoke_acquired)
		blind_smoke_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. It will create a choking cloud that will blind any non-thralls who enter. \
			</i></span>")
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Dark Acceleration</b> ability. This will allow you to turn one of your thralls into a weaker shadowling. \
			</i></span>")
		var/datum/action/cooldown/spell/pointed/empower_thrall/empower = new(M)
		empower.Grant(M)
		var/datum/action/cooldown/spell/blindness_smoke/smoke = new(M)
		smoke.Grant(M)
	if(thralls >= CEILING(7 * SSticker.mode.thrall_ratio, 1) && !null_charge_acquired)
		null_charge_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Null Charge</b> ability. This ability will drain an APC's contents to the void, preventing it from recharging \
		or sending power until repaired.</i></span>")
		var/datum/action/cooldown/spell/null_charge/null_charge = new(M)
		null_charge.Grant(M)
	if(thralls >= CEILING(9 * SSticker.mode.thrall_ratio, 1) && !reviveThrallAcquired)
		reviveThrallAcquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. This will, after a short time, bring a dead thrall completely back to life \
		with no bodily defects.</i></span>")
		var/datum/action/cooldown/spell/pointed/revive_thrall/revive = new(M)
		revive.Grant(M)
	if(thralls < victory_threshold)
		to_chat(user, span_shadowling("You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present."))
	else if(thralls >= victory_threshold)
		to_chat(user, span_shadowling("<b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready."))
		to_chat(user, span_shadowling("<b>You may find Ascendance in the Shadowling Evolution tab.</b>"))
		for(M in GLOB.alive_mob_list)
			if(is_shadow(M))
				var/datum/action/cooldown/spell/collective_mind/CM
				if(CM in M.actions)
					M.actions -= CM
					qdel(CM)
				for(var/datum/action/cooldown/spell/shadowling_hatch/hatch in M.actions)
					LAZYREMOVE(M.actions, hatch)
				var/datum/action/cooldown/spell/shadowling_ascend/ascend = new(M)
				ascend.Grant(M)
				if(M == user)
					to_chat(user, span_shadowling("<i>You project this power to the rest of the shadowlings.</i>"))
				else
					to_chat(M, span_shadowling("<b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b>")) //Tells all the other shadowlings

	return TRUE

/datum/action/cooldown/spell/null_charge
	name = "Null Charge"
	desc = "Empties an APC, preventing it from recharging until fixed."
	panel = "Shadowling Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "null_charge"

	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/null_charge/cast(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return FALSE
	if(!shadowling_check(user))
		return

	var/list/local_objs = view(1, user)
	var/obj/machinery/power/apc/target_apc
	for(var/object in local_objs)
		if(istype(object, /obj/machinery/power/apc))
			target_apc = object
			break

	if(!target_apc)
		to_chat(user, span_warning("You must stand next to an APC to drain it!"))
		return

	//Free veil since you have to stand next to the thing for a while to depower it.
	target_apc.set_light(0)
	target_apc.visible_message(span_warning("The [target_apc] flickers and begins to grow dark."))

	to_chat(user, span_shadowling("You dim the APC's screen and carefully begin siphoning its power into the void."))
	if(!do_after(user, 15 SECONDS, target_apc))
		//Whoops!  The APC's light turns back on
		to_chat(user, span_shadowling("Your concentration breaks and the APC suddenly repowers!"))
		target_apc.set_light(2)
		target_apc.visible_message(span_warning("The [target_apc] begins glowing brightly!"))
	else
		//We did it
		to_chat(user, span_shadowling("You return the APC's power to the void, disabling it."))
		target_apc.cell?.charge = 0	//Sent to the shadow realm
		target_apc.chargemode = 0 //Won't recharge either until an engineer hits the button
		target_apc.charging = 0
		target_apc.update_icon()

	return TRUE

/datum/action/cooldown/spell/blindness_smoke //Spawns a cloud of smoke that blinds non-thralls/shadows and grants slight healing to shadowlings and their allies
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	button_icon_state = "black_smoke"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	sound = 'sound/effects/bamf.ogg'
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/blindness_smoke/cast(mob/living/carbon/human/user) //Extremely hacky
	. = ..()
	if(!.)
		return FALSE
	if(!shadowling_check(user))
		return
	user.visible_message(span_warning("[user] bends over and coughs out a cloud of black smoke!"))
	to_chat(user, span_shadowling("You regurgitate a vast cloud of blinding smoke."))
	var/obj/item/reagent_containers/glass/beaker/large/B = new /obj/item/reagent_containers/glass/beaker/large(user.loc) //hacky
	B.reagents.clear_reagents() //Just in case!
	B.invisibility = INFINITY //This ought to do the trick
	B.reagents.add_reagent(/datum/reagent/shadowling_blindness_smoke, 10)
	var/datum/effect_system/fluid_spread/smoke/chem/S = new
	S.attach(B)
	if(S)
		S.set_up(4, location = B.loc, carry = B.reagents)
		S.start()
	qdel(B)
	return TRUE

/datum/action/cooldown/spell/aoe/unearthly_screech //Damages nearby windows, confuses nearby carbons, and outright stuns silly cones
	name = "Sonic Screech"
	desc = "Deafens, stuns, and confuses nearby people. Also shatters windows."
	panel = "Shadowling Abilities"
	button_icon_state = "screech"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	sound = 'sound/effects/screech.ogg'
	aoe_radius = 7
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/aoe/unearthly_screech/cast_on_thing_in_aoe(atom/target_atom, mob/living/user)
	if(!shadowling_check(user))
		return
	user.audible_message(span_warning("<b>[user] lets out a horrible scream!</b>"))
	if(isturf(target))
		var/turf/T = target_atom
		for(var/mob/target in T.contents)
			if(is_shadow_or_thrall(target))
				if(target == user) //No message for the user, of course
					continue
				else
					continue
			if(iscarbon(target))
				var/mob/living/carbon/M = target
				to_chat(M, span_danger("<b>A spike of pain drives into your head and scrambles your thoughts!</b>"))
				M.adjust_confusion(10 SECONDS)
				M.adjustEarDamage(0, 30)//as bad as a changeling shriek
			else if(issilicon(target))
				var/mob/living/silicon/S = target
				to_chat(S, span_warning("<b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b>"))
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread
				sp.set_up(5, 1, S)
				sp.start()
				S.Paralyze(5 SECONDS)
		for(var/obj/structure/window/W in T.contents)
			W.take_damage(rand(80, 100))

/datum/action/cooldown/spell/pointed/empower_thrall //turns a thrall into a lesser shadowling
	name = "Dark Acceleration"
	desc = "Empowers a thrall. You can only have 3 empowered thralls at a time. Empowered thralls become lesser versions of yourself, gaining a small selection of your abilities as well as your healing in the dark and aversion to light."
	panel = "Shadowling Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "darksight"

	cast_range = 1
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/pointed/empower_thral/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!shadowling_check(user))
		return
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/thrallToEmpower = target
	if(!is_thrall(thrallToEmpower))
		to_chat(user, span_warning("[thrallToEmpower] is not a thrall."))
		return
	if(thrallToEmpower.stat != CONSCIOUS)
		to_chat(user, span_warning("[thrallToEmpower] must be conscious to become empowered."))
		return
	if(thrallToEmpower.dna.species.id == "l_shadowling")
		to_chat(user, span_warning("[thrallToEmpower] is already empowered."))
		return
	var/empowered_thralls = 0
	for(var/datum/mind/M in SSticker.mode.thralls)
		if(!ishuman(M.current))
			return
		var/mob/living/carbon/human/H = M.current
		if(H.dna.species.id == "l_shadowling")
			empowered_thralls++
	if(empowered_thralls >= EMPOWERED_THRALL_LIMIT)
		to_chat(user, span_warning("You cannot spare this much energy. There are too many empowered thralls."))
		return
	user.visible_message(span_danger("[user] places their hands over [thrallToEmpower]'s face, red light shining from beneath."), \
						span_shadowling("You place your hands on [thrallToEmpower]'s face and begin gathering energy..."))
	to_chat(thrallToEmpower, span_userdanger("[user] places their hands over your face. You feel energy gathering. Stand still..."))
	if(!do_mob(user, thrallToEmpower, 8 SECONDS))
		to_chat(user, span_warning("Your concentration snaps. The flow of energy ebbs."))
		return
	to_chat(user, span_shadowling("<b><i>You release a massive surge of power into [thrallToEmpower]!</b></i>"))
	user.visible_message(span_boldannounce("<i>Red lightning surges into [thrallToEmpower]'s face!</i>"))
	playsound(thrallToEmpower, 'sound/weapons/Egloves.ogg', 50, 1)
	playsound(thrallToEmpower, 'sound/machines/defib_zap.ogg', 50, 1)
	user.Beam(thrallToEmpower,icon_state="red_lightning",time=1)
	thrallToEmpower.Knockdown(5)
	thrallToEmpower.visible_message(span_warning("<b>[thrallToEmpower] collapses, their skin and face distorting!"), \
								   span_userdanger("<i>AAAAAAAAAAAAAAAAAAAGH-</i>"))
	if (!do_mob(user, thrallToEmpower, 5))
		thrallToEmpower.Unconscious(1 MINUTES)
		thrallToEmpower.visible_message(span_warning("<b>[thrallToEmpower] gasps, and passes out!</b>"), span_warning("<i>That... feels nice....</i>"))
		to_chat(user, span_warning("We have been interrupted! [thrallToEmpower] will need to rest to recover."))
		return
	thrallToEmpower.visible_message(span_warning("[thrallToEmpower] slowly rises, no longer recognizable as human."), \
								   "<span class='shadowling'><b>You feel new power flow into you. You have been gifted by your masters. You now closely resemble them. You are empowered in \
									darkness but wither slowly in light. In addition, Lesser Glare has been upgraded into it's true form, and you've been given the ability to turn off nearby lights.</b></span>")
	thrallToEmpower.set_species(/datum/species/shadow/ling/lesser)
	for(var/datum/action/cooldown/spell/pointed/lesser_glare/lglare in thrallToEmpower.actions)
		LAZYREMOVE(thrallToEmpower.actions, lglare)

	var/datum/action/cooldown/spell/pointed/sling/glare/sglare = new(thrallToEmpower)
	sglare.Grant(thrallToEmpower)

	var/datum/action/cooldown/spell/aoe/veil/veil = new(thrallToEmpower)
	veil.Grant(thrallToEmpower)

	var/datum/action/cooldown/spell/jaunt/void_jaunt/jaunt = new(thrallToEmpower)
	jaunt.Grant(thrallToEmpower)

/datum/action/cooldown/spell/pointed/revive_thrall //Completely revives a dead thrall
	name = "Black Recuperation"
	desc = "Revives or empowers a thrall."
	panel = "Shadowling Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "revive_thrall"

	cast_range = 1
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/pointed/revive_thrall/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!shadowling_check(user))
		return
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/thrallToRevive = target
	if(!is_thrall(thrallToRevive))
		to_chat(user, span_warning("[thrallToRevive] is not a thrall."))
		return
	if(thrallToRevive.stat != DEAD)
		to_chat(user, span_warning("[thrallToRevive] is not dead."))
		return
	if(HAS_TRAIT(thrallToRevive, TRAIT_BADDNA))
		to_chat(user, span_warning("[thrallToRevive] is too far gone."))
		return

	user.visible_message(span_danger("[user] kneels over [thrallToRevive], placing their hands on \his chest."), \
						span_shadowling("You crouch over the body of your thrall and begin gathering energy..."))
	thrallToRevive.notify_ghost_cloning("Your masters are resuscitating you! Re-enter your corpse if you wish to be brought to life.", source = thrallToRevive)
	if(!do_mob(user, thrallToRevive, 30))
		to_chat(user, span_warning("Your concentration snaps. The flow of energy ebbs."))
		return
	to_chat(user, span_shadowling("<b><i>You release a massive surge of power into [thrallToRevive]!</b></i>"))
	user.visible_message(span_boldannounce("<i>Red lightning surges from [user]'s hands into [thrallToRevive]'s chest!</i>"))
	playsound(thrallToRevive, 'sound/weapons/Egloves.ogg', 50, 1)
	playsound(thrallToRevive, 'sound/machines/defib_zap.ogg', 50, 1)
	user.Beam(thrallToRevive,icon_state="red_lightning",time=1)
	var/b = do_mob(user, thrallToRevive, 20)
	if(thrallToRevive.revive(full_heal = 1))
		thrallToRevive.visible_message(span_boldannounce("[thrallToRevive] heaves in breath, dim red light shining in their eyes."), \
									   span_shadowling("<b><i>You have returned. One of your masters has brought you from the darkness beyond.</b></i>"))
		thrallToRevive.Knockdown(4)
		thrallToRevive.emote("gasp")
		playsound(thrallToRevive, "bodyfall", 50, 1)
		if (!b)
			thrallToRevive.Knockdown(50)
			thrallToRevive.Unconscious(500)
			thrallToRevive.visible_message(span_boldannounce("[thrallToRevive] collapses in exhaustion."), \
				 span_warning("<b><i>You collapse in exhaustion... nap..... dark.</b></i>"))
	
	return TRUE

/datum/action/cooldown/spell/pointed/shadowling_extend_shuttle
	name = "Destroy Engines"
	desc = "Sacrifice a thrall to extend the time of the emergency shuttle's arrival by fifteen minutes. This can only be used once."
	panel = "Shadowling Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "extend_shuttle"

	cast_range = 1
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/pointed/shadowling_extend_shuttle/InterceptClickOn(mob/living/user, params, atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!shadowling_check(user))
		return
	if(!ishuman(target_atom))
		return
	var/mob/living/carbon/human/target = target_atom
	if(target.stat)
		return
	if(!is_thrall(target))
		to_chat(user, span_warning("[target] must be a thrall."))
		return
	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		to_chat(user, "span class='warning'>The shuttle must be inbound only to the station.</span>")
		return
	var/mob/living/carbon/human/M = target
	user.visible_message(span_warning("[user]'s eyes flash a bright red!"), \
					  span_notice("You begin to draw [M]'s life force."))
	M.visible_message(span_warning("[M]'s face falls slack, their jaw slightly distending."), \
					  span_boldannounce("You are suddenly transported... far, far away..."))
	if(!do_after(user, 5 SECONDS, M))
		to_chat(M, span_warning("You are snapped back to reality, your haze dissipating!"))
		to_chat(user, span_warning("You have been interrupted. The draw has failed."))
		return
	to_chat(user, span_notice("You project [M]'s life force toward the approaching shuttle, extending its arrival duration!"))
	M.visible_message(span_warning("[M]'s eyes suddenly flare red. They proceed to collapse on the floor, not breathing."), \
						 span_warning("<b>...speeding by... ...pretty blue glow... ...touch it... ...no glow now... ...no light... ...nothing at all..."))
	M.dust()

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/more_minutes = 9000
		var/timer = SSshuttle.emergency.timeLeft()
		timer += more_minutes
		priority_announce("Major system failure aboard the emergency shuttle. This will extend its arrival time by approximately 15 minutes...", "System Failure", 'sound/misc/notice1.ogg')
		SSshuttle.emergency.setTimer(timer)
		SSshuttle.emergencyNoRecall = TRUE
	user.actions.Remove(src) //Can only be used once!
	qdel(src)
	
	return TRUE

//Loosely adapted from the Nightmare's Shadow Walk, but different enough that
//inheriting would have been more hacky code.
//Unlike Shadow Walk, jaunting shadowlings can move through lit areas unmolested,
//but take a constant stamina penalty while jaunting.
/datum/action/cooldown/spell/jaunt/void_jaunt
	name = "Void Jaunt"
	desc = "Move through the void for a time, avoiding mortal eyes and lights."
	panel = "Shadowling Abilities"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "jaunt"

	cooldown_time = 80 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN
	var/apply_damage = TRUE

/datum/action/cooldown/spell/jaunt/void_jaunt/cast(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(iscarbon(user))	//If we're not an ascendant sling
		var/mob/living/carbon/C = user
		if(C.on_fire)
			user.visible_message(span_boldwarning("[user]'s body shudders and flickers into darkness for a moment!"),
													span_shadowling("The void rejects the flames engulfing your body, throwing you back into the burning light!"))									
			return
	if(!shadowling_check(user) && !istype(user, /mob/living/simple_animal/ascendant_shadowling))
		return
	if(is_jaunting(user))
		exit_jaunt()
		return
	else
		playsound(get_turf(user), 'sound/magic/ethereal_enter.ogg', 50, 1, -1)
		if(apply_damage)
			user.visible_message(span_boldwarning("[user] melts into the shadows!"),
													span_shadowling("Steeling yourself, you dive into the void."))
		else
			user.visible_message(span_boldwarning("[user] melts into the shadows!"),
													span_shadowling("You allow yourself to fall into the void."))
		user.SetAllImmobility(0)
		user.setStaminaLoss(0, 0)
		var/obj/effect/dummy/phased_mob/shadowling/S2 = new(get_turf(user.loc))
		S2.apply_damage = apply_damage
		user.forceMove(S2)
		S2.jaunter = user
		S2.jaunt_spell = src

	return TRUE

//Both have to be high to cancel out natural regeneration
#define VOIDJAUNT_STAM_PENALTY_DARK 10
#define VOIDJAUNT_STAM_PENALTY_LIGHT 35

/obj/effect/dummy/phased_mob/shadowling
	name = "darkness"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = TRUE
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/apply_damage = TRUE
	var/move_delay = 0			//Time until next move allowed
	var/move_speed = 2			//Deciseconds per move

	var/datum/action/cooldown/spell/jaunt/void_jaunt/jaunt_spell //what spell we actually came from (for forced cooldown)

/obj/effect/dummy/phased_mob/shadowling/relaymove(mob/user, direction)
	if(move_delay > world.time && apply_damage)	//Ascendants get no slowdown
		return

	move_delay = world.time + move_speed
	var/turf/newLoc = get_step(src,direction)
	forceMove(newLoc)

/obj/effect/dummy/phased_mob/shadowling/proc/check_light_level()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(!isliving(jaunter))
		return
	var/mob/living/jaunter_living = jaunter
	if(light_amount > LIGHT_DAM_THRESHOLD)	//Increased penalty
		jaunter_living.apply_damage(VOIDJAUNT_STAM_PENALTY_LIGHT, STAMINA)
	else
		jaunter_living.apply_damage(VOIDJAUNT_STAM_PENALTY_DARK, STAMINA)

/obj/effect/dummy/phased_mob/shadowling/eject_jaunter(mob/living/unjaunter, turf/loc_override, forced)
	if(unjaunter)
		unjaunter.forceMove(get_turf(src))
		if(forced)
			unjaunter.visible_message(span_boldwarning("A dark shape stumbles from a hole in the air and collapses!"),
															span_shadowling("<b>Straining, you use the last of your energy to force yourself from the void.</b>"))
		else
			unjaunter.visible_message(span_boldwarning("A dark shape tears itself from nothingness!"),
															span_shadowling("You exit the void."))

		playsound(get_turf(jaunter), 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
		jaunt_spell?.StartCooldown()
		jaunter = null
	qdel(src)

/obj/effect/dummy/phased_mob/shadowling/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/shadowling/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/dummy/phased_mob/shadowling/process()
	if(!jaunter)
		qdel(src)
	if(jaunter.loc != src)
		qdel(src)

	if(apply_damage)
		check_light_level()

		//True if jaunter entered stamcrit
		var/mob/living/jaunter_living = jaunter
		if(jaunter_living.IsParalyzed())
			eject_jaunter(forced = TRUE)
			return

/obj/effect/dummy/phased_mob/shadowling/ex_act()
	return

/obj/effect/dummy/phased_mob/shadowling/bullet_act()
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/shadowling/singularity_act()
	return

#undef VOIDJAUNT_STAM_PENALTY_DARK
#undef VOIDJAUNT_STAM_PENALTY_LIGHT


// THRALL ABILITIES BEYOND THIS POINT //
/datum/action/cooldown/spell/pointed/lesser_glare //a defensive ability, nothing else. can't be used to stun people, steal tasers, etc. Just good for escaping
	name = "Lesser Glare"
	desc = "Makes a single target dizzy for a bit."
	panel = "Thrall Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "glare"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	cooldown_time = 45 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/pointed/lesser_glare/InterceptClickOn(mob/living/carbon/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_EYES))
		to_chat(user, span_warning("You need eyes to glare!"))
		return
	if(!ishuman(target) || !target)
		to_chat(user, span_warning("You may only glare at humans!"))
		return
	var/mob/living/carbon/human/M = target
	if(M.stat)
		to_chat(user, span_warning("[target] must be conscious!"))
		return
	if(is_shadow_or_thrall(M))
		to_chat(user, span_warning("You cannot glare at allies!"))
		return
	user.visible_message(span_warning("<b>[user]'s eyes flash a bright red!</b>"))
	target.visible_message(span_danger("[target] suddendly looks dizzy and nauseous..."))
	if(in_range(target, user))
		to_chat(target, span_userdanger("Your gaze is forcibly drawn into [user]'s eyes, and you suddendly feel dizzy and nauseous..."))
	else //Only alludes to the thrall if the target is close by
		to_chat(target, span_userdanger("Red lights suddenly dance in your vision, and you suddendly feel dizzy and nauseous..."))
	M.adjust_confusion(25 SECONDS)
	M.adjust_jitter(50 SECONDS)
	if(prob(25))
		M.vomit(10)

	return TRUE

/datum/action/cooldown/spell/lesser_shadow_walk //Thrall version of Shadow Walk, only works in darkness, doesn't grant phasing, but gives near-invisibility
	name = "Guise"
	desc = "Wraps your form in shadows, making you harder to see."
	panel = "Thrall Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "shadow_walk"

	cooldown_time = 2 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/lesser_shadow_walk/proc/reappear(mob/living/carbon/human/user)
	user.visible_message(span_warning("[user] appears from nowhere!"), span_shadowling("Your shadowy guise slips away."))
	user.alpha = initial(user.alpha)

/datum/action/cooldown/spell/lesser_shadow_walk/cast(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return FALSE
	user.visible_message(span_warning("[user] suddenly fades away!"), span_shadowling("You veil yourself in darkness, making you harder to see."))
	user.alpha = 10
	addtimer(CALLBACK(src, PROC_REF(reappear), user), 10 SECONDS)
	
	return TRUE

/datum/action/cooldown/spell/thrall_night_vision //Toggleable night vision for thralls
	name = "Thrall Darksight"
	desc = "Allows you to see in the dark!"
	button_icon_state = "darksight"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	spell_requirements = NONE

/datum/action/cooldown/spell/thrall_night_vision/cast(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return FALSE
	if(!is_shadow_or_thrall(user))
		return
	var/obj/item/organ/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		return
	eyes.sight_flags = initial(eyes.sight_flags)
	switch(eyes.lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			eyes.see_in_dark = 8
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			eyes.see_in_dark = 2	//default
	user.update_sight()

	return TRUE

/datum/action/cooldown/spell/lesser_shadowling_hivemind //Lets a thrall talk with their allies
	name = "Lesser Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Thrall Abilities"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "commune"

	cooldown_time = 5 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/lesser_shadowling_hivemind/cast(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return FALSE
	if(!is_shadow_or_thrall(user))
		to_chat(user, span_warning("<b>As you attempt to commune with the others, an agonizing spike of pain drives itself into your head!</b>"))
		user.apply_damage(10, BRUTE, "head")
		return
	var/text = stripped_input(user, "What do you want to say your masters and fellow thralls?.", "Lesser Commune", "")
	if(!text)
		return
	text = span_shadowling("<b>\[Thrall\]</b><i> [user.real_name]</i>: [text]")
	for(var/T in GLOB.alive_mob_list)
		var/mob/M = T
		if(is_shadow_or_thrall(M))
			to_chat(M, text)
		if(isobserver(M))
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [text]")
	log_say("[user.real_name]/[user.key] : [text]")

	return TRUE

// ASCENDANT ABILITIES BEYOND THIS POINT //
// YES THEY'RE OP, BUT THEY'VE WON AT THE POINT WHERE THEY HAVE THIS, SO WHATEVER. //
/datum/action/cooldown/spell/pointed/sling/annihilate //Gibs someone instantly.
	name = "Annihilate"
	desc = "Gibs someone instantly."
	panel = "Ascendant"
	button_icon_state = "annihilate"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	sound = 'sound/magic/Staff_Chaos.ogg'
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/sling/annihilate/InterceptClickOn(mob/living/caller, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/boom = target
	if(user.incorporeal_move)
		to_chat(user, span_warning("You are not in the same plane of existence. Unphase first."))
		revert_cast()
		return
	if(is_shadow(boom)) //Used to not work on thralls. Now it does so you can PUNISH THEM LIKE THE WRATHFUL GOD YOU ARE.
		to_chat(user, "<span class='warning'>Making an ally explode seems unwise.<span>")
		revert_cast()
		return
	if(istype(boom, /mob/living/simple_animal/pet/dog/corgi))
		to_chat(user, "<span class='warning'>Not even we are that bad of monsters..<span>")
		revert_cast()
		return
	if (!boom.is_holding(/obj/item/storage/backpack/holding)) //so people actually have a chance to kill ascended slings without being insta-sploded
		user.visible_message(span_warning("[user]'s markings flare as they gesture at [boom]!"), \
							span_shadowling("You direct a lance of telekinetic energy into [boom]."))
		if(iscarbon(boom))
			playsound(boom, 'sound/magic/Disintegrate.ogg', 100, 1)
		boom.visible_message(span_userdanger("[boom] explodes!"))
		boom.gib()
	else
		to_chat(user, "<span class='warning'>The telekinetic energy is absorbed by the bluespace portal in [boom]'s hand!<span>")
		to_chat(boom, "<span class='userdanger'>You feel a slight recoil from the bag of holding!<span>")

/datum/action/cooldown/spell/pointed/sling/hypnosis //Enthralls someone instantly. Nonlethal alternative to Annihilate
	name = "Hypnosis"
	desc = "Instantly enthralls a human."
	panel = "Ascendant"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "enthrall"
	
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/sling/hypnosis/InterceptClickOn(mob/living/caller, params, atom/target_atom)
	. = ..()
	if(!.)
		return
	if(!iscarbon(target_atom))
		return
	var/mob/living/carbon/target = target_atom
	if(user.incorporeal_move)
		revert_cast()
		to_chat(user, span_warning("You are not in the same plane of existence. Unphase first."))
		return
	if(is_shadow_or_thrall(target))
		to_chat(user, span_warning("You cannot enthrall an ally."))
		revert_cast()
		return
	if(!target.ckey || !target.mind)
		to_chat(user, span_warning("The target has no mind."))
		revert_cast()
		return
	if(target.stat)
		to_chat(user, span_warning("The target must be conscious."))
		revert_cast()
		return
	if(!ishuman(target))
		to_chat(user, span_warning("You can only enthrall humans."))
		revert_cast()
		return
	to_chat(user, span_shadowling("You instantly rearrange <b>[target]</b>'s memories, hyptonitizing them into a thrall."))
	to_chat(target, span_userdanger("<font size=3>An agonizing spike of pain drives into your mind, and--</font>"))
	target.mind.special_role = "thrall"
	target.add_thrall()

/datum/action/cooldown/spell/aoe/ascendant_storm //Releases bolts of lightning to everyone nearby
	name = "Lightning Storm"
	desc = "Shocks everyone nearby."
	panel = "Ascendant"
	button_icon_state = "lightning_storm"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	sound = 'sound/magic/lightningbolt.ogg'
	aoe_radius = 6
	cooldown_time = 10 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/aoe/ascendant_storm/cast_on_thing_in_aoe(turf/victim, mob/living/user)
	if(user.incorporeal_move)
		to_chat(user, span_warning("You are not in the same plane of existence. Unphase first."))
		return
	user.visible_message(span_warning("<b>A massive ball of lightning appears in [user]'s hands and flares out!</b>"), \
						span_shadowling("You conjure a ball of lightning and release it."))
	for(var/mob/living/carbon/human/target in view(aoe_radius))
		if(is_shadow_or_thrall(target))
			continue
		to_chat(target, span_userdanger("You're struck by a bolt of lightning!"))
		target.apply_damage(10, BURN)
		playsound(target, 'sound/magic/LightningShock.ogg', 50, 1)
		target.Knockdown(8 SECONDS)
		user.Beam(target,icon_state="red_lightning",time=10)

/datum/action/cooldown/spell/shadowling_hivemind_ascendant //Large, all-caps text in shadowling chat
	name = "Ascendant Commune"
	desc = "Allows you to LOUDLY communicate with all other shadowlings and thralls."
	panel = "Ascendant"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "commune"

	spell_requirements = NONE

/datum/action/cooldown/spell/shadowling_hivemind_ascendant/cast(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return FALSE
	var/text = sanitize(tgui_input_text(user, "What do you want to say to fellow thralls and shadowlings?.", "Hive Chat", ""))
	if(!text)
		return
	text = "<font size=4><span class='shadowling'><b>\[Ascendant\]<i> [user.real_name]</i>: [text]</b></span></font>"
	for(var/mob/M in GLOB.mob_list)
		if(is_shadow_or_thrall(M))
			to_chat(M, text)
		if(isobserver(M))
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [text]")
	log_say("[user.real_name]/[user.key] : [text]")

/datum/action/cooldown/spell/pointed/sling/instant_enthrall //Enthralls someone instantly. Nonlethal alternative to Annihilate
	name = "Subjugate"
	desc = "Instantly enthrall a weakling."
	panel = "Ascendant"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "gore"

	spell_requirements = NONE

/datum/action/cooldown/spell/jaunt/void_jaunt/ascendant
	name = "Void Walk"
	desc = "Move invisibly through the void between worlds, shielded from mortal eyes."
	panel = "Ascendant"

	apply_damage = FALSE
