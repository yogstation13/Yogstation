/obj/effect/hallucination/danger/lava/proc/burn_stuff(AM) // A slightly-altered copy of /turf/open/lava/proc/burn_stuff(), from 28 June 2019.
	if(!AM)
		return

	if(isobj(AM))
		var/obj/O = AM
		if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
			return
		if((O.resistance_flags & (ON_FIRE)))
			return
		if(!(O.resistance_flags & FLAMMABLE))
			O.resistance_flags |= FLAMMABLE //Even fireproof AMs burn up in lava
		if(O.resistance_flags & FIRE_PROOF)
			O.resistance_flags &= ~FIRE_PROOF
		if(O.armor.fire > 50) //obj with 100% fire armor still get slowly burned away.
			O.armor = O.armor.setRating(fire = 50)
		O.fire_act(10000, 1000)
	else if (isliving(AM))
		var/mob/living/L = AM
		if(L.movement_type & FLYING)
			return
		var/buckle_check = L.buckling
		if(!buckle_check)
			buckle_check = L.buckled
		if(isobj(buckle_check))
			var/obj/O = buckle_check
			if(O.resistance_flags & LAVA_PROOF)
				return
		else if(isliving(buckle_check))
			var/mob/living/live = buckle_check
			if("lava" in live.weather_immunities)
				return

		if(!L.on_fire)
			L.update_fire()

		if(iscarbon(L))
			var/mob/living/carbon/C = L
			var/obj/item/clothing/S = C.get_item_by_slot(SLOT_WEAR_SUIT)
			var/obj/item/clothing/H = C.get_item_by_slot(SLOT_HEAD)

			if(S && H && S.clothing_flags & LAVAPROTECT && H.clothing_flags & LAVAPROTECT)
				return

		if("lava" in L.weather_immunities)
			return

		L.adjustFireLoss(20)
		if(L) //mobs turning into object corpses could get deleted here.
			L.adjust_fire_stacks(20)
			L.IgniteMob()

/obj/effect/hallucination/danger/anomaly/proc/mobShock(mob/living/M) // A slightly-altered copy of /obj/effect/anomaly/flux/proc/mobShock(), from 28 June 2019.
	if(istype(M))
		if(iscarbon(M))
			if(ishuman(M))
				M.electrocute_act(20, "[name]", safety=1)
				return
			M.electrocute_act(25, "[name]") // burn you fuckin' nutty xeno
			return
		else
			M.adjustFireLoss(20)
			M.visible_message("<span class='danger'>[M] was shocked by \the [name]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='italics'>You hear a heavy electrical crack.</span>")