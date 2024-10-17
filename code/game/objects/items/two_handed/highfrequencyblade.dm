/obj/item/vibro_weapon
	icon = 'icons/obj/weapons/longsword.dmi'
	icon_state = "hfrequency0"
	base_icon_state = "hfrequency"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "vibro sword"
	desc = "A potent weapon capable of cutting through nearly anything. Wielding it in two hands will allow you to deflect gunfire."
	force = 20
	armour_penetration = 100
	throwforce = 20
	throw_speed = 4
	sharpness = SHARP_EDGED
	attack_verb = list("cut", "sliced", "diced")
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/vibro_weapon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = 20, \
		icon_wielded = "[base_icon_state]1", \
	)
	AddComponent(/datum/component/cleave_attack, requires_wielded=TRUE)
	AddComponent(/datum/component/butchering, 20, 105)
	AddComponent(/datum/component/blocking, block_force = 30, block_flags = WEAPON_BLOCK_FLAGS|PROJECTILE_ATTACK|REFLECTIVE_BLOCK|WIELD_TO_BLOCK)

/obj/item/vibro_weapon/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/vibro_weapon/wizard
	desc = "A blade that was mastercrafted by a legendary blacksmith. Its' enchantments let it slash through anything."
	force = 8
	throwforce = 20
	wound_bonus = 20
	bare_wound_bonus = 25

/obj/item/vibro_weapon/wizard/attack_self(mob/user, modifiers)
	if(!IS_WIZARD(user))
		balloon_alert(user, "you're too weak!")
		return
	return ..()
