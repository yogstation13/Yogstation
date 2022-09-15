//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/shadow_mend
	id = "shadow_mend"
	duration = 30
	alert_type = /obj/screen/alert/status_effect/shadow_mend

/obj/screen/alert/status_effect/shadow_mend
	name = "Shadow Mend"
	desc = "Shadowy energies wrap around your wounds, sealing them at a price. After healing, you will slowly lose health every three seconds for thirty seconds."
	icon_state = "shadow_mend"

/datum/status_effect/shadow_mend/on_apply()
	owner.visible_message(span_notice("Violet light wraps around [owner]'s body!"), span_notice("Violet light wraps around your body!"))
	playsound(owner, 'sound/magic/teleport_app.ogg', 50, 1)
	return ..()

/datum/status_effect/shadow_mend/tick()
	owner.adjustBruteLoss(-15)
	owner.adjustFireLoss(-15)

/datum/status_effect/shadow_mend/on_remove()
	owner.visible_message(span_warning("The violet light around [owner] glows black!"), span_warning("The tendrils around you cinch tightly and reap their toll..."))
	playsound(owner, 'sound/magic/teleport_diss.ogg', 50, 1)
	owner.apply_status_effect(STATUS_EFFECT_VOID_PRICE)


/datum/status_effect/void_price
	id = "void_price"
	duration = 300
	tick_interval = 30
	alert_type = /obj/screen/alert/status_effect/void_price

/obj/screen/alert/status_effect/void_price
	name = "Void Price"
	desc = "Black tendrils cinch tightly against you, digging wicked barbs into your flesh."
	icon_state = "shadow_mend"

/datum/status_effect/void_price/tick()
	SEND_SOUND(owner, sound('sound/magic/summon_karp.ogg', volume = 25))
	owner.adjustBruteLoss(3)


/datum/status_effect/vanguard_shield
	id = "vanguard"
	duration = 200
	tick_interval = 0 //tick as fast as possible
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /obj/screen/alert/status_effect/vanguard
	var/datum/progressbar/progbar

/obj/screen/alert/status_effect/vanguard
	name = "Vanguard"
	desc = "You're absorbing stuns! 25% of all stuns taken will affect you after this effect ends."
	icon_state = "vanguard"
	alerttooltipstyle = "clockcult"

/obj/screen/alert/status_effect/vanguard/MouseEntered(location,control,params)
	var/mob/living/L = usr
	if(istype(L)) //this is probably more safety than actually needed
		var/vanguard = L.stun_absorption["vanguard"]
		desc = initial(desc)
		desc += "<br><b>[FLOOR(vanguard["stuns_absorbed"] * 0.1, 1)]</b> seconds of stuns held back.\
		[GLOB.ratvar_awakens ? "":"<br><b>[FLOOR(min(vanguard["stuns_absorbed"] * 0.025, 20), 1)]</b> seconds of stun will affect you."]"
	..()

/datum/status_effect/vanguard_shield/Destroy()
	qdel(progbar)
	progbar = null
	return ..()

/datum/status_effect/vanguard_shield/on_apply()
	owner.log_message("gained Vanguard stun immunity", LOG_ATTACK)
	owner.add_stun_absorption("vanguard", INFINITY, 1, "'s yellow aura momentarily intensifies!", "Your ward absorbs the stun!", " radiating with a soft yellow light!")
	owner.visible_message(span_warning("[owner] begins to faintly glow!"), span_brass("You will absorb all stuns for the next twenty seconds."))
	owner.SetStun(0, FALSE)
	owner.SetKnockdown(0, FALSE)
	owner.SetParalyzed(0, FALSE)
	owner.SetImmobilized(0)
	progbar = new(owner, duration, owner)
	progbar.bar.color = list("#FAE48C", "#FAE48C", "#FAE48C", rgb(0,0,0))
	progbar.update(duration - world.time)
	return ..()

/datum/status_effect/vanguard_shield/tick()
	progbar.update(duration - world.time)

/datum/status_effect/vanguard_shield/on_remove()
	var/vanguard = owner.stun_absorption["vanguard"]
	var/stuns_blocked = 0
	if(vanguard)
		stuns_blocked = FLOOR(min(vanguard["stuns_absorbed"] * 0.25, 400), 1)
		vanguard["end_time"] = 0 //so it doesn't absorb the stuns we're about to apply
	if(owner.stat != DEAD)
		var/message_to_owner = span_warning("You feel your Vanguard quietly fade...")
		var/otheractiveabsorptions = FALSE
		for(var/i in owner.stun_absorption)
			if(owner.stun_absorption[i]["end_time"] > world.time && owner.stun_absorption[i]["priority"] > vanguard["priority"])
				otheractiveabsorptions = TRUE
		if(!GLOB.ratvar_awakens && stuns_blocked && !otheractiveabsorptions)
			owner.Paralyze(stuns_blocked)
			message_to_owner = span_boldwarning("The weight of the Vanguard's protection crashes down upon you!")
			if(stuns_blocked >= 300)
				message_to_owner += "\n[span_userdanger("You faint from the exertion!")]"
				stuns_blocked *= 2
				owner.Unconscious(stuns_blocked)
		else
			stuns_blocked = 0 //so logging is correct in cases where there were stuns blocked but we didn't stun for other reasons
		owner.visible_message(span_warning("[owner]'s glowing aura fades!"), message_to_owner)
		owner.log_message("lost Vanguard stun immunity[stuns_blocked ? "and was stunned for [stuns_blocked]":""]", LOG_ATTACK)


/datum/status_effect/inathneqs_endowment
	id = "inathneqs_endowment"
	duration = 150
	alert_type = /obj/screen/alert/status_effect/inathneqs_endowment

/obj/screen/alert/status_effect/inathneqs_endowment
	name = "Inath-neq's Endowment"
	desc = "Adrenaline courses through you as the Resonant Cogwheel's energy shields you from all harm!"
	icon_state = "inathneqs_endowment"
	alerttooltipstyle = "clockcult"

/datum/status_effect/inathneqs_endowment/on_apply()
	owner.log_message("gained Inath-neq's invulnerability", LOG_ATTACK)
	owner.visible_message(span_warning("[owner] shines with azure light!"), span_notice("You feel Inath-neq's power flow through you! You're invincible!"))
	var/oldcolor = owner.color
	owner.color = "#1E8CE1"
	owner.fully_heal()
	owner.add_stun_absorption("inathneq", 150, 2, "'s flickering blue aura momentarily intensifies!", "Inath-neq's power absorbs the stun!", " glowing with a flickering blue light!")
	owner.status_flags |= GODMODE
	animate(owner, color = oldcolor, time = 150, easing = EASE_IN)
	addtimer(CALLBACK(owner, /atom/proc/update_atom_colour), 150)
	playsound(owner, 'sound/magic/ethereal_enter.ogg', 50, 1)
	return ..()

/datum/status_effect/inathneqs_endowment/on_remove()
	owner.log_message("lost Inath-neq's invulnerability", LOG_ATTACK)
	owner.visible_message(span_warning("The light around [owner] flickers and dissipates!"), span_boldwarning("You feel Inath-neq's power fade from your body!"))
	owner.status_flags &= ~GODMODE
	playsound(owner, 'sound/magic/ethereal_exit.ogg', 50, 1)


/datum/status_effect/cyborg_power_regen
	id = "power_regen"
	duration = 100
	alert_type = /obj/screen/alert/status_effect/power_regen
	var/power_to_give = 0 //how much power is gained each tick

/datum/status_effect/cyborg_power_regen/on_creation(mob/living/new_owner, new_power_per_tick)
	. = ..()
	if(. && isnum(new_power_per_tick))
		power_to_give = new_power_per_tick

/obj/screen/alert/status_effect/power_regen
	name = "Power Regeneration"
	desc = "You are quickly regenerating power!"
	icon_state = "power_regen"

/datum/status_effect/cyborg_power_regen/tick()
	var/mob/living/silicon/robot/cyborg = owner
	if(!istype(cyborg) || !cyborg.cell)
		qdel(src)
		return
	playsound(cyborg, 'sound/effects/light_flicker.ogg', 50, 1)
	cyborg.cell.give(power_to_give)

/datum/status_effect/his_grace
	id = "his_grace"
	duration = -1
	tick_interval = 4
	alert_type = /obj/screen/alert/status_effect/his_grace
	var/bloodlust = 0

/obj/screen/alert/status_effect/his_grace
	name = "His Grace"
	desc = "His Grace hungers, and you must feed Him."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/obj/screen/alert/status_effect/his_grace/MouseEntered(location,control,params)
	desc = initial(desc)
	var/datum/status_effect/his_grace/HG = attached_effect
	desc += "<br><font size=3><b>Current Bloodthirst: [HG.bloodlust]</b></font>\
	<br>Becomes undroppable at <b>[HIS_GRACE_FAMISHED]</b>\
	<br>Will consume you at <b>[HIS_GRACE_CONSUME_OWNER]</b>"
	..()

/datum/status_effect/his_grace/on_apply()
	owner.log_message("gained His Grace's stun immunity", LOG_ATTACK)
	owner.add_stun_absorption("hisgrace", INFINITY, 3, null, "His Grace protects you from the stun!")
	return ..()

/datum/status_effect/his_grace/tick()
	bloodlust = 0
	var/graces = 0
	for(var/obj/item/his_grace/HG in owner.held_items)
		if(HG.bloodthirst > bloodlust)
			bloodlust = HG.bloodthirst
		if(HG.awakened)
			graces++
	if(!graces)
		owner.apply_status_effect(STATUS_EFFECT_HISWRATH)
		qdel(src)
		return
	var/grace_heal = bloodlust * 0.05
	owner.adjustBruteLoss(-grace_heal)
	owner.adjustFireLoss(-grace_heal)
	owner.adjustToxLoss(-grace_heal, TRUE, TRUE)
	owner.adjustOxyLoss(-(grace_heal * 2))
	owner.adjustCloneLoss(-grace_heal)
	owner.adjustStaminaLoss(-200) //no stuns allowed sorry

/datum/status_effect/his_grace/on_remove()
	owner.log_message("lost His Grace's stun immunity", LOG_ATTACK)
	if(islist(owner.stun_absorption) && owner.stun_absorption["hisgrace"])
		owner.stun_absorption -= "hisgrace"


/datum/status_effect/wish_granters_gift //Fully revives after ten seconds.
	id = "wish_granters_gift"
	duration = 50
	alert_type = /obj/screen/alert/status_effect/wish_granters_gift

/datum/status_effect/wish_granters_gift/on_apply()
	to_chat(owner, span_notice("Death is not your end! The Wish Granter's energy suffuses you, and you begin to rise..."))
	return ..()

/datum/status_effect/wish_granters_gift/on_remove()
	owner.revive(full_heal = TRUE, admin_revive = TRUE)
	owner.visible_message(span_warning("[owner] appears to wake from the dead, having healed all wounds!"), span_notice("You have regenerated."))
	owner.update_mobility()

/obj/screen/alert/status_effect/wish_granters_gift
	name = "Wish Granter's Immortality"
	desc = "You are being resurrected!"
	icon_state = "wish_granter"

/datum/status_effect/cult_master
	id = "The Cult Master"
	duration = -1
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/alive = TRUE

/datum/status_effect/cult_master/proc/deathrattle()
	if(!QDELETED(GLOB.cult_narsie))
		return //if nar-sie is alive, don't even worry about it
	var/area/A = get_area(owner)
	for(var/datum/mind/B in SSticker.mode.cult)
		if(isliving(B.current))
			var/mob/living/M = B.current
			SEND_SOUND(M, sound('sound/hallucinations/veryfar_noise.ogg'))
			to_chat(M, span_cultlarge("The Cult's Master, [owner], has fallen in \the [A]!"))

/datum/status_effect/cult_master/tick()
	if(owner.stat != DEAD && !alive)
		alive = TRUE
		return
	if(owner.stat == DEAD && alive)
		alive = FALSE
		deathrattle()

/datum/status_effect/cult_master/on_remove()
	deathrattle()
	. = ..()

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /obj/screen/alert/status_effect/blooddrunk

/obj/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply()
	. = ..()
	if(.)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.physiology.brute_mod *= 0.1
			H.physiology.burn_mod *= 0.1
			H.physiology.tox_mod *= 0.1
			H.physiology.oxy_mod *= 0.1
			H.physiology.clone_mod *= 0.1
			H.physiology.stamina_mod *= 0.1
		owner.log_message("gained blood-drunk stun immunity", LOG_ATTACK)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1)

/datum/status_effect/blooddrunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod *= 10
		H.physiology.burn_mod *= 10
		H.physiology.tox_mod *= 10
		H.physiology.oxy_mod *= 10
		H.physiology.clone_mod *= 10
		H.physiology.stamina_mod *= 10
	owner.log_message("lost blood-drunk stun immunity", LOG_ATTACK)
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.stun_absorption -= "blooddrunk"

/datum/status_effect/sword_spin
	id = "Bastard Sword Spin"
	duration = 50
	tick_interval = 8
	alert_type = null


/datum/status_effect/sword_spin/on_apply()
	owner.visible_message(span_danger("[owner] begins swinging the sword with inhuman strength!"))
	var/oldcolor = owner.color
	owner.color = "#ff0000"
	owner.add_stun_absorption("bloody bastard sword", duration, 2, "doesn't even flinch as the sword's power courses through them!", "You shrug off the stun!", " glowing with a blazing red aura!")
	owner.spin(duration,1)
	animate(owner, color = oldcolor, time = duration, easing = EASE_IN)
	addtimer(CALLBACK(owner, /atom/proc/update_atom_colour), duration)
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, 0)
	return ..()


/datum/status_effect/sword_spin/tick()
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, 0)
	var/obj/item/slashy
	slashy = owner.get_active_held_item()
	for(var/mob/living/M in orange(1,owner))
		slashy.attack(M, owner)

/datum/status_effect/sword_spin/on_remove()
	owner.visible_message(span_warning("[owner]'s inhuman strength dissipates and the sword's runes grow cold!"))


//Used by changelings to rapidly heal
//Heals 10 brute and oxygen damage every second, and 5 fire
//Being on fire will suppress this healing
/datum/status_effect/fleshmend
	id = "fleshmend"
	duration = 100
	alert_type = /obj/screen/alert/status_effect/fleshmend

/datum/status_effect/fleshmend/tick()
	var/prot = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		prot = H.get_thermal_protection()


	if(owner.on_fire && (prot < FIRE_IMMUNITY_MAX_TEMP_PROTECT))
		linked_alert.icon_state = "fleshmend_fire"
		return
	else
		linked_alert.icon_state = "fleshmend"
	owner.adjustBruteLoss(-10, FALSE)
	owner.adjustFireLoss(-5, FALSE)
	owner.adjustOxyLoss(-10)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	QDEL_LIST(C.all_scars)

/obj/screen/alert/status_effect/fleshmend
	name = "Fleshmend"
	desc = "Our wounds are rapidly healing. <i>This effect is prevented if we are on fire.</i>"
	icon_state = "fleshmend"

/datum/status_effect/exercised
	id = "Exercised"
	duration = 1200
	alert_type = null

/datum/status_effect/exercised/on_creation(mob/living/new_owner, ...)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	START_PROCESSING(SSprocessing, src) //this lasts 20 minutes, so SSfastprocess isn't needed.

/datum/status_effect/exercised/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

//Hippocratic Oath: Applied when the Rod of Asclepius is activated.
/datum/status_effect/hippocraticOath
	id = "Hippocratic Oath"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 25
	examine_text = span_notice("They seem to have an aura of healing and helpfulness about them.")
	alert_type = null
	var/hand
	var/deathTick = 0

/datum/status_effect/hippocraticOath/on_apply()
	//Makes the user passive, it's in their oath not to harm!
	ADD_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(owner)
	return ..()

/datum/status_effect/hippocraticOath/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.remove_hud_from(owner)

/datum/status_effect/hippocraticOath/tick()
	if(owner.stat == DEAD)
		if(deathTick < 4)
			deathTick += 1
		else
			owner.visible_message("[owner]'s soul is absorbed into the rod, relieving the previous snake of its duty.")
			var/mob/living/simple_animal/hostile/retaliate/poison/snake/healSnake = new(owner.loc)
			healSnake.poison_type = /datum/reagent/medicine/omnizine/godblood
			healSnake.name = "Asclepius's Snake"
			healSnake.real_name = "Asclepius's Snake"
			healSnake.desc = "A mystical snake previously trapped upon the Rod of Asclepius, now freed of its burden. Unlike the average snake, its bites contain chemicals with minor healing properties."
			new /obj/effect/decal/cleanable/ash(owner.loc)
			new /obj/item/rod_of_asclepius(owner.loc)
			if(owner.mind)
				owner.mind.transfer_to(healSnake)
			qdel(owner)
	else
		if(iscarbon(owner))
			var/mob/living/carbon/itemUser = owner
			var/obj/item/heldItem = itemUser.get_item_for_held_index(hand)
			if(heldItem == null || heldItem.type != /obj/item/rod_of_asclepius) //Checks to make sure the rod is still in their hand
				var/obj/item/rod_of_asclepius/newRod = new(itemUser.loc)
				newRod.activated()
				if(!itemUser.has_hand_for_held_index(hand))
					//If user does not have the corresponding hand anymore, give them one and return the rod to their hand
					if(((hand % 2) == 0))
						var/obj/item/bodypart/L = itemUser.newBodyPart(BODY_ZONE_R_ARM, FALSE, FALSE)
						L.attach_limb(itemUser)
						itemUser.put_in_hand(newRod, hand, forced = TRUE)
					else
						var/obj/item/bodypart/L = itemUser.newBodyPart(BODY_ZONE_L_ARM, FALSE, FALSE)
						L.attach_limb(itemUser)
						itemUser.put_in_hand(newRod, hand, forced = TRUE)
					to_chat(itemUser, span_notice("Your arm suddenly grows back with the Rod of Asclepius still attached!"))
				else
					//Otherwise get rid of whatever else is in their hand and return the rod to said hand
					itemUser.put_in_hand(newRod, hand, forced = TRUE)
					to_chat(itemUser, span_notice("The Rod of Asclepius suddenly grows back out of your arm!"))
			//Because a servant of medicines stops at nothing to help others, lets keep them on their toes and give them an additional boost.
			if(itemUser.health < itemUser.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(itemUser), "#375637")
			itemUser.adjustBruteLoss(-1.5)
			itemUser.adjustFireLoss(-1.5)
			itemUser.adjustToxLoss(-1.5, forced = TRUE) //Because Slime People are people too
			itemUser.adjustOxyLoss(-1.5)
			itemUser.adjustStaminaLoss(-1.5)
			itemUser.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1.5)
			itemUser.adjustCloneLoss(-0.5) //Becasue apparently clone damage is the bastion of all health
		//Heal all those around you, unbiased
		for(var/mob/living/L in view(7, owner))
			if(L.health < L.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(L), "#375637")
			if(iscarbon(L))
				L.adjustBruteLoss(-3.5)
				L.adjustFireLoss(-3.5)
				L.adjustToxLoss(-3.5, forced = TRUE) //Because Slime People are people too
				L.adjustOxyLoss(-3.5)
				L.adjustStaminaLoss(-3.5)
				L.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3.5)
				L.adjustCloneLoss(-1) //Becasue apparently clone damage is the bastion of all health
			else if(issilicon(L))
				L.adjustBruteLoss(-3.5)
				L.adjustFireLoss(-3.5)
			else if(isanimal(L))
				var/mob/living/simple_animal/SM = L
				SM.adjustHealth(-3.5, forced = TRUE)

/datum/status_effect/good_music
	id = "Good Music"
	alert_type = null
	duration = 6 SECONDS
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/good_music/tick()
	owner.dizziness = max(0, owner.dizziness - 2)
	owner.jitteriness = max(0, owner.jitteriness - 2)
	owner.confused = max(0, owner.confused - 1)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "goodmusic", /datum/mood_event/goodmusic)

/obj/screen/alert/status_effect/regenerative_core
	name = "Reinforcing Tendrils"
	desc = "You can move faster than your broken body could normally handle!"
	icon_state = "regenerative_core"
	name = "Regenerative Core Tendrils"

/datum/status_effect/regenerative_core
	id = "Regenerative Core"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /obj/screen/alert/status_effect/regenerative_core

/datum/status_effect/regenerative_core/on_apply()
	if(is_station_level(get_turf(owner)))
		ADD_TRAIT(owner, TRAIT_REDUCED_DAMAGE_SLOWDOWN, id)
	else
		ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
	owner.adjustBruteLoss(-25)
	owner.adjustFireLoss(-25)
	owner.remove_CC()
	owner.bodytemperature = BODYTEMP_NORMAL
	return TRUE

/datum/status_effect/regenerative_core/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
	REMOVE_TRAIT(owner, TRAIT_REDUCED_DAMAGE_SLOWDOWN, id)

/datum/status_effect/antimagic
	id = "antimagic"
	duration = 10 SECONDS
	examine_text = span_notice("They seem to be covered in a dull, grey aura.")

/datum/status_effect/antimagic/on_apply()
	owner.visible_message(span_notice("[owner] is coated with a dull aura!"))
	ADD_TRAIT(owner, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	//glowing wings overlay
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, 0)
	return ..()

/datum/status_effect/antimagic/on_remove()
	REMOVE_TRAIT(owner, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	owner.visible_message(span_warning("[owner]'s dull aura fades away..."))

/datum/status_effect/creep //allows darkspawn to move through lights without lightburn damage //yogs start: darkspawn
	id = "creep"
	duration = -1
	alert_type = /obj/screen/alert/status_effect/creep
	examine_text = span_warning("SUBJECTPRONOUN is surrounded by velvety, gently-waving black shadows!")
	var/datum/antagonist/darkspawn/darkspawn

/datum/status_effect/creep/on_creation(mob/living/owner, datum/antagonist/darkspawn)
	. = ..()
	if(!.)
		return
	src.darkspawn = darkspawn

/datum/status_effect/creep/process()
	if(!darkspawn)
		qdel(src)
		return
	if(!darkspawn.has_psi(1)) //ticks 5 times per second, 5 Psi lost per second
		to_chat(owner, span_warning("Without the Psi to maintain it, your protective aura vanishes!"))
		qdel(src)
		return
	darkspawn.use_psi(1)

/obj/screen/alert/status_effect/creep
	name = "Creep"
	desc = "You are immune to lightburn. Drains 1 Psi per second."
	icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	icon_state = "creep"


/datum/status_effect/time_dilation //used by darkspawn; greatly increases action times etc
	id = "time_dilation"
	duration = 600
	alert_type = /obj/screen/alert/status_effect/time_dilation
	examine_text = span_warning("SUBJECTPRONOUN is moving jerkily and unpredictably!")

/datum/status_effect/time_dilation/on_apply()
	owner.next_move_modifier *= 0.5
	owner.action_speed_modifier *= 0.5
	owner.ignore_slowdown(id)
	return TRUE

/datum/status_effect/time_dilation/on_remove()
	owner.next_move_modifier *= 2
	owner.action_speed_modifier *= 2
	owner.unignore_slowdown(id)

/obj/screen/alert/status_effect/time_dilation
	name = "Time Dilation"
	desc = "Your actions are twice as fast, and the delay between them is halved. Additionally, you are immune to slowdown."
	icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	icon_state = "time_dilation" //yogs end
