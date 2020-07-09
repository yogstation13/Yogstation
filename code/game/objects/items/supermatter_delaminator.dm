/obj/item/paper/guides/antag/antinoblium_guide
	info = "Antinoblium Shard User's Manual<br>\
	<ul>\
	<li>Approach an active supermatter crystal with radiation shielded personal protective equipment. DO NOT MAKE PHYSICAL CONTACT.</li>\
	<li>Magnetically attach the data corruptor (also provided) into the supermatter control infrastructure to allow attaching the antinoblium.</li>\
	<li>Open the provided antinoblium container (provided).</li>\
	<li>Use antinoblium extraction tongs (also provided) and apply it to the crystal.</li>\
	<li>Physical contact of any object with the antinoblium shard will fracture the shard and cause a spontaneous energy release.</li>\
	<li>Extricate yourself immediately. You have 5 minutes before the infrastructure fails completely.</li>\
	<li>Upon complete infrastructure failure, the crystal well will destabilize and emit electromagnetic waves that span the entire station.</li>\
	<li>Nanotresen safety controls will announce the destabilization of the crystal. Your identity will likely be compromised, but nothing can be done about the crystal.</li>\
	</ul>"

/obj/item/supermatter_delaminator/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/supermatter_delaminator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/supermatter_delaminator/antinoblium_shard
	icon = 'icons/obj/supermatter_delaminator.dmi'
	name = "antinoblium shard"
	desc = "A small syndicate-engineered shard derived from supermatter. Highly fragile, do not handle without protection!"
	icon_state = "antinoblium_shard"

/obj/item/supermatter_delaminator/antinoblium_shard/attack_tk() // no TK dusting memes
	return FALSE

/obj/item/supermatter_delaminator/antinoblium_shard/can_be_pulled(user) // no drag memes
	return FALSE

/obj/item/supermatter_delaminator/antinoblium_shard/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/hemostat/antinoblium))
		var/obj/item/hemostat/antinoblium/tongs = W
		if (tongs.shard)
			to_chat(user, "<span class='notice'>\The [tongs] is already holding an antinoblium shard!</span>")
			return FALSE
		forceMove(tongs)
		tongs.shard = src
		tongs.update_icon()
		to_chat(user, "<span class='notice'>You carefully pick up [src] with [tongs].</span>")
	else if(istype(W, /obj/item/scalpel/supermatter) || istype(W, /obj/item/nuke_core_container/supermatter/)) // we don't want it to dust
		return
	else
		to_chat(user, "<span class='notice'>As it touches \the [src], both \the [src] and \the [W] burst into dust!</span>")
		radiation_pulse(user, 100)
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		qdel(W)
		qdel(src)

/obj/item/supermatter_delaminator/antinoblium_shard/pickup(mob/living/user)
	..()
	if(!iscarbon(user))
		return FALSE
	var/mob/ded = user
	user.visible_message("<span class='danger'>[ded] reaches out and tries to pick up [src]. [ded.p_their()] body starts to glow and bursts into flames before flashing into dust!</span>",\
			"<span class='userdanger'>You reach for [src] with your hands. That was dumb.</span>",\
			"<span class='italics'>Everything suddenly goes silent.</span>")
	radiation_pulse(user, 500, 2)
	playsound(get_turf(user), 'sound/effects/supermatter.ogg', 50, 1)
	ded.dust()

/obj/item/antinoblium_container
	name = "antinoblium bin"
	desc = "A small cube that houses a stable antinoblium shard  to be safely stored."
	icon = 'icons/obj/supermatter_delaminator.dmi'
	icon_state = "antinoblium_container_sealed"
	//item_state = "tile"
	//lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	//righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	var/obj/item/supermatter_delaminator/antinoblium_shard/shard
	var/sealed = TRUE

/obj/item/antinoblium_container/Initialize()
	. = ..()
	shard = new /obj/item/supermatter_delaminator/antinoblium_shard

/obj/item/antinoblium_container/Destroy()
	QDEL_NULL(shard)
	return ..()

/obj/item/antinoblium_container/proc/load(obj/item/hemostat/antinoblium/T, mob/user)
	if(!istype(T) || !T.shard || shard || sealed)
		return FALSE
	T.shard.forceMove(src)
	shard = T.shard
	T.shard = null
	T.icon_state = "supermatter_tongs"
	icon_state = "antinoblium_container_loaded"
	to_chat(user, "<span class='warning'>Container is resealing...</span>")
	addtimer(CALLBACK(src, .proc/seal), 50)
	return TRUE

/obj/item/antinoblium_container/proc/unload(obj/item/hemostat/antinoblium/T, mob/user)
	if(!istype(T) || T.shard || !shard || sealed)
		return FALSE
	src.shard.forceMove(T)
	T.shard = shard
	shard = null
	T.icon_state = "antinoblium_tongs_loaded"
	icon_state = "antinoblium_container_empty"
	to_chat(user, "<span class='warning'>[user] gingerly takes out the antinoblium shard with the tongs...</span>")
	return TRUE

/obj/item/antinoblium_container/proc/seal()
	if(sealed)
		return
	if(istype(shard) && !sealed)
		STOP_PROCESSING(SSobj, shard)
		icon_state = "antinoblium_container_sealed"
		playsound(src, 'sound/items/Deconstruct.ogg', 60, 1)
		sealed = TRUE
		if(ismob(loc))
			to_chat(loc, "<span class='warning'>[src] is temporarily resealed, [shard] is safely contained.</span>")

/obj/item/antinoblium_container/proc/unseal()
	if(!sealed)
		return
	icon_state = "antinoblium_container_loaded"
	sealed = FALSE
	if(ismob(loc))
		to_chat(loc, "<span class='warning'>[src] is unsealed, the [shard] can now be removed.</span>")

/obj/item/antinoblium_container/attackby(obj/item/hemostat/antinoblium/tongs, mob/user)
	if(istype(tongs))
		if(!tongs.shard)
			unload(tongs, user)
		else
			load(tongs, user)
	else
		return ..()

/obj/item/antinoblium_container/attack_self(mob/user)
	if(sealed && shard)
		if(do_after(user, 100, unseal()))
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>[user] opens the [src] revealing the [shard] contained inside!</span>")
	else if(!sealed && shard)
		if(do_after(user, 100, seal()))
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>[user] seals the [src].</span>")

/obj/item/hemostat/antinoblium
	name = "antinoblium extraction tongs"
	desc = "A pair of tongs made from condensed hyper-noblium gas, searingly cold to the touch, that can safely grip an antinoblium shard."
	icon = 'icons/obj/supermatter_delaminator.dmi'
	icon_state = "antinoblium_tongs"
	toolspeed = 0.75
	damtype = "fire"
	var/obj/item/supermatter_delaminator/antinoblium_shard/shard

/obj/item/hemostat/antinoblium/Destroy()
	QDEL_NULL(shard)
	return ..()

/obj/item/hemostat/antinoblium/update_icon()
	if(shard)
		icon_state = "antinoblium_tongs_loaded"
	else
		icon_state = "antinoblium_tongs"

/obj/item/hemostat/antinoblium/afterattack(atom/O, mob/user, proximity)
	. = ..()
	if(!shard)
		return
	if(proximity && ismovable(O) && O != shard  && !istype(O, /obj/item/antinoblium_container) && !istype(O, /obj/machinery/power/supermatter_crystal))
		Consume(O, user)

/obj/item/hemostat/antinoblium/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum) // no instakill supermatter javelins
	if(shard)
		shard.forceMove(loc)
		visible_message("<span class='notice'>\The [shard] falls out of \the [src] as it hits the ground.</span>")
		shard = null
		update_icon()
	..()

/obj/item/hemostat/antinoblium/proc/Consume(atom/movable/AM, mob/user)
	if(ismob(AM))
		var/mob/victim = AM
		victim.dust()
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(victim)].", "supermatter")
	else
		investigate_log("has consumed [AM].", "supermatter")
		qdel(AM)
	if (user)
		user.visible_message("<span class='danger'>As [user] touches [AM] with \the [src], both flash into dust and silence fills the room...</span>",\
			"<span class='userdanger'>You touch [AM] with [src], and everything suddenly goes silent.\n[AM] and [shard] flash into dust, and soon as you can register this, you do as well.</span>",\
			"<span class='italics'>Everything suddenly goes silent.</span>")
		user.dust()
	radiation_pulse(src, 500, 2)
	empulse(src, 5, 10)
	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
	QDEL_NULL(shard)
	update_icon()

/obj/item/supermatter_corruptor
	name = "supermatter data corruptor bug"
	desc = "A small magnetic object that transfers viral payloads into the control structure it is attached to."
	icon = 'icons/obj/supermatter_delaminator.dmi'
	icon_state = "corruptor"

