/datum/component/lingering
	dupe_type = /datum/component/lingering //overwrite other types of lingering effect

/datum/component/lingering/Initialize()
	if(!istype(parent, /turf))
		return COMPONENT_INCOMPATIBLE

/datum/component/lingering/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_HITBY, PROC_REF(hitby))
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(Entered))

/datum/component/lingering/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_HITBY)
	UnregisterSignal(parent, COMSIG_ATOM_ENTERED)
	STOP_PROCESSING(SSobj, src)
	. = ..()
	
////////////////////////////////////////////////////////////////////////////////////
//---------------------------------Triggers---------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/proc/hitby(datum/source, atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(affect_stuff(AM))
		START_PROCESSING(SSobj, src)

/datum/component/lingering/proc/Entered(datum/source, atom/movable/AM)
	if(affect_stuff(AM))
		START_PROCESSING(SSobj, src)

/datum/component/lingering/process(delta_time)
	if(!affect_stuff(null, delta_time))
		STOP_PROCESSING(SSobj, src)

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------safety check-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile))

	var/turf/open/place = get_turf(parent)

	var/list/found_safeties = typecache_filter_list(place.contents, lava_safeties_typecache)

	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)

/datum/component/lingering/proc/affect_stuff(AM, delta_time = 1)
	. = 0

	if(is_safe())
		return FALSE

	if(AM) //if it's a specific object, apply to that one
		return apply_effect(AM, delta_time)

	var/turf/open/place = get_turf(parent) //otherwise, apply to every object on the turf

	if(!place)
		return

	for(var/thing in place.contents)
		if(thing == parent)
			continue
		if(apply_effect(thing, delta_time))
			. = 1

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Do the effect-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/proc/apply_effect(thing, delta_time) //override this for subtypes
	return FALSE

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------Regular lava-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/lava/apply_effect(thing, delta_time)
	. = 0
	if(isobj(thing))
		var/obj/O = thing
		if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
			return
		. = 1
		if((O.resistance_flags & (ON_FIRE)))
			return
		if(!(O.resistance_flags & FLAMMABLE))
			O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
		if(O.resistance_flags & FIRE_PROOF)
			O.resistance_flags &= ~FIRE_PROOF
		if(O.armor.fire > 50) //obj with 100% fire armor still get slowly burned away.
			O.armor = O.armor.setRating(fire = 50)
		O.fire_act(10000, 1000 * delta_time)

	else if (isliving(thing))
		. = 1
		var/mob/living/L = thing
		if(L.movement_type & FLYING)
			return	//YOU'RE FLYING OVER IT
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
			var/obj/item/clothing/S = C.get_item_by_slot(ITEM_SLOT_OCLOTHING)
			var/obj/item/clothing/H = C.get_item_by_slot(ITEM_SLOT_HEAD)

			if(S && H && S.clothing_flags & LAVAPROTECT && H.clothing_flags & LAVAPROTECT)
				return

		if("lava" in L.weather_immunities)
			return

		L.adjustFireLoss(20 * delta_time)
		if(L) //mobs turning into object corpses could get deleted here.
			L.adjust_fire_stacks(20 * delta_time)
			L.ignite_mob()

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Toxic water lava---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/toxic/apply_effect(thing, delta_time)
	. = 0
	if(isobj(thing)) //objects are unaffected for now
		return
	else if (isliving(thing))
		. = 1
		var/mob/living/L = thing
		if(L.movement_type & (FLYING|FLOATING))
			return	//YOU'RE FLYING OVER IT
		if(HAS_TRAIT(L,TRAIT_SULPH_PIT_IMMUNE))
			return
		var/buckle_check = L.buckling
		if(!buckle_check)
			buckle_check = L.buckled
		if(isobj(buckle_check))
			var/obj/O = buckle_check
			if(O.resistance_flags & ACID_PROOF)
				return
		else if(isliving(buckle_check))
			var/mob/living/live = buckle_check
			if(live.movement_type & (FLYING|FLOATING))
				return
			if(HAS_TRAIT(live, TRAIT_SULPH_PIT_IMMUNE))
				return

		if(ishuman(L))
			var/mob/living/carbon/human/humie = L
			var/chance = (100 - humie.getarmor(null,BIO)) * 0.33

			if(isipc(humie) && prob(chance))
				humie.adjustFireLoss(15)
				to_chat(humie,span_danger("the sulphuric solution burns and singes into your plating!"))
				return

			if(prob((chance * 0.5) + 10))
				humie.acid_act(15,15)
				
			if(HAS_TRAIT(L,TRAIT_TOXIMMUNE) || HAS_TRAIT(L,TRAIT_TOXINLOVER))
				return
			
			humie.reagents.add_reagent(/datum/reagent/toxic_metabolities, 2)

		else if(prob(25))
			L.acid_act(5,7.5)
	
////////////////////////////////////////////////////////////////////////////////////
//----------------------------Plasma river lava-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/lingering/plasma/apply_effect(thing, delta_time)
	. = 0
	if(isobj(thing))
		var/obj/O = thing
		if((O.resistance_flags & (FREEZE_PROOF)) || O.throwing)
			return

	else if (isliving(thing))
		. = 1
		var/mob/living/L = thing
		if(L.movement_type & FLYING)
			return	//YOU'RE FLYING OVER IT
		if(WEATHER_SNOW in L.weather_immunities)
			return

		var/buckle_check = L.buckling
		if(!buckle_check)
			buckle_check = L.buckled
		if(isobj(buckle_check))
			var/obj/O = buckle_check
			if(O.resistance_flags & FREEZE_PROOF)
				return

		else if(isliving(buckle_check))
			var/mob/living/live = buckle_check
			if(WEATHER_SNOW in live.weather_immunities)
				return

		L.adjustFireLoss(2)
		if(L)
			L.adjust_fire_stacks(20) //dipping into a stream of plasma would probably make you more flammable than usual
			L.adjust_bodytemperature(-rand(50,65)) //its cold, man
			if(ishuman(L))//are they a carbon?
				var/list/plasma_parts = list()//a list of the organic parts to be turned into plasma limbs
				var/list/robo_parts = list()//keep a reference of robotic parts so we know if we can turn them into a plasmaman
				var/mob/living/carbon/human/PP = L
				var/datum/species/S = PP.dna.species
				if(istype(S, /datum/species/plasmaman) || (S.inherent_biotypes & MOB_ROBOTIC)) //ignore plasmamen/robotic species
					return

				for(var/BP in PP.bodyparts)
					var/obj/item/bodypart/NN = BP
					if(NN.status == BODYPART_ROBOTIC)
						robo_parts += NN
					if(NN.body_zone == BODY_ZONE_HEAD) //don't add the head to the list, just transform them into an plasmaman when it's the only thing left
						continue
					if(NN.status == BODYPART_ORGANIC && !(NN.species_id == "plasmaman" || NN.species_id == "husk")) //getting every organic, non-plasmaman limb (augments/androids are immune to this)
						plasma_parts += NN

				if(prob(35)) //checking if the delay is over & if the victim actually has any parts to nom
					PP.adjustToxLoss(15)
					PP.adjustFireLoss(25)
					if(length(plasma_parts))
						playsound(PP, 'sound/effects/wounds/sizzle2.ogg', 80, TRUE)
						var/obj/item/bodypart/NB = pick(plasma_parts) //using the above-mentioned list to get a choice of limbs to replace
						if(PP.stat != DEAD)
							PP.emote("scream")
							PP.visible_message(span_warning("[L] screams in pain as [L.p_their()] [NB] melts down to the bone!"), span_userdanger("You scream out in pain as your [NB] melts down to the bone, leaving an eerie plasma-like glow where flesh used to be!"))
						else
							PP.visible_message(span_warning("[L]'s [NB] melts down to the bone!"))
						var/obj/item/bodypart/replacement_part = new NB.type
						replacement_part.species_id = "plasmaman"
						replacement_part.original_owner = "plasma river"
						replacement_part.replace_limb(PP)
						qdel(NB)
					else if(!length(robo_parts)) //a person with no potential organic limbs left AND no robotic limbs, time to turn them into a plasmaman
						playsound(PP, 'sound/effects/wounds/sizzle2.ogg', 80, TRUE)
						PP.ignite_mob()
						PP.cure_husk(BURN) //cure the probable husk first
						PP.set_species(/datum/species/plasmaman)
						PP.regenerate_icons()
						PP.visible_message(span_warning("[L] bursts into a brilliant purple flame as [L.p_their()] entire body is that of a skeleton!"), \
											span_userdanger("Your senses numb as all of your remaining flesh is turned into a purple slurry, sloshing off your body and leaving only your bones to show in a vibrant purple!"))
