/obj/item/bigspoon
	name = "comically large spoon"
	desc = "For when you're only allowed one spoonful of something."
	icon = 'icons/obj/kitchen.dmi'
	mob_overlay_icon = 'yogstation/icons/mob/clothing/back.dmi'
	icon_state = "bigspoon"
	item_state = "bigspoon0"
	base_icon_state = "bigspoon"
	lefthand_file = 'yogstation/icons/mob/inhands/weapons/bigspoon_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/weapons/bigspoon_righthand.dmi'
	force = 2 //It's a big unwieldy for one hand
	sharpness = SHARP_NONE //issa spoon
	armour_penetration = -50 //literally couldn't possibly be a worse weapon for hitting armour
	throwforce = 1 //it's terribly weighted, what do you expect?
	hitsound = 'sound/items/trayhit1.ogg'
	attack_verb = list("scooped", "bopped", "spooned", "wacked")
	block_chance = 30 //Only works in melee, but I bet your ass you could raise its handle to deflect a sword
	wound_bonus = -10
	bare_wound_bonus = -15
	materials = list(/datum/material/iron=18000)
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK

/obj/item/bigspoon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = 16, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)
	AddComponent(/datum/component/cleave_attack, requires_wielded=TRUE, no_multi_hit=TRUE)

/obj/item/bigspoon/proc/on_wield(atom/source, mob/living/user)
	hitsound = 'yogstation/sound/weapons/bat_hit.ogg'

/obj/item/bigspoon/proc/on_unwield(atom/source, mob/living/user)
	hitsound = initial(hitsound)

/obj/item/bigspoon/update_icon_state() //i don't know why it's item_state rather than icon_state like every other wielded weapon //because you're changing in-hand icons not the inventory icon
	. = ..()
	item_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]"
