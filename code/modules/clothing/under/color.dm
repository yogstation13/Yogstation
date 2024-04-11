/obj/item/clothing/under/color
	name = "jumpsuit"
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	dying_key = DYE_REGISTRY_UNDER
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	icon = 'icons/obj/clothing/under/color.dmi'
	icon_state = "jumpsuit"
	item_state = "jumpsuit"
	worn_icon_state = "jumpsuit"
	mob_overlay_icon = 'icons/mob/clothing/uniform/color.dmi'
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/skirt/color
	dying_key = DYE_REGISTRY_JUMPSKIRT
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	icon = 'icons/obj/clothing/under/color.dmi'
	icon_state = "jumpskirt"
	item_state = "jumpsuit"
	worn_icon_state = "jumpskirt"
	mob_overlay_icon = 'icons/mob/clothing/uniform/color.dmi'	

/obj/item/clothing/under/color/random
	icon_state = "random_jumpsuit"

/obj/item/clothing/under/color/random/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - subtypesof(/obj/item/clothing/under/skirt/color) - /obj/item/clothing/under/color/random - /obj/item/clothing/under/color/grey/glorf - /obj/item/clothing/under/color/black/ghost)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING, initial=TRUE) //or else you end up with naked assistants running around everywhere...
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/skirt/color/random
	icon_state = "random_jumpsuit"		//Skirt variant needed

/obj/item/clothing/under/skirt/color/random/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/under/skirt/color/C = pick(subtypesof(/obj/item/clothing/under/skirt/color) - /obj/item/clothing/under/skirt/color/random)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING)
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	resistance_flags = NONE

/obj/item/clothing/under/skirt/color/black
	name = "black jumpskirt"

/obj/item/clothing/under/color/black/ghost
	item_flags = DROPDEL

/obj/item/clothing/under/color/black/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	greyscale_colors = "#b3b3b3"

/obj/item/clothing/under/skirt/color/grey
	name = "grey jumpskirt"
	desc = "A tasteful grey jumpskirt that reminds you of the good old days."
	greyscale_colors = "#b3b3b3"

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."
	icon_state = "grey_ancient"
	item_state = "gy_suit"
	worn_icon_state = "grey_ancient"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	can_adjust = FALSE

/obj/item/clothing/under/color/grey/glorf/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.forcesay(GLOB.hit_appends)
	return 0

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	greyscale_colors = "#52aecc"

/obj/item/clothing/under/skirt/color/blue
	name = "blue jumpskirt"
	greyscale_colors = "#52aecc"

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	greyscale_colors = "#9ed63a"

/obj/item/clothing/under/skirt/color/green
	name = "green jumpskirt"
	greyscale_colors = "#9ed63a"

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers."
	greyscale_colors = "#ff8c19"

/obj/item/clothing/under/skirt/color/orange
	name = "orange jumpskirt"
	greyscale_colors = "#ff8c19"

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	greyscale_colors = "#ffa69b"

/obj/item/clothing/under/skirt/color/pink
	name = "pink jumpskirt"
	greyscale_colors = "#ffa69b"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	greyscale_colors = "#eb0c07"

/obj/item/clothing/under/skirt/color/red
	name = "red jumpskirt"
	greyscale_colors = "#eb0c07"

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	greyscale_colors = "#ffffff"

/obj/item/clothing/under/skirt/color/white
	name = "white jumpskirt"
	greyscale_colors = "#ffffff"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	greyscale_colors = "#ffe14d"

/obj/item/clothing/under/skirt/color/yellow
	name = "yellow jumpskirt"
	greyscale_colors = "#ffe14d"

/obj/item/clothing/under/color/darkblue
	name = "darkblue jumpsuit"
	greyscale_colors = "#3285ba"

/obj/item/clothing/under/skirt/color/darkblue
	name = "darkblue jumpskirt"
	greyscale_colors = "#3285ba"

/obj/item/clothing/under/color/teal
	name = "teal jumpsuit"
	greyscale_colors = "#77f3b7"

/obj/item/clothing/under/skirt/color/teal
	name = "teal jumpskirt"
	greyscale_colors = "#77f3b7"

/obj/item/clothing/under/color/lightpurple
	name = "purple jumpsuit"
	greyscale_colors = "#9f70cc"

/obj/item/clothing/under/skirt/color/lightpurple
	name = "lightpurple jumpskirt"
	greyscale_colors = "#9f70cc"

/obj/item/clothing/under/color/darkgreen
	name = "darkgreen jumpsuit"
	greyscale_colors = "#6fbc22"

/obj/item/clothing/under/skirt/color/darkgreen
	name = "darkgreen jumpskirt"
	greyscale_colors = "#6fbc22"

/obj/item/clothing/under/color/lightbrown
	name = "lightbrown jumpsuit"
	greyscale_colors = "#c59431"

/obj/item/clothing/under/skirt/color/lightbrown
	name = "lightbrown jumpskirt"
	greyscale_colors = "#c59431"

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	greyscale_colors = "#a17229"

/obj/item/clothing/under/skirt/color/brown
	name = "brown jumpskirt"
	greyscale_colors = "#a17229"

/obj/item/clothing/under/color/maroon
	name = "maroon jumpsuit"
	greyscale_colors = "#cc295f"

/obj/item/clothing/under/skirt/color/maroon
	name = "maroon jumpskirt"
	greyscale_colors = "#cc295f"

/obj/item/clothing/under/color/rainbow
	name = "rainbow jumpsuit"
	desc = "A multi-colored jumpsuit!"
	icon_state = "rainbow"
	item_state = "rainbow"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	can_adjust = FALSE
	flags_1 = NONE

/obj/item/clothing/under/color/jumpskirt/rainbow
	name = "rainbow jumpskirt"
	desc = "A multi-colored jumpskirt!"
	icon_state = "rainbow_skirt"
	item_state = "rainbow_skirt"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	can_adjust = FALSE
	flags_1 = NONE
