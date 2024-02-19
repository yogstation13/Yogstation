/obj/item/fuel_rod
	name = "uranium-235 fuel rod"
	desc = "A titanium sheathed rod containing a measure of enriched uranium-dioxide powder inside, and a breeding blanket of uranium-238 around it, used to kick off a fission reaction and breed plutonium fuel respectivly."
	icon = 'icons/obj/control_rod.dmi'
	icon_state = "irradiated"
	w_class = WEIGHT_CLASS_BULKY
	var/depletion = 0 //Each fuel rod will deplete in around 30 minutes.
	var/fuel_power = 0.10
	var/rad_strength = 500
	var/half_life = 2000 // how many depletion ticks are needed to half the fuel_power (1 tick = 1 second)
	var/time_created = 0
	var/process = FALSE
	// The depletion where depletion_final() will be called (and does something)
	var/depletion_threshold = 100
	var/depleted_final = FALSE // depletion_final should run only once
	var/depletion_conversion_type = /obj/item/fuel_rod/plutonium

/obj/item/fuel_rod/Initialize(mapload)
	. = ..()
	time_created = world.time
	AddComponent(/datum/component/radioactive, rad_strength, src, half_life) // This should be temporary for it won't make rads go lower than 350
	if(process)
		START_PROCESSING(SSobj, src)

/obj/item/fuel_rod/Destroy()
	if(process)
		STOP_PROCESSING(SSobj, src)
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/N = loc
	if(istype(N))
		N.fuel_rods -= src
	. = ..()

// Converts a fuel rod into a given type
/obj/item/fuel_rod/proc/depletion_final(result_rod)
	if(!result_rod)
		return FALSE
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/N = loc
	// Right now there's no reason rods should deplete outside a reactor
	if(istype(N))
		var/obj/item/fuel_rod/R = new result_rod(loc)
		if(istype(R, /obj/item/fuel_rod)) // if it's not even a fuel rod then what the fuck are we doing here
			R.depletion = depletion
			R.fuel_power = fuel_power // conservation of energy
			N.fuel_rods += R
			qdel(src)
			return TRUE
		else
			stack_trace("Invalid fuel rod type: [R.type]")
	return FALSE

/obj/item/fuel_rod/proc/deplete(amount=0.035)
	depletion += amount
	if(depletion >= depletion_threshold && !depleted_final) // set whether or not it's depleted
		depleted_final = depletion_final(depletion_conversion_type)

/obj/item/fuel_rod/plutonium
	fuel_power = 0.20
	name = "plutonium-239 fuel rod"
	desc = "A highly energetic titanium sheathed rod containing a sizeable measure of weapons grade plutonium, it's highly efficient as nuclear fuel, but will cause the reaction to get out of control if not properly utilised."
	icon_state = "inferior"
	rad_strength = 1500
	process = TRUE // for half life code
	depletion_threshold = 300
	depletion_conversion_type = /obj/item/fuel_rod/depleted

/obj/item/fuel_rod/process(delta_time)
	fuel_power *= 0.5**(delta_time / half_life) // halves the fuel power every half life (33 minutes)

/obj/item/fuel_rod/depleted
	fuel_power = 0.05
	name = "depleted fuel rod"
	desc = "A highly radioactive fuel rod which has expended most of its useful energy."
	icon_state = "normal"
	rad_strength = 6000 // smelly
	depletion_conversion_type = null // It means that it won't turn into anything
	process = TRUE

// Master type for material optional (or requiring, wyci) and/or producing rods
/obj/item/fuel_rod/material
	// Whether the rod has been harvested. Should be set in expend().
	var/expended = FALSE
	// The material that will be inserted and then multiplied (or not). Should be some sort of /obj/item/stack
	var/material_type
	// The name of material that'll be used for texts
	var/material_name
	var/material_name_singular
	var/initial_amount = 0
	// The maximum amount of material the rod can hold
	var/max_initial_amount = 10
	var/grown_amount = 0
	// The multiplier for growth. 1 for the same 2 for double etc etc
	var/multiplier = 2
	// After this depletion, you won't be able to add new materials
	var/material_input_deadline = 25
	// Material fuel rods generally don't get converted into another fuel object
	depletion_conversion_type = null

/obj/item/fuel_rod/material/Initialize(mapload)
	. = ..()
	var/obj/item/stack/S = new material_type()
	material_name = S.name
	material_name_singular = S.singular_name
	qdel(S)

// Called when the rod is fully harvested
/obj/item/fuel_rod/material/proc/expend()
	expended = TRUE

// Basic checks for material rods
/obj/item/fuel_rod/material/proc/check_material_input(mob/user)
	if(depletion >= material_input_deadline)
		to_chat(user, "<span class='warning'>The sample slots have sealed themselves shut, it's too late to add [material_name] now!</span>") // no cheesing in crystals at 100%
		return FALSE
	if(expended)
		to_chat(user, "<span class='warning'>\The [src]'s material slots have already been used.</span>")
		return FALSE
	return TRUE

// The actual growth
/obj/item/fuel_rod/material/depletion_final(result_rod)
	if(result_rod)
		return ..() // So if you put anything into depletion_conversion_type then your fuel rod will be converted (or not) and *won't grow*
	grown_amount = initial_amount * multiplier
	return TRUE

/obj/item/fuel_rod/material/attackby(obj/item/W, mob/user, params)
	var/obj/item/stack/sheet/M = W
	if(!material_type && istype(M))
		material_type = M.type
	if(istype(M, material_type))
		if(!check_material_input(user))
			return
		if(initial_amount < max_initial_amount)
			var/adding = min((max_initial_amount - initial_amount), M.amount)
			M.amount -= adding
			initial_amount += adding
			if (adding == 1)
				to_chat(user, "<span class='notice'>You insert [adding] [material_name_singular] into \the [src].</span>")
			else
				to_chat(user, "<span class='notice'>You insert [adding] [material_name] into \the [src].</span>")
			M.is_zero_amount(delete_if_zero = TRUE)
		else
			to_chat(user, "<span class='warning'>\The [src]'s material slots are full!</span>")
			return
	else
		return ..()

/obj/item/fuel_rod/material/attack_self(mob/user)
	if(expended)
		to_chat(user, "<span class='notice'>You have already removed [material_name] from \the [src].</span>")
		return

	if(depleted_final)
		new material_type(user.loc, grown_amount)
		if (grown_amount == 1)
			to_chat(user, "<span class='notice'>You harvest [grown_amount] [material_name_singular] from \the [src].</span>") // Unlikely
		else
			to_chat(user, "<span class='notice'>You harvest [grown_amount] [material_name] from \the [src].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		grown_amount = 0
		expend()
	else if(depletion)
		to_chat(user, "<span class='warning'>\The [src] has not fissiled enough to fully grow the sample. The progress bar shows it is [min(depletion/depletion_threshold*100,100)]% complete.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	else if(initial_amount)
		new material_type(user.loc, initial_amount)
		if (initial_amount == 1)
			to_chat(user, "<span class='notice'>You remove [initial_amount] [material_name_singular] from \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>You remove [initial_amount] [material_name] from \the [src].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		initial_amount = 0

/obj/item/fuel_rod/material/examine(mob/user)
	. = ..()
	if(material_type)
		if(expended)
			. += "<span class='warning'>The material slots have been slagged by the extreme heat, you can't grow [material_name] in this rod again...</span>"
			return
		else if(depleted_final)
			. += "<span class='warning'>This fuel rod's [material_name] are now fully grown, and it currently bears [grown_amount] harvestable [material_name_singular]\s.</span>"
			return
		if(depletion)
			. += "<span class='danger'>The sample is [min(depletion/depletion_threshold*100,100)]% fissiled.</span>"
		. += "<span class='disarm'>[initial_amount]/[max_initial_amount] of the slots for [material_name] are full.</span>"
	else
		. += "<span class='disarm'>This rod is ready for material breeding</span>"

/obj/item/fuel_rod/material/telecrystal
	name = "telecrystal fuel rod"
	desc = "A disguised titanium sheathed rod containing several small slots infused with uranium dioxide. Permits the insertion of telecrystals to grow more. Fissiles much faster than its standard counterpart"
	icon_state = "telecrystal"
	fuel_power = 0.30 // twice as powerful as a normal rod, you're going to need some engineering autism if you plan to mass produce TC
	depletion_threshold = 33 // otherwise it takes two hours
	rad_strength = 1500
	max_initial_amount = 8
	multiplier = 3
	material_type = /obj/item/stack/telecrystal

/obj/item/fuel_rod/material/telecrystal/depletion_final(result_rod)
	if(..())
		return TRUE
	fuel_power = 0.60 // thrice as powerful as plutonium, you'll want to get this one out quick!
	name = "exhausted telecrystal fuel rod"
	desc = "A highly energetic, disguised titanium sheathed rod containing a number of slots filled with greatly expanded telecrystals which can be removed by hand. It's extremely efficient as nuclear fuel, but will cause the reaction to get out of control if not properly utilised."
	icon_state = "telecrystal_used"
	AddComponent(/datum/component/radioactive, 3000, src)
	return FALSE

/obj/item/fuel_rod/material/bananium
	name = "bananium fuel rod"
	desc = "A hilarious heavy-duty fuel rod which fissiles a bit slower than its cowardly counterparts. However, its cutting-edge cosmic clown technology allows rooms for extraordinarily exhilarating extraterrestrial element called bananium to menacingly multiply."
	icon_state = "bananium"
	fuel_power = 0.15
	depletion_threshold = 33
	rad_strength = 350
	max_initial_amount = 10
	multiplier = 3
	material_type = /obj/item/stack/sheet/mineral/bananium

/obj/item/fuel_rod/material/bananium/deplete(amount=0.035)
	..()
	if(initial_amount == max_initial_amount && prob(10))
		playsound(src, pick('sound/items/bikehorn.ogg'), 50) // HONK

/obj/item/fuel_rod/material/bananium/depletion_final(result_rod)
	if(..())
		return TRUE
	fuel_power = 0.3 // Be warned
	name = "fully grown bananium fuel rod"
	desc = "A hilarious heavy-duty fuel rod which fissiles a bit slower than it cowardly counterparts. Its greatly grimacing growth stage is now over, and bananium outgrowth hums as if it's blatantly honking bike horns."
	icon_state = "bananium_used"
	AddComponent(/datum/component/radioactive, 1250, src)
	return FALSE
