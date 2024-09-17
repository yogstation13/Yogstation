/datum/element/loomable/proc/combine_nearby_stacks(atom/target, obj/item/stack/our_stack)
	for(var/obj/item/stack/nearby_stack as anything in view(1, get_turf(target)))
		if(our_stack.amount >= our_stack.max_amount)
			break
		if(our_stack.can_merge(nearby_stack, inhand = TRUE))
			nearby_stack.merge(our_stack)
