//In here: Hatch and Ascendance
/datum/action/cooldown/spell/shadowling_hatch
	name = "Hatch"
	desc = "Casts off your disguise."
	panel = "Shadowling Evolution"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "hatch"

	cooldown_time = 5 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN

/obj/structure/alien/resin/wall/shadowling //For chrysalis
	name = "chrysalis wall"
	desc = "Some sort of purple substance in an egglike shape. It pulses and throbs from within and seems impenetrable."
	max_integrity = INFINITY

/datum/action/cooldown/spell/shadowling_hatch/cast(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(user.stat || !ishuman(user) || !user || !is_shadow(user) || user.isinspace())
		return
	var/mob/living/carbon/human/H = user
	var/hatch_or_no = tgui_alert(H,"Are you sure you want to hatch? You cannot undo this!","Ello",list("Yes","No"))
	switch(hatch_or_no)
		if("No")
			to_chat(H, span_warning("You decide against hatching for now."))
			return
		if("Yes")
			H.notransform = TRUE
			H.visible_message(span_warning("[H]'s things suddenly slip off. They hunch over and vomit up a copious amount of purple goo which begins to shape around them!"), \
							span_shadowling("You remove any equipment which would hinder your hatching and begin regurgitating the resin which will protect you."))
			var/temp_flags = H.status_flags
			H.status_flags |= GODMODE //Can't die while hatching
			H.unequip_everything()
			if(!do_mob(H,H,50,1))
				return
			var/turf/shadowturf = get_turf(user)
			for(var/turf/open/floor/F in orange(1, user))
				new /obj/structure/alien/resin/wall/shadowling(F)
			for(var/obj/structure/alien/resin/wall/shadowling/R in shadowturf) //extremely hacky
				qdel(R)
				new /obj/structure/alien/weeds/node(shadowturf) //Dim lighting in the chrysalis -- removes itself afterwards
			H.visible_message(span_warning("A chrysalis forms around [H], sealing them inside."), \
							span_shadowling("You create your chrysalis and begin to contort within."))
			if(!do_mob(H,H,100,1))
				return
			H.visible_message(span_warning("<b>The skin on [H]'s back begins to split apart. Black spines slowly emerge from the divide.</b>"), \
							span_shadowling("Spines pierce your back. Your claws break apart your fingers. You feel excruciating pain as your true form begins its exit."))
			if(!do_mob(H,H,90,1))
				return
			H.visible_message(span_warning("<b>[H], skin shifting, begins tearing at the walls around them.</b>"), \
							span_shadowling("Your false skin slips away. You begin tearing at the fragile membrane protecting you."))
			if(!do_mob(H,H,80,1))
				return
			playsound(H.loc, 'sound/weapons/slash.ogg', 25, 1)
			to_chat(H, "<i><b>You rip and slice.</b></i>")
			if(!do_mob(H,H,10,1))
				return
			playsound(H.loc, 'sound/weapons/slashmiss.ogg', 25, 1)
			to_chat(H, "<i><b>The chrysalis falls like water before you.</b></i>")
			if(!do_mob(H,H,10,1))
				return
			playsound(H.loc, 'sound/weapons/slice.ogg', 25, 1)
			to_chat(H, "<i><b>You are free!</b></i>")
			H.status_flags = temp_flags
			if(!do_mob(H,H,10,1))
				return
			playsound(H.loc, 'sound/effects/ghost.ogg', 100, 1)
			var/newNameId = pick(GLOB.nightmare_names)
			var/oldName = H.real_name
			GLOB.nightmare_names.Remove(newNameId)
			H.real_name = newNameId
			H.name = user.real_name
			H.notransform = FALSE
			to_chat(H, "<i><b><font size=3>YOU LIVE!!!</i></b></font>")
			var/hatchannounce = "<font size=3><span class='shadowling'><b>[oldName] has hatched into the Shadowling [newNameId]!</b></span></font>"
			for(var/T in GLOB.alive_mob_list)
				var/mob/M = T
				if(is_shadow_or_thrall(M))
					to_chat(M, hatchannounce)
			for(var/T in GLOB.dead_mob_list)
				var/mob/M = T
				to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [hatchannounce]")
			for(var/obj/structure/alien/resin/wall/shadowling/W in orange(1, H))
				playsound(W, 'sound/effects/splat.ogg', 50, 1)
				qdel(W)
			for(var/obj/structure/alien/weeds/node/N in shadowturf)
				qdel(N)
			H.visible_message(span_warning("The chrysalis explodes in a shower of purple flesh and fluid!"))
			H.underwear = "Nude"
			H.undershirt = "Nude"
			H.socks = "Nude"
			H.faction |= "faithless"
			for(var/datum/antagonist/shadowling/antag_datum in H.mind.antag_datums)
				antag_datum.show_to_ghosts = TRUE
			H.LoadComponent(/datum/component/walk/shadow)

			H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(H), SLOT_WEAR_SUIT)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(H), SLOT_HEAD)
			H.set_species(/datum/species/shadow/ling) //can't be a shadowling without being a shadowling
			H.dna.remove_all_mutations(list(MUT_NORMAL, MUT_EXTRA), TRUE)
			Remove(H)
			if(!do_mob(H,H,10,1))
				return
			to_chat(H, span_shadowling("<b><i>Your powers are awoken. You may now live to your fullest extent. Remember your goal. Cooperate with your thralls and allies.</b></i>"))

			var/datum/action/cooldown/spell/pointed/enthrall/enthrall = new(H)
			enthrall.Grant(H)

			var/datum/action/cooldown/spell/pointed/sling/glare/glare = new(H)
			glare.Grant(H)

			var/datum/action/cooldown/spell/aoe/veil/veil = new(H)
			veil.Grant(H)

			var/datum/action/cooldown/spell/jaunt/void_jaunt/void_jaunt = new(H)
			void_jaunt.Grant(H)

			var/datum/action/cooldown/spell/jaunt/shadow_walk/shadow_walk = new(H)
			shadow_walk.Grant(H)

			var/datum/action/cooldown/spell/aoe/flashfreeze/flashfreeze = new(H)
			flashfreeze.Grant(H)

			var/datum/action/cooldown/spell/collective_mind/mind = new(H)
			mind.Grant(H)
	
			var/datum/action/cooldown/spell/shadowling_regenarmor/regen_armor = new(H)
			regen_armor.Grant(H)

			var/datum/action/cooldown/spell/pointed/shadowling_extend_shuttle/shuttle_extend = new(H)
			shuttle_extend.Grant(H)
	
	return TRUE

/datum/action/cooldown/spell/shadowling_ascend
	name = "Ascend"
	desc = "Enters your true form."
	panel = "Shadowling Evolution"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "ascend"

	cooldown_time = 5 MINUTES
	spell_requirements = NONE

/datum/action/cooldown/spell/shadowling_ascend/before_cast(mob/living/user)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = user
	if(!shadowling_check(H))
		return
	var/hatch_or_no = tgui_alert(H,"It is time to ascend. Are you sure about this?",,list("Yes","No"))
	switch(hatch_or_no)
		if("No")
			to_chat(H, span_warning("You decide against ascending for now."))
			return
		if("Yes")
			H.notransform = 1
			H.visible_message(span_warning("[H]'s things suddenly slip off. They gently rise into the air, red light glowing in their eyes."), \
							span_shadowling("You rise into the air and get ready for your transformation."))
			for(var/obj/item/I in H) //drops all items
				H.unequip_everything(I)
			if(!do_mob(H,H,50,1))
				return
			H.visible_message(span_warning("[H]'s skin begins to crack and harden."), \
							span_shadowling("Your flesh begins creating a shield around yourself."))
			if(!do_mob(H,H,100,1))
				return
			H.visible_message(span_warning("The small horns on [H]'s head slowly grow and elongate."), \
								span_shadowling("Your body continues to mutate. Your telepathic abilities grow.")) //y-your horns are so big, senpai...!~
			if(!do_mob(H,H,90,1))
				return
			H.visible_message(span_warning("[H]'s body begins to violently stretch and contort."), \
								span_shadowling("You begin to rend apart the final barriers to godhood."))
			if(!do_mob(H,H,40,1))
				return
			to_chat(H, "<i><b>Yes!</b></i>")
			if(!do_mob(H,H,10,1))
				return
			to_chat(H, "<i><b>[span_big("YES!!")]</b></i>")
			if(!do_mob(H,H,10,1))
				return
			to_chat(H, "<i><b>[span_reallybig("YE--")]</b></i>")
			if(!do_mob(H,H,1,1))
				return
			for(var/mob/living/M in orange(7, H))
				M.Knockdown(10)
				to_chat(M, span_userdanger("An immense pressure slams you onto the ground!"))
			send_to_playing_players("<font size=5><span class='shadowling'><b>\"VYSHA NERADA YEKHEZET U'RUU!!\"</font></span>")
			sound_to_playing_players('sound/hallucinations/veryfar_noise.ogg')
			for(var/obj/machinery/power/apc/A in GLOB.apcs_list)
				A.overload_lighting()
			SSachievements.unlock_achievement(/datum/achievement/greentext/slingascend, H.client)
			var/mob/A = new /mob/living/simple_animal/ascendant_shadowling(H.loc)
			for(var/datum/action/spell in H.actions)
				if(spell == src)
					continue
				spell.Remove(H)
			H.mind.transfer_to(A)
			A.name = H.real_name
			if(A.real_name)
				A.real_name = H.real_name
			H.invisibility = 60 //This is pretty bad, but is also necessary for the shuttle call to function properly
			H.forceMove(A)
			if(!SSticker.mode.shadowling_ascended)
				set_security_level(SEC_LEVEL_GAMMA)
				SSshuttle.emergencyCallTime = 1800
				SSshuttle.emergency.request(null, 0.3)
				SSshuttle.emergencyNoRecall = TRUE
				SSticker.mode.shadowling_ascended = TRUE
			var/datum/action/cooldown/spell/pointed/sling/annihilate/annihilate = new(A)
			annihilate.Grant(A)

			var/datum/action/cooldown/spell/pointed/sling/hypnosis/hypnosis = new(A)
			hypnosis.Grant(A)

			var/datum/action/cooldown/spell/aoe/ascendant_storm/storm = new(A)
			storm.Grant(A)

			var/datum/action/cooldown/spell/jaunt/void_jaunt/ascendant/jaunt = new(A)
			jaunt.Grant(A)

			var/datum/action/cooldown/spell/shadowling_hivemind_ascendant/hivemind = new(A)
			hivemind.Grant(A)
			Remove(A)
			qdel(H)
