#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7

#define EFFECT_PROB_VERYLOW 20
#define EFFECT_PROB_LOW 35
#define EFFECT_PROB_MEDIUM 50
#define EFFECT_PROB_HIGH 75
#define EFFECT_PROB_VERYHIGH 95

#define FAIL 8

/obj/machinery/rnd/experimentor/proc/experiment(exp,obj/item/exp_on)
	recentlyExperimented = 1
	icon_state = "h_lathe_wloop"
	var/chosenchem
	var/criticalReaction = is_type_in_typecache(exp_on,  critical_items_typecache)
	var/badThingCoeffIfCrit = criticalReaction ? badThingCoeff : 0 // certain malfunctions are desirable for non-critical items
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_POKE)
		visible_message("[src] prods at [exp_on] with mechanical arms.")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] is gripped in just the right way, enhancing its focus.")
			badThingCoeff++
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions and destroys [exp_on], lashing its arms out at nearby people!</span>")
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(15, BRUTE, pick(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_PRECISE_GROIN))
				investigate_log("Experimentor dealt minor brute to [m].", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions!</span>")
			exp = SCANTYPE_OBLITERATE
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, throwing the [exp_on]!</span>")
			var/mob/living/target = locate(/mob/living) in oview(7,src)
			if(target)
				var/obj/item/throwing = loaded_item
				investigate_log("Experimentor has thrown [loaded_item] at [key_name(target)]", INVESTIGATE_EXPERIMENTOR)
				ejectItem()
				if(throwing)
					throwing.throw_at(target, 10, 1)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_IRRADIATE)
		visible_message("<span class='danger'>[src] reflects radioactive rays at [exp_on]!</span>")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] has activated an unknown subroutine!")
			cloneMode = TRUE
			investigate_log("Experimentor has made a clone of [exp_on]", INVESTIGATE_EXPERIMENTOR)
			ejectItem()
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, melting [exp_on] and leaking radiation!</span>")
			radiation_pulse(src, 500)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, spewing toxic waste!</span>")
			for(var/turf/T in oview(1, src))
				if(!T.density)
					if(prob(EFFECT_PROB_VERYHIGH) && !(locate(/obj/effect/decal/cleanable/greenglow) in T))
						var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
						reagentdecal.reagents.add_reagent("radium", 7)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeffIfCrit))
			var/savedName = "[exp_on]"
			ejectItem(TRUE)
			var/newPath = text2path(pickweight(valid_items))
			loaded_item = new newPath(src)
			visible_message("<span class='warning'>[src] malfunctions, transforming [savedName] into [loaded_item]!</span>")
			investigate_log("Experimentor has transformed [savedName] into [loaded_item]", INVESTIGATE_EXPERIMENTOR)
			if(istype(loaded_item, /obj/item/grenade/chem_grenade))
				var/obj/item/grenade/chem_grenade/CG = loaded_item
				CG.prime()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_GAS)
		visible_message("<span class='warning'>[src] fills its chamber with gas, [exp_on] included.</span>")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("[exp_on] achieves the perfect mix!")
			new /obj/item/stack/sheet/mineral/plasma(get_turf(pick(oview(1,src))))
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeffIfCrit))
			visible_message("<span class='danger'>[src] destroys [exp_on], leaking dangerous gas!</span>")
			chosenchem = pick("carbon","radium","toxin","condensedcapsaicin","mushroomhallucinogen","space_drugs","ethanol","beepskysmash")
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = src
			R.add_reagent(chosenchem , 50)
			investigate_log("Experimentor has released [chosenchem] smoke.", INVESTIGATE_EXPERIMENTOR)
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(R, 0, src, silent = TRUE)
			playsound(src, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(R)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeffIfCrit))
			visible_message("<span class='danger'>[src]'s chemical chamber has sprung a leak!</span>")
			chosenchem = pick("mutationtoxin","nanomachines","sacid")
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = src
			R.add_reagent(chosenchem , 50)
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(R, 0, src, silent = TRUE)
			playsound(src, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(R)
			ejectItem(TRUE)
			warn_admins(usr, "[chosenchem] smoke")
			investigate_log("Experimentor has released <font color='red'>[chosenchem]</font> smoke!", INVESTIGATE_EXPERIMENTOR)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("[src] malfunctions, spewing harmless gas.")
			throwSmoke(loc)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] melts [exp_on], ionizing the air around it!</span>")
			empulse(loc, 4, 6)
			investigate_log("Experimentor has generated an Electromagnetic Pulse.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_HEAT)
		visible_message("[src] raises [exp_on]'s temperature.")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s emergency coolant system gives off a small ding!</span>")
			playsound(src, 'sound/machines/ding.ogg', 50, 1)
			var/obj/item/reagent_containers/food/drinks/coffee/C = new /obj/item/reagent_containers/food/drinks/coffee(get_turf(pick(oview(1,src))))
			chosenchem = pick("plasma","capsaicin","ethanol")
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			var/turf/start = get_turf(src)
			var/mob/M = locate(/mob/living) in view(src, 3)
			var/turf/MT = get_turf(M)
			if(MT)
				visible_message("<span class='danger'>[src] dangerously overheats, launching a flaming fuel orb!</span>")
				investigate_log("Experimentor has launched a <font color='red'>fireball</font> at [M]!", INVESTIGATE_EXPERIMENTOR)
				var/obj/item/projectile/magic/aoe/fireball/FB = new /obj/item/projectile/magic/aoe/fireball(start)
				FB.preparePixelProjectile(MT, start)
				FB.fire()
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, melting [exp_on] and releasing a burst of flame!</span>")
			explosion(loc, -1, 0, 0, 0, 0, flame_range = 2)
			investigate_log("Experimentor started a fire.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, melting [exp_on] and leaking hot air!</span>")
			var/datum/gas_mixture/env = loc.return_air()
			var/transfer_moles = 0.25 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null)
					heat_capacity = 1
				removed.temperature = min((removed.temperature*heat_capacity + 100000)/heat_capacity, 1000)
			env.merge(removed)
			air_update_turf()
			investigate_log("Experimentor has released hot air.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, activating its emergency coolant systems!</span>")
			throwSmoke(loc)
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(5, BURN, pick(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_PRECISE_GROIN))
				investigate_log("Experimentor has dealt minor burn damage to [key_name(m)]", INVESTIGATE_EXPERIMENTOR)
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_COLD)
		visible_message("[src] lowers [exp_on]'s temperature.")
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s emergency coolant system gives off a small ding!</span>")
			var/obj/item/reagent_containers/food/drinks/coffee/C = new /obj/item/reagent_containers/food/drinks/coffee(get_turf(pick(oview(1,src))))
			playsound(src, 'sound/machines/ding.ogg', 50, 1) //Ding! Your death coffee is ready!
			chosenchem = pick("uranium","frostoil","ephedrine")
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src] malfunctions, shattering [exp_on] and releasing a dangerous cloud of coolant!</span>")
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = src
			R.add_reagent("frostoil" , 50)
			investigate_log("Experimentor has released frostoil gas.", INVESTIGATE_EXPERIMENTOR)
			var/datum/effect_system/smoke_spread/chem/smoke = new
			smoke.set_up(R, 0, src, silent = TRUE)
			playsound(src, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(R)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, shattering [exp_on] and leaking cold air!</span>")
			var/datum/gas_mixture/env = loc.return_air()
			var/transfer_moles = 0.25 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null)
					heat_capacity = 1
				removed.temperature = (removed.temperature*heat_capacity - 75000)/heat_capacity
			env.merge(removed)
			air_update_turf()
			investigate_log("Experimentor has released cold air.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='warning'>[src] malfunctions, releasing a flurry of chilly air as [exp_on] pops out!</span>")
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(0, loc)
			smoke.start()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_OBLITERATE)
		visible_message("<span class='warning'>[exp_on] activates the crushing mechanism, [exp_on] is destroyed!</span>")
		if(linked_console.linked_lathe)
			GET_COMPONENT_FROM(linked_materials, /datum/component/material_container, linked_console.linked_lathe)
			for(var/material in exp_on.materials)
				linked_materials.insert_amount( min((linked_materials.max_amount - linked_materials.total_amount), (exp_on.materials[material])), material)
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message("<span class='warning'>[src]'s crushing mechanism slowly and smoothly descends, flattening the [exp_on]!</span>")
			new /obj/item/stack/sheet/plasteel(get_turf(pick(oview(1,src))))
		else if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s crusher goes way too many levels too high, crushing right through space-time!</span>")
			playsound(src, 'sound/effects/supermatter.ogg', 50, 1, -3)
			investigate_log("Experimentor has triggered the 'throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					AM.throw_at(src,10,1)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='danger'>[src]'s crusher goes one level too high, crushing right into space-time!</span>")
			playsound(src, 'sound/effects/supermatter.ogg', 50, 1, -3)
			investigate_log("Experimentor has triggered the 'minor throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
			var/list/throwAt = list()
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					throwAt.Add(AM)
			for(var/counter = 1, counter < throwAt.len, ++counter)
				var/atom/movable/cast = throwAt[counter]
				cast.throw_at(pick(throwAt),10,1)
		ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == FAIL)
		var/a = pick("rumbles","shakes","vibrates","shudders")
		var/b = pick("crushes","spins","viscerates","smashes","insults")
		visible_message("<span class='warning'>[exp_on] [a], and [b], the experiment was a failure.</span>")

	if(exp == SCANTYPE_DISCOVER)
		visible_message("[src] scans the [exp_on], revealing its true nature!")
		playsound(src, 'sound/effects/supermatter.ogg', 50, 3, -1)
		var/obj/item/relic/R = loaded_item
		R.reveal()
		investigate_log("Experimentor has revealed a relic with <span class='danger'>[R.realProc]</span> effect.", INVESTIGATE_EXPERIMENTOR)
		ejectItem()

	var/badThingCoeffIfSuccess = (exp == FAIL) ? 0 : badThingCoeff

	//Global reactions
	if(prob(EFFECT_PROB_VERYLOW-badThingCoeffIfSuccess) && prob(14) && loaded_item)
		visible_message("<span class='warning'>[src]'s onboard detection system has malfunctioned!</span>")
		item_reactions["[exp_on.type]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
		ejectItem()
	if(prob(EFFECT_PROB_VERYLOW-badThingCoeff) && prob(19) && loaded_item)
		visible_message("<span class='warning'>[src] melts [exp_on], ian-izing the air around it!</span>")
		throwSmoke(loc)
		if(trackedIan)
			throwSmoke(trackedIan.loc)
			trackedIan.forceMove(loc)
			investigate_log("Experimentor has stolen Ian!", INVESTIGATE_EXPERIMENTOR) //...if anyone ever fixes it...
		else
			new /mob/living/simple_animal/pet/dog/corgi(loc)
			investigate_log("Experimentor has spawned a new corgi.", INVESTIGATE_EXPERIMENTOR)
		ejectItem(TRUE)
	if(prob(EFFECT_PROB_VERYLOW-badThingCoeff) && prob(14) && loaded_item)
		visible_message("<span class='warning'>Experimentor draws the life essence of those nearby!</span>")
		for(var/mob/living/m in view(4,src))
			to_chat(m, "<span class='danger'>You feel your flesh being torn from you, mists of blood drifting to [src]!</span>")
			m.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
			investigate_log("Experimentor has taken 50 brute a blood sacrifice from [m]", INVESTIGATE_EXPERIMENTOR)
	if(prob(EFFECT_PROB_VERYLOW-badThingCoeff) && prob(23) && loaded_item)
		visible_message("<span class='warning'>[src] encounters a run-time error!</span>")
		throwSmoke(loc)
		if(trackedRuntime)
			throwSmoke(trackedRuntime.loc)
			trackedRuntime.forceMove(drop_location())
			investigate_log("Experimentor has stolen Runtime!", INVESTIGATE_EXPERIMENTOR)
		else
			new /mob/living/simple_animal/pet/cat(loc)
			investigate_log("Experimentor failed to steal runtime, and instead spawned a new cat.", INVESTIGATE_EXPERIMENTOR)
		ejectItem(TRUE)
	if(prob(EFFECT_PROB_VERYLOW-badThingCoeff) && prob(23) && loaded_item)
		visible_message("<span class='warning'>[src] begins to smoke and hiss, shaking violently!</span>")
		use_power(500000)
		investigate_log("Experimentor has drained power from its APC", INVESTIGATE_EXPERIMENTOR)

	addtimer(CALLBACK(src, .proc/reset_exp), resetTime)

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER

#undef EFFECT_PROB_VERYLOW
#undef EFFECT_PROB_LOW
#undef EFFECT_PROB_MEDIUM
#undef EFFECT_PROB_HIGH
#undef EFFECT_PROB_VERYHIGH

#undef FAIL
