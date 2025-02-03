/datum/action/cooldown/spell/conjure/cheese/post_summon(obj/item/food/cheese_wheel, atom/cast_on)
	if(istype(cheese_wheel))
		cheese_wheel.preserved_food = TRUE // it's magical cheese
