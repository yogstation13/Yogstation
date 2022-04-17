/obj/structure/flora/tree/dead/jungle
	icon = 'icons/obj/flora/deadtrees.dmi'
	desc = "A dead tree. How it died, you know not."
	icon_state = "nwtree_1"

/obj/structure/flora/tree/dead/jungle/Initialize()
	. = ..()
	icon_state = "nwtree_[rand(1, 6)]"

/obj/structure/herb
	name = "generic herb"
	desc = "generic herb of some origin"
	icon = 'yogstation/icons/obj/jungle.dmi'
	var/herb_index = 0
	var/identification_response = list(TRUE = list("yeah this some herb right there"), FALSE = list("dunno looks like a fucking plant to me"))

/obj/structure/herb/examine(mob/user)
	. = ..()
	icon_state = "herb"
	var/selection = HAS_TRAIT_FROM(user,get_trait(),JUNGLELAND_TRAIT)
	. += pick(identification_response[selection])

/obj/structure/herb/proc/get_trait()
	return TRAIT_HERB_IDENTIFIED + "_[name]"



/obj/structure/ore_patch
	name = "Exposed ore vein"
	desc = "A patch of rocks and boulders carved from the bedrock below, may contain valuable resources."
	icon = 'yogstation/icons/obj/jungle.dmi'
	max_integrity = 1000
	var/ore_type = null
	var/ore_quantity_upper
	var/ore_quantity_lower
	var/ore_color = COLOR_RED_LIGHT
	var/mutable_appearance/ore_specks
	anchored = TRUE
	density = TRUE

/obj/structure/ore_patch/Initialize()
	. = ..()
	var/index = rand(0,3)
	icon_state = "ore[index]"
	if(ore_type != null)
		ore_specks = mutable_appearance('yogstation/icons/obj/jungle.dmi',"ore_ov[index]")
		ore_specks.color = ore_color
		add_overlay(ore_specks)

/obj/structure/ore_patch/Destroy()
	QDEL_NULL(ore_specks)
	return ..()

/obj/structure/ore_patch/tool_act(mob/living/user, obj/item/I, tool_type)
	if(tool_type != TOOL_MINING)
		return ..()
	
	I.play_tool_sound(user)
	to_chat(user,"You start excavating the vein...")
	if(!do_after(user,5 SECONDS*I.toolspeed,TRUE,src))
		return
		
	if(!ore_type)
		to_chat(user, span_notice("This ore vein is barren!"))
	
	I.play_tool_sound(user)
	take_damage(100-I.force , BRUTE, "", FALSE) //exactly 100 damage ALWAYS
	spawn_ore(1)

/obj/structure/ore_patch/proc/spawn_ore(yield_mult)
	var/quantity = round(rand(ore_quantity_lower,ore_quantity_upper)*yield_mult)
	new ore_type(drop_location(), quantity)

/obj/structure/ore_patch/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	var/_damage_amount = damage_flag == "bomb" ? damage_amount * 10 : damage_amount
	return ..(_damage_amount,damage_type,damage_flag,sound_effect,attack_dir,armour_penetration)

/obj/structure/ore_patch/obj_destruction(damage_flag)
	var/yield = 1

	if(damage_flag == "bomb")
		yield = 10

	spawn_ore(yield)

	return ..()

/obj/structure/ore_patch/iron
	ore_type = /obj/item/stack/ore/iron
	ore_quantity_upper = 5
	ore_quantity_lower = 1
	ore_color = "#878687" 

/obj/structure/ore_patch/plasma
	ore_type = /obj/item/stack/ore/plasma
	ore_quantity_upper = 3
	ore_quantity_lower = 1
	ore_color = "#c716b8"

/obj/structure/ore_patch/uranium
	ore_type = /obj/item/stack/ore/uranium
	ore_quantity_upper = 3
	ore_quantity_lower = 1
	ore_color = "#1fb83b"

/obj/structure/ore_patch/titanium
	ore_type = /obj/item/stack/ore/titanium
	ore_quantity_upper = 4
	ore_quantity_lower = 1
	ore_color = "#b3c0c7"

/obj/structure/ore_patch/gold
	ore_type = /obj/item/stack/ore/gold
	ore_quantity_upper = 3
	ore_quantity_lower = 1
	ore_color = "#f0972b"

/obj/structure/ore_patch/silver
	ore_type = /obj/item/stack/ore/silver
	ore_quantity_upper = 4
	ore_quantity_lower = 1
	ore_color = "#bdbebf"

/obj/structure/ore_patch/diamond
	ore_type = /obj/item/stack/ore/diamond
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#22c2d4"

/obj/structure/ore_patch/bluespace
	ore_type = /obj/item/stack/sheet/bluespace_crystal
	ore_quantity_upper = 2
	ore_quantity_lower = 1
	ore_color = "#506bc7"
