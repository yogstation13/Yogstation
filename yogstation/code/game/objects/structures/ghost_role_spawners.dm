/obj/effect/mob_spawn/human/ash_walker/cosmic
	name = "cosmic ashwalker egg"
	desc = "As you stare you can hear your own thoughts hum through the wind."
	mob_name = "a cosmic ashwalker"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	mob_species = /datum/species/lizard/ashwalker/cosmic
	flavour_text = "<font size=3><b>Y</b></font><b>ou are an ash walker. You were <span class='danger'>Abducted</span>. Taken from your home by strange beings, so they could take you apart and then put you back together as something which they could control. They failed, and paid the price. Your prison screamed and shook as ash storms dashed it to the ground. Now you are free, but... something is different.</b>"
	uniform = null

/obj/effect/mob_spawn/human/ash_walker/cosmic/special(mob/living/new_spawn)
	..()
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.grant_all_languages(omnitongue=TRUE) // Is this powercreep?
		to_chat(H, "<span class='notice'>You are familiar with these human's language. Use this to your advantage to communicate with those authentic with it.</span>")
	to_chat(new_spawn, "<span class='notice'>When you are close to death you will enter a chrysalis state where you will slowly regenerate. During this state you are very vunerable.</span>")

// Rebirth egg that ashwalkers regenerate in when they reach under 0 health. Takes time to regenerate.
/obj/effect/cyrogenicbubble
	name = "cosmic egg"
	desc = "You can see the embryo of a slowly regenerating baby-ashwalker. This one is extraordinary."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	density = 1
	var/health = 100
	var/progress = 0
	var/mob/living/ashwalker

/obj/effect/cyrogenicbubble/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/effect/cyrogenicbubble/Destroy()
	if(ashwalker)
		qdel(ashwalker) // haha, you're not getting out of this one.
	if(health)
		health = 0
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/cyrogenicbubble/process()
	if(health)
		progress = min(50, progress + 1) // capped at 50, its all we need.
	else
		ejectEgg()
	if(progress == 50)
		ejectEgg()

/obj/effect/cyrogenicbubble/proc/reset_rebirth()
	if(!ashwalker)
		return

	if(ishuman(ashwalker))
		var/mob/living/carbon/human/H = ashwalker
		var/datum/species/lizard/ashwalker/cosmic/C = H.dna.species
		C.rebirth = FALSE

/obj/effect/cyrogenicbubble/attackby(obj/item/weapon, mob/user)
	if(health)
		if(weapon.force > health)
			ejectEgg()
			qdel(src)
		else
			health -= weapon.force
	playsound(loc, weapon.hitsound, 50, 1, 1)
	user.changeNext_move(CLICK_CD_MELEE)

/obj/effect/cyrogenicbubble/attack_animal(mob/living/simple_animal/M)
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	if(damage > health)
		ejectEgg()
		qdel(src)
		visible_message("<span class='warning'>[M] [M.attacktext] [src]</span>")
	else
		health -= damage

/obj/effect/cyrogenicbubble/proc/ejectEgg()
	if(ashwalker)
		if(progress == 50)
			ashwalker.revive(1) // full heal
		else
			// if they didn't make it to 50, then they'll be healed, but not completely
			// scaling is multiplied by 2, based on the fact that damage varies and I don't want to exactly set their brute/fire/tox/oxy damage
			ashwalker.adjustToxLoss(-progress*2, 0)
			ashwalker.adjustOxyLoss(-progress*2, 0)
			ashwalker.adjustBruteLoss(-progress*2, 0)
			ashwalker.adjustFireLoss(-progress*2, 0)
			ashwalker.revive()
		ashwalker.forceMove(get_turf(src))
		ashwalker.real_name = name
		ashwalker.name = name
		ashwalker.blood_volume = BLOOD_VOLUME_NORMAL
		reset_rebirth()
		ashwalker.grab_ghost()
		ashwalker = null
	qdel(src)

/obj/effect/cyrogenicbubble/return_air()
	if(get_turf(src))
		var/turf/T = get_turf(src)
		return T.return_air()
	else
		return null