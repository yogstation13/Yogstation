/// A durathread weave has been used on this item.
#define TRAIT_DURATHREAD_INFUSED "durathread_infused"
#define DOAFTER_SOURCE_DURATHREAD_WEAVE 	"doafter_durathread_weave"

GLOBAL_LIST_INIT(durathread_weave_blacklist, typecacheof(list(
	/obj/item/clothing/gloves/mod,
	/obj/item/clothing/head/beanie/durathread,
	/obj/item/clothing/head/beret/durathread,
	/obj/item/clothing/head/costume/crown,
	/obj/item/clothing/head/helmet/durathread,
	/obj/item/clothing/head/helmet/space,
	/obj/item/clothing/head/hooded/ablative,
	/obj/item/clothing/head/mod,
	/obj/item/clothing/head/utility,
	/obj/item/clothing/mask/bandana/durathread,
	/obj/item/clothing/shoes/magboots,
	/obj/item/clothing/shoes/mod,
	/obj/item/clothing/shoes/sandal,
	/obj/item/clothing/suit/armor,
	/obj/item/clothing/suit/chaplainsuit/armor,
	/obj/item/clothing/suit/hooded/ablative,
	/obj/item/clothing/suit/mod,
	/obj/item/clothing/suit/space,
	/obj/item/clothing/under/misc/durathread,
	/obj/item/clothing/under/rank/cargo/miner,
)))

/obj/item/stack/sheet/durathread/examine(mob/user)
	. = ..()
	. += span_info("You can click on a piece of clothing, with an active welder in your offhand, in order to reinforce it!")

/obj/item/stack/sheet/durathread/afterattack(obj/item/clothing/clothing, mob/living/user, proximity)
	. = ..()
	if(. || !isliving(user) || !proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	var/obj/item/welder
	for(var/obj/item/thingy in user.held_items)
		if(thingy.tool_behaviour == TOOL_WELDER)
			welder = thingy
			break
	if(QDELETED(welder))
		to_chat(user, span_warning("You need to have a welder in your hands in order to reinforce clothing with durathread!"))
		return
	else if(!isclothing(clothing) || QDELING(clothing))
		to_chat(user, span_warning("You can only reinforce clothing with durathread!"))
		return
	else if(is_type_in_typecache(clothing, GLOB.durathread_weave_blacklist))
		to_chat(user, span_warning("You cannot reinforce [clothing] with durathread!"))
		return
	else if(HAS_TRAIT(clothing, TRAIT_DURATHREAD_INFUSED))
		to_chat(user, span_warning("[clothing] already has durathread reinforcement!"))
		return
	else if(amount < 5)
		to_chat(user, span_warning("You need at least 5 durathread to reinforce [src]!"))
		return
	to_chat(user, span_info("You begin to reinforce [clothing] with [src]..."))
	if(!welder.use_tool(clothing, user, 10 SECONDS, 5, extra_checks = CALLBACK(src, PROC_REF(has_enough)), interaction_key = DOAFTER_SOURCE_DURATHREAD_WEAVE))
		to_chat(user, span_warning("You fail to reinforce [clothing]!"))
		return
	var/datum/armor/clothing_armor = clothing.get_armor()
	var/datum/armor/reinforced_armor = clothing_armor?.combine_max_armor(get_armor_by_type(/datum/armor/durathread_weave))
	if(isnull(reinforced_armor))
		CRASH("Got null armor when trying to reinforce clothing with durathread.")
	else if(reinforced_armor ~= clothing_armor) // the armor was already as good as or better than the durathread reinforcement
		to_chat(user, span_warning("[clothing] cannot be further reinforced!"))
		return
	if(!use(5))
		to_chat(user, span_warning("You need at least 5 durathread to reinforce [src]!"))
		return
	to_chat(user, span_info("You reinforce [clothing] with durathread!"))
	clothing.set_armor(reinforced_armor)
	clothing.name = "durathread-reinforced [clothing.name]"
	ADD_TRAIT(clothing, TRAIT_DURATHREAD_INFUSED, CLOTHING_TRAIT)

/obj/item/stack/sheet/durathread/proc/has_enough()
	return amount >= 5

/datum/armor/durathread_weave
	melee = 20
	bullet = 10
	laser = 30
	energy = 30
	fire = 35
	acid = 35
	wound = 20

#undef DOAFTER_SOURCE_DURATHREAD_WEAVE
