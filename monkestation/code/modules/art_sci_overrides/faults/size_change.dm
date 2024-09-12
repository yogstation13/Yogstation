/datum/artifact_fault/shrink
	name = "Shrinking Fault"
	trigger_chance = 13
	visible_message = "starts to shrink."

	research_value = 200

/datum/artifact_fault/shrink/on_trigger()
	our_artifact.holder.transform = matrix(our_artifact.holder.transform, 0.9, 0.9, MATRIX_SCALE)
	if(!isstructure(our_artifact.holder))
		return
	var/obj/structure/structure = our_artifact.holder
	structure.w_class--
	if(structure.w_class < WEIGHT_CLASS_TINY)
		our_artifact.holder.visible_message("[our_artifact.holder] vanishes into thin air!")
		qdel(our_artifact.holder)

/datum/artifact_fault/grow
	name = "Growing Fault"
	trigger_chance = 13
	visible_message = "starts to grow."

	var/trigger_count = 0
/datum/artifact_fault/grow/on_trigger()
	trigger_count++
	if(trigger_count<5)
		our_artifact.holder.transform = matrix(our_artifact.holder.transform, 1.1, 1.1, MATRIX_SCALE)
	else
		our_artifact.holder.visible_message("[our_artifact.holder] can't possibly grow any larger!")
		return
	if(!isitem(our_artifact.holder))
		return
	var/obj/item/item = our_artifact.holder
	if(item.w_class > WEIGHT_CLASS_HUGE)
		return

	item.w_class++
	if(item.w_class > WEIGHT_CLASS_HUGE)
		our_artifact.holder.visible_message("[our_artifact.holder] becomes to cumbersome to carry!")
		our_artifact.holder.anchored = TRUE
