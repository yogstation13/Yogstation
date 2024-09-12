/obj/item/artifact_summon_wand
	name = "artifact manipulation wand"
	desc = "A one-use device capable of summoning an artifact from... somewhere.Use the item in hand to change modes. Right Click a disk onto it to load the disk. Right Click the item to attempt to summon an artifact, or slap an existing one to modify it."
	icon = 'icons/obj/device.dmi'
	icon_state = "memorizer2"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	var/obj/item/disk/artifact/slotted_disk
	var/selected_mode = 0
	/// modes are- 0 = random, 1 = blank artifact,2 = disk copy, 3 = disc activator, 4 = disc fault, 5 = disc effect.
	var/max_modes = 5

/obj/item/artifact_summon_wand/attack_self(mob/user, modifiers)
	. = ..()
	selected_mode++
	if(selected_mode > max_modes)
		selected_mode = 0
	var/display_text = "cause a bug. Tell the coders quick!"
	switch(selected_mode)
		if(0)
			display_text = "create a random artifact."
		if(1)
			display_text = "create a blank artifact."
		if(2)
			display_text = "create a copy of inserted disk"
		if(3)
			display_text = "create or modify an artifact with just the inserted disks activator."
		if(4)
			display_text = "create or modify an artifact with just the inserted disks fault."
		if(5)
			display_text = "create or modify an artifact with just the inserted disks effect."
	to_chat(user,span_notice("You set [src] to [display_text]"))

/obj/item/artifact_summon_wand/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon,/obj/item/disk/artifact))
		if(slotted_disk)
			to_chat(user,span_notice("You swap the disk inside [src]"))
			weapon.forceMove(src)
			if(!user.put_in_hand(slotted_disk))
				slotted_disk.forceMove(get_turf(user))
			slotted_disk = weapon
		else
			to_chat(user,span_notice("You slot [weapon] inside [src]"))
			weapon.forceMove(src)
			slotted_disk = weapon
/obj/item/artifact_summon_wand/attack_self_secondary(mob/user, modifiers)
	. = ..()
	summon_artifact(user)

/obj/item/artifact_summon_wand/proc/summon_artifact(mob/user)
	var/turf/attempt_location = get_turf(get_step(user,user.dir))
	if(attempt_location.density)
		return
	visible_message(span_notice("[user] begins to summon an artifact using [src]!"),span_notice("You begin attempting to summon an artifact using [src]..."))
	if(do_after(user,5 SECOND))
		var/obj/new_artifact = spawn_artifact(attempt_location)
		var/datum/component/artifact/art_comp = new_artifact.GetComponent(/datum/component/artifact)
		if(!art_comp)
			visible_message(span_notice("Something goes wrong, and [src] fizzles!"))
			return
		switch(selected_mode)//0 left blank, as we don't need to do anything else.
			if(1)
				art_comp.clear_out()
			if(2)
				art_comp.clear_out()
				if(slotted_disk.activator)
					art_comp.add_activator(slotted_disk.activator)
				if(slotted_disk.fault)
					art_comp.change_fault(slotted_disk.fault)
				if(slotted_disk.effect)
					art_comp.try_add_effect(slotted_disk.effect)
			if(3)
				art_comp.clear_out()
				if(slotted_disk.activator)
					art_comp.add_activator(slotted_disk.activator)
			if(4)
				art_comp.clear_out()
				if(slotted_disk.fault)
					art_comp.change_fault(slotted_disk.fault)
			if(5)
				art_comp.clear_out()
				if(slotted_disk.effect)
					art_comp.try_add_effect(slotted_disk.effect)
		visible_message(span_notice("[new_artifact] appears from nowhere!"),span_notice("You summon [new_artifact], and [src] disintegrates!"))
		if(slotted_disk)
			if(!user.put_in_active_hand(slotted_disk))
				slotted_disk.forceMove(get_turf(user))
		slotted_disk = null
		qdel(src)
	else
		visible_message(span_notice("Something goes wrong, and [src] fizzles!"))

/obj/item/artifact_summon_wand/examine(mob/user)
	. = ..()
	if(slotted_disk)
		. += span_notice("Contains [slotted_disk]")
	switch (selected_mode)
		if(0)
			. += span_notice("Will currently try to summon a random artifact.")
		if(1)
			. += span_notice("Will currently try to summon a blank artifact")
		if(2)
			. += span_notice("Will currently try to copy the disk to a new or existing artifact.")
		if(3)
			. += span_notice("Will currently try to copy the disk activator to a new or existing artifact.")
		if(4)
			. += span_notice("Will currently try to copy the disk fault to a new or existing artifact.")
		if(5)
			. += span_notice("Will currently try to copy the disk effect to a new or existing artifact.")

/obj/item/artifact_summon_wand/attack_atom(atom/attacked_atom, mob/living/user, params)
	var/datum/component/artifact/art_comp = attacked_atom.GetComponent(/datum/component/artifact)
	if(art_comp && slotted_disk)
		visible_message(span_notice("[user] begins trying to configure [attacked_atom] with [src]!"),span_notice("You begin trying to configure the [attacked_atom] with [src]..."))
		if(do_after(user,5 SECOND))
			var/added_anything = FALSE
			switch(selected_mode)
				if(0)
					visible_message(span_notice("...but nothing changed!"))
				if(1)
					art_comp.clear_out()
					visible_message(span_notice("[attacked_atom] is rendered inert!"))
					added_anything = TRUE
				if(2)
					if(slotted_disk.activator)
						added_anything |= art_comp.add_activator(slotted_disk.activator)
					if(slotted_disk.fault)
						added_anything |= art_comp.change_fault(slotted_disk.fault)
					if(slotted_disk.effect)
						added_anything |= art_comp.try_add_effect(slotted_disk.effect)
				if(3)
					if(slotted_disk.activator)
						added_anything |= art_comp.add_activator(slotted_disk.activator)
				if(4)
					if(slotted_disk.fault)
						added_anything |= art_comp.change_fault(slotted_disk.fault)
				if(5)
					if(slotted_disk.effect)
						added_anything |= art_comp.try_add_effect(slotted_disk.effect)
			if(added_anything)
				visible_message(span_notice("[user] configures the [attacked_atom] with [src]!"),span_notice("You configure the [attacked_atom] with [src], which switftly disintegrates!"))
				if(slotted_disk)
					if(!user.put_in_active_hand(slotted_disk))
						slotted_disk.forceMove(get_turf(user))
				slotted_disk = null
				qdel(src)
			else
				visible_message(span_notice("...but nothing changed!"))
		else
			visible_message(span_notice("Something goes wrong, and [src] fizzles!"))
	return ..() //I TAKE NO RESPONSIBILITY FOR CALLING THIS L A S T.

