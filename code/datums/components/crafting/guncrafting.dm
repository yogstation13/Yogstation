//Gun crafting parts til they can be moved elsewhere

// PARTS //

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "A prototype modular receiver and trigger assembly for a firearm."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "receiver"

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "riflestock"

/obj/item/weaponcrafting/silkstring
	name = "silkstring"
	desc = "A long piece of Silk that looks like a cable coil."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "silkstring"

//Gunkits

/obj/item/weaponcrafting/gunkit
	name = "weapon parts kit"
	desc = "A weapon parts kit."
	var/obj/item/required_item //The weapon we combine this with to make it into the result
	var/obj/item/result
	icon = 'icons/obj/improvised.dmi'
	icon_state = "kitsuitcase"
	w_class = WEIGHT_CLASS_BULKY
	var/extra_info = "contact a coder"

/obj/item/weaponcrafting/gunkit/attackby(obj/item/gun/W, mob/user, params)
	if(W.type == required_item)
		if(do_after(user, 10 SECONDS, W))
			var/newthing = new result(get_turf(src))
			if(istype(newthing, /obj/item/gun/energy))
				var/obj/item/gun/energy/Q = W
				var/obj/item/gun/energy/N = newthing
				var/power = Q.cell.charge
				if(power < N.cell.charge)
					N.cell.charge = power
				var/obj/item/firing_pin/pin = Q.pin
				Q.pin = null
				if(!isnull(N.pin))
					QDEL_NULL(N.pin)
				pin.forceMove(N)
				N.pin = pin
			qdel(W)
			qdel(src)
	..()

/obj/item/weaponcrafting/gunkit/examine(mob/user)
	. =..()
	. += span_notice(extra_info)

/obj/item/weaponcrafting/gunkit/teleshield
	name = "riot shield modification kit"
	desc = "A set of lightweight replacement parts and hinges that enables a riot shield to fold up for easy transport."
	required_item = /obj/item/shield/riot
	result = /obj/item/shield/riot/tele
	extra_info = "It requires a riot shield."

/obj/item/weaponcrafting/gunkit/aeg
	name = "energy gun charging upgrade parts"
	desc = "A packaged miniature nuclear reactor that plugs into the charging port of an energy gun, allowing it to self-charge when fed with uranium."
	required_item = /obj/item/gun/energy/e_gun
	result = /obj/item/gun/energy/e_gun/nuclear
	extra_info = "It requires an energy gun."

/obj/item/weaponcrafting/gunkit/xray
	name = "laser gun x-ray lens replacement kit"
	desc = "A set of parts that replaces components in a stock laser gun, allowing the gun to fire concentrated bursts of X-Ray radiation."
	required_item = /obj/item/gun/energy/laser
	result = /obj/item/gun/energy/xray
	extra_info = "It requires a laser gun."

/obj/item/weaponcrafting/gunkit/beamrifle
	name = "x-ray laser gun capacitor upgrade"
	desc = "A kit containing an enlarged chassis and enhanced internal components for an X-Ray laser gun, enabling it to fire explosive charges of energy."
	required_item = /obj/item/gun/energy/xray
	result = /obj/item/gun/energy/beam_rifle
	extra_info = "It requires an x-ray laser gun."

/obj/item/weaponcrafting/gunkit/teslagun
	name = "laser gun capacitor upgrade"
	desc = "A set of complex and poorly-understood parts that enables a laser gun to fire arcing balls of electricity."
	required_item = /obj/item/gun/energy/laser
	result = /obj/item/gun/energy/tesla_revolver
	extra_info = "It requires a laser gun."

/obj/item/weaponcrafting/gunkit/decloner
	name = "strange laser gun upgrade kit"
	desc = "A bizzare looking set of parts that enables a laser gun to damage the very fabric of a victim's DNA."
	required_item = /obj/item/gun/energy/laser
	result = /obj/item/gun/energy/decloner
	extra_info = "It requires a laser gun."

/obj/item/weaponcrafting/gunkit/tempgun
	name = "laser gun thermal lens upgrade kit"
	desc = "A replacement modulator and lens for a laser gun, enabling it to fire beams that can either heat or cool the internal body temperature of the victim."
	required_item = /obj/item/gun/energy/laser
	result = /obj/item/gun/energy/temperature
	extra_info = "It requires a laser gun."

/obj/item/weaponcrafting/gunkit/ioncarbine
	name = "laser gun electromagnetic interference upgrade"
	desc = "A kit containing electromagnetic pulse shielding and a replacement lens, enabling it to fire bolts that disable electronics."
	required_item = /obj/item/gun/energy/laser
	result = /obj/item/gun/energy/ionrifle/carbine
	extra_info = "It requires a laser gun."

/obj/item/weaponcrafting/gunkit/bow
	name = "hardlight bow parts kit"
	desc = "An unusual set of parts that entirely cannibalize an energy gun to create a modern energy bow."
	required_item = /obj/item/gun/energy/e_gun
	result = /obj/item/gun/ballistic/bow/energy
	extra_info = "It requires an energy gun."

/obj/item/weaponcrafting/gunkit/mindflayer
	name = "alien looking parts kit"
	desc = "An otherworldly set of parts capable of inflicting neural damage on anyone shot by the finished product. Even looking at it makes your head hurt."
	required_item = /obj/item/gun/energy/laser
	result = /obj/item/gun/energy/mindflayer
	extra_info = "It requires a laser gun"

/obj/item/weaponcrafting/gunkit/bouncer
	name = "volatile parts kit"
	desc = "A kit of parts that allows an energy gun to fire bouncing projectiles."
	required_item = /obj/item/gun/energy/e_gun
	result = /obj/item/gun/energy/e_gun/bouncer
	extra_info = "It requires an energy gun."