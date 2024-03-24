//Snowflake spot for putting sling organ related stuff
/obj/item/organ/shadowtumor
	name = "black tumor"
	desc = "A tiny black mass with red tendrils trailing from it. It seems to shrivel in the light."
	icon_state = "blacktumor"
	w_class = 1
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN_TUMOR
	///How many process ticks the organ can be in light before it evaporates
	var/organ_health = 3
	///adds a cooldown to the resist so a thrall ipc or preternis can't weaponize it
	COOLDOWN_DECLARE(resist_cooldown)
	///How long the resist cooldown is
	var/cooldown_length = 15 SECONDS

/obj/item/organ/shadowtumor/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/shadowtumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/organ/shadowtumor/process()
	if(!isthrall(owner))
		qdel(src)
		return
	if(isturf(loc))
		var/turf/T = loc
		var/light_count = T.get_lumcount()
		if(light_count > SHADOW_SPECIES_DIM_LIGHT && organ_health > 0) //Die in the light
			organ_health--
		else if(light_count < SHADOW_SPECIES_DIM_LIGHT && organ_health < 3) //Heal in the dark
			organ_health = min(organ_health + 1, 3)
		if(organ_health <= 0)
			visible_message(span_warning("[src] collapses in on itself!"))
			qdel(src)
	else
		organ_health = min(organ_health+0.5, 3)

/obj/item/organ/shadowtumor/on_find(mob/living/finder)
	. = ..()
	finder.visible_message(span_danger("[finder] opens up [owner]'s skull, revealing a pulsating black mass, with red tendrils attaching it to [owner.p_their()] brain."))

/obj/item/organ/shadowtumor/proc/resist(mob/living/carbon/M)
	if(QDELETED(src))
		return FALSE
	if(!(M.stat == CONSCIOUS))//Thralls cannot be deconverted while awake
		return FALSE
	if(!isthrall(M))//non thralls don't resist
		return FALSE
	if(!COOLDOWN_FINISHED(src, resist_cooldown))//adds a cooldown to the resist so a thrall ipc or preternis can't weaponize it
		return FALSE
	COOLDOWN_START(src, resist_cooldown, cooldown_length)

	playsound(M,'sound/effects/tendril_destroyed.ogg', 80, 1)
	to_chat(M, span_progenitor("<b><i>NOT LIKE THIS!</i></b>"))
	M.visible_message(span_danger("[M] suddenly slams upward and knocks everyone back!"))
	M.resting = FALSE //Remove all stuns
	M.SetAllImmobility(0, TRUE)
	for(var/mob/living/user as anything in range(2, get_turf(src)))
		if(!istype(user))
			continue
		if(is_darkspawn_or_thrall(user))
			continue
		var/turf/target = get_ranged_target_turf(user, get_dir(M, user))
		user.throw_at(target, 2, 2, M)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.Knockdown(4 SECONDS)
			C.adjustBruteLoss(20)
		if(issilicon(user))
			var/mob/living/silicon/S = user
			S.Knockdown(8 SECONDS)
			S.adjustBruteLoss(20)
			playsound(S, 'sound/effects/bang.ogg', 50, 1)
	return TRUE
