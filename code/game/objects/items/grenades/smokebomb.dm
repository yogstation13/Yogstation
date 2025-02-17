/**
 *This is smoke bomb, mezum koman. It is a grenade subtype. All craftmanship is of the highest quality.
 *It menaces with spikes of iron. On it is a depiction of an assistant.
 *The assistant is bleeding. The assistant has a painful expression. The assistant is dead.
 */
/obj/item/grenade/smokebomb
	name = "smoke grenade"
	desc = "Real bruh moment if you ever see this. Probably tell a c*der or something."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "smokewhite"
	inhand_icon_state = "smoke"
	slot_flags = ITEM_SLOT_BELT
	///It's extremely important to keep this list up to date. It helps to generate the insightful description of the smokebomb
	var/list/bruh_moment = list("Dank", "Hip", "Lit", "Based", "Robust", "Bruh", "Gamer") //monkestation edit
	var/writing_utensil = "crayon" //monkestation edit
	//monkestation addition: var for smoke type
	var/smoke_type = /datum/effect_system/fluid_spread/smoke/bad
	//monkestation addition: var for if we have the dumb... i mean insightful bruh description
	var/bruh_description = TRUE

///Here we generate the extremely insightful description.
/obj/item/grenade/smokebomb/Initialize(mapload)
	. = ..()
	if(bruh_description)
		desc = "'[pick(bruh_moment)]' is scribbled on it in [writing_utensil]." //monkestation edit

///Here we generate some smoke and also damage blobs??? for some reason. Honestly not sure why we do that.
/obj/item/grenade/smokebomb/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/smoke = new smoke_type
	smoke.set_up(4, holder = src, location = src)
	smoke.start()
	qdel(smoke) //And deleted again. Sad really.
	for(var/obj/structure/blob/blob in view(8, src))
		var/damage = round(30/(get_dist(blob, src) + 1))
		blob.take_damage(damage, BURN, MELEE, 0)
	qdel(src)

//MONKESTATION EDIT START
/obj/item/grenade/smokebomb/security
	name = "security smoke grenade"
	icon_state = "smokered"
	//dumb list name but i respect the joke
	bruh_moment = list("Cover up", "Plausible Deniability", "Clown B-Gone", "Smoke Em!", "Syndicate Repellant")
	writing_utensil = "chalk"

/obj/item/grenade/smokebomb/nanofrost
	name = "nanofrost smoke grenade"
	icon_state = "smokeblue"
	smoke_type = /datum/effect_system/fluid_spread/smoke/freezing
	desc = "A NanoFrost™ smoke grenade. The smoke neutralizes airborne plasma by converting it into cold nitrogen while freezing vents shut. Handy for dealing with fires."
	bruh_description = FALSE
//MONKESTATION EDIT STOP
