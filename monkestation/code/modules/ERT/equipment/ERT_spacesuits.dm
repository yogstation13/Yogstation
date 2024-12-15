/datum/armor/ert //might make it weaker later
	melee = 35
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	bio = 30
	fire = 80
	acid = 85
	wound = 10

/obj/item/clothing/suit/space/ert
	name = "emergency response team space suit"
	desc = "A special space suit designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance." // simple description could use more tho
	icon = 'monkestation/icons/obj/clothing/ERT/ERT_spacesuit_obj.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/ERT/ERT_spacesuit_worn.dmi'
	worn_icon_digitigrade = 'monkestation/icons/mob/clothing/ERT/ERT_spacesuit_worn-digi.dmi'
	icon_state = "ert-generic"
	//lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'   do i dare make inhand sprites
	//righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	slowdown = 0 //agile
	max_integrity = 300
	armor_type = /datum/armor/ert
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT //this feels right?
	cell = /obj/item/stock_parts/cell/bluespace
	allowed = list(
		/obj/item/tank/jetpack/oxygen/security,
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/tank/jetpack/oxygen/captain,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/gun/ballistic,
		/obj/item/gun/energy,
		/obj/item/gun/microfusion,
		/obj/item/knife/combat,
		/obj/item/melee/baton,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/storage/belt/holster/detective,
		/obj/item/storage/belt/holster/nukie,
		/obj/item/storage/belt/holster/energy,
	)

/obj/item/clothing/suit/space/ert/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	user.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/obj/item/clothing/suit/space/ert/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	user.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)


/obj/item/clothing/suit/space/ert/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/head/helmet/space/ert
	name = "emergency response team space helmet"
	desc = "A special space helmet designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon = 'monkestation/icons/obj/clothing/ERT/ERT_helmet_obj.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/ERT/ERT_helmet_worn.dmi'
	icon_state = "ert-generic0"
	//styling
	var/style = "generic"
	worn_icon_snouted = 'monkestation/icons/mob/clothing/ERT/ERT_helmet_worn-digi.dmi'
	max_integrity = 300
	armor_type = /datum/armor/ert
	resistance_flags = ACID_PROOF | FIRE_PROOF
	//helmet light
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_outer_range = 5
	light_power = 1
	light_on = FALSE
	var/on = FALSE

/obj/item/clothing/head/helmet/space/ert/attack_self(mob/user)
	on = !on
	icon_state = "ert-[style][on]"
	user.update_worn_head()

	set_light_on(on)

/obj/item/clothing/head/helmet/space/ert/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

// NOW FOR ALL THE VARIATIONS!
//-----------
// Commander
//-----------
/obj/item/clothing/suit/space/ert/commander
	name = "emergency response team commander space suit"
	desc = "A special space suit designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-commander"

/obj/item/clothing/head/helmet/space/ert/commander
	name = "emergency response team commander space helmet"
	desc = "A special space helmet designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-commander0"
	style = "commander"

//---------
// Medical
// --------
/obj/item/clothing/suit/space/ert/medical
	name = "emergency response team medical space suit"
	desc = "A special space suit designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-medical"

/obj/item/clothing/head/helmet/space/ert/medical
	name = "emergency response team medical space helmet"
	desc = "A special space helmet designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-medical0"
	style = "medical"

//----------
// Security
//----------
/obj/item/clothing/suit/space/ert/security
	name = "emergency response team security space suit"
	desc = "A special space suit designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-security"

/obj/item/clothing/head/helmet/space/ert/security
	name = "emergency response team security space helmet"
	desc = "A special space helmet designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-security0"
	style = "security"

//----------
// Engineer
//----------
/obj/item/clothing/suit/space/ert/engineer
	name = "emergency response team engineer space suit"
	desc = "A special space suit designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-engineer"

/obj/item/clothing/head/helmet/space/ert/engineer
	name = "emergency response team engineer space helmet"
	desc = "A special space helmet designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-engineer0"
	style = "engineer"

//----------
// Janitor
//----------
/obj/item/clothing/suit/space/ert/janitor
	name = "emergency response team janitor space suit"
	desc = "A special space suit designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-janitor"

/obj/item/clothing/head/helmet/space/ert/janitor
	name = "emergency response team janitor space helmet"
	desc = "A special space helmet designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-janitor0"
	style = "janitor"

//----------
// Chaplain
//----------
/obj/item/clothing/suit/space/ert/chaplain
	name = "emergency response team chaplain space suit"
	desc = "A special space suit designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-chaplain"

/obj/item/clothing/head/helmet/space/ert/chaplain
	name = "emergency response team chaplain space helmet"
	desc = "A special space helmet designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-chaplain0"
	style = "chaplain"

//-------
// Clown
//-------
/obj/item/clothing/suit/space/ert/clown
	name = "emergency response team clown space suit"
	desc = "A special space suit designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-clown"

/obj/item/clothing/head/helmet/space/ert/clown
	name = "emergency response team clown space helmet"
	desc = "A special space helmet designed by Nanotrasen for use by it's emergency response teams. It has markings to distinguish the role of the wearer at a glance."
	icon_state = "ert-clown0"
	style = "clown"


