#define RESOLVE_ICON_STATE(worn_item) (worn_item.worn_icon_state || worn_item.icon_state)
	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/* Keep these comments up-to-date if you -insist- on hurting my code-baby ;_;
This system allows you to update individual mob-overlays, without regenerating them all each time.
When we generate overlays we generate the standing version and then rotate the mob as necessary..

As of the time of writing there are 20 layers within this list. Please try to keep this from increasing. //22 and counting, good job guys
	var/overlays_standing[20]		//For the standing stance

Most of the time we only wish to update one overlay:
	e.g. - we dropped the fireaxe out of our left hand and need to remove its icon from our mob
	e.g.2 - our hair colour has changed, so we need to update our hair icons on our mob
In these cases, instead of updating every overlay using the old behaviour (regenerate_icons), we instead call
the appropriate update_X proc.
	e.g. - update_l_hand()
	e.g.2 - update_hair()

Note: Recent changes by aranclanos+carn:
	update_icons() no longer needs to be called.
	the system is easier to use. update_icons() should not be called unless you absolutely -know- you need it.
	IN ALL OTHER CASES it's better to just call the specific update_X procs.

Note: The defines for layer numbers is now kept exclusvely in __DEFINES/misc.dm instead of being defined there,
	then redefined and undefiend everywhere else. If you need to change the layering of sprites (or add a new layer)
	that's where you should start.

All of this means that this code is more maintainable, faster and still fairly easy to use.

There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src), rather than using the helper procs)
	You will need to call the relevant update_inv_* proc

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_damage_overlays()	//handles damage overlays for brute/burn damage
		update_body()				//Handles updating your mob's body layer and mutant bodyparts
									as well as sprite-accessories that didn't really fit elsewhere (underwear, undershirts, socks, lips, eyes)
									//NOTE: update_mutantrace() is now merged into this!
		update_hair()				//Handles updating your hair overlay (used to be update_face, but mouth and
									eyes were merged into update_body())


*/

//HAIR OVERLAY
/mob/living/carbon/human/update_hair()
	dna.species.handle_hair(src)

//used when putting/removing clothes that hide certain mutant body parts to just update those and not update the whole body.
/mob/living/carbon/human/proc/update_mutant_bodyparts()
	dna?.species.handle_mutant_bodyparts(src)

/mob/living/carbon/human/update_body()
	dna?.species.handle_body(src)
	..()

/mob/living/carbon/human/update_fire()
	..((fire_stacks > HUMAN_FIRE_STACK_ICON_NUM) ? "Standing" : "Generic_mob_burning")


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()

	if(!..())
		icon_render_key = null //invalidate bodyparts cache
		update_body()
		update_hair()
		update_inv_w_uniform()
		update_inv_wear_id()
		update_inv_gloves()
		update_inv_glasses()
		update_inv_ears()
		update_inv_shoes()
		update_inv_s_store()
		update_inv_wear_mask()
		update_inv_head()
		update_inv_belt()
		update_inv_back()
		update_inv_wear_suit()
		update_inv_pockets()
		update_inv_neck()
		update_transform()
		//mutations
		update_mutations_overlay()
		//damage overlays
		update_damage_overlays()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_clothing(slot_flags)
	if(slot_flags & ITEM_SLOT_BACK)
		update_inv_back()
	if(slot_flags & ITEM_SLOT_MASK)
		update_inv_wear_mask()
	if(slot_flags & ITEM_SLOT_NECK)
		update_inv_neck()
	if(slot_flags & ITEM_SLOT_HANDCUFFED)
		update_inv_handcuffed()
	if(slot_flags & ITEM_SLOT_LEGCUFFED)
		update_inv_legcuffed()
	if(slot_flags & ITEM_SLOT_BELT)
		update_inv_belt()
	if(slot_flags & ITEM_SLOT_ID)
		update_inv_wear_id()
	if(slot_flags & ITEM_SLOT_EARS)
		update_inv_ears()
	if(slot_flags & ITEM_SLOT_EYES)
		update_inv_glasses()
	if(slot_flags & ITEM_SLOT_GLOVES)
		update_inv_gloves()
	if(slot_flags & ITEM_SLOT_HEAD)
		update_inv_head()
	if(slot_flags & ITEM_SLOT_FEET)
		update_inv_shoes()
	if(slot_flags & ITEM_SLOT_OCLOTHING)
		update_inv_wear_suit()
	if(slot_flags & ITEM_SLOT_ICLOTHING)
		update_inv_w_uniform()
	if(slot_flags & ITEM_SLOT_SUITSTORE)
		update_inv_s_store()
	if(slot_flags & (ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET))
		update_inv_pockets()

/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_ICLOTHING) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/uniform = w_uniform
		uniform.screen_loc = ui_iclothing
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += w_uniform
		update_observer_view(w_uniform,1)

		if(wear_suit && (wear_suit.flags_inv & HIDEJUMPSUIT))
			return
		//This is how non-humanoid clothing works.
		//icon_file MUST be set to null by default, or it causes issues.
		//"override_file = handled_by_bodytype ? icon_file : null" MUST be added to the arguments of build_worn_icon()
		//Friendly reminder that icon_exists(file, state, scream = TRUE) is your friend when debugging this code.
		var/icon_file
		var/target_overlay = RESOLVE_ICON_STATE(uniform) //Selects proper icon from the vars the clothing has (Search define for more.)
		var/obj/item/bodypart/leg/left/l_leg = get_bodypart(BODY_ZONE_L_LEG)
		var/obj/item/bodypart/leg/right/r_leg = get_bodypart(BODY_ZONE_R_LEG)
		var/obj/item/bodypart/chest/chest = get_bodypart(BODY_ZONE_CHEST)
		uniform.species_fitted = null	
		if(uniform.adjusted)
			target_overlay = "[target_overlay]_d"
		if((uniform.mutantrace_variation & DIGITIGRADE_VARIATION) && HAS_TRAIT(src, TRAIT_DIGITIGRADE) && !HAS_TRAIT(src, TRAIT_DIGI_SQUISH)) // yogs - digitigrade alt sprites
			target_overlay = "[target_overlay]_l"  // yogs end
		//Checks for GAGS
		if(uniform.greyscale_config && uniform.greyscale_colors)
			if("GAGS_sprite" in uniform.sprite_sheets)
				var/list/GAGS_species = uniform.sprite_sheets["GAGS_sprite"]
				if((SPECIES_VOX in GAGS_species) && l_leg?.species_id == SPECIES_VOX && r_leg?.species_id == SPECIES_VOX)
					target_overlay += "_vox"
					uniform.species_fitted = SPECIES_VOX
		if(l_leg?.species_id == SPECIES_VOX && (r_leg?.species_id == SPECIES_VOX))//for Vox, it's the Vox legs that make regular sprites not fit
			if(SPECIES_VOX in uniform.sprite_sheets)
				if(icon_exists(uniform.sprite_sheets[SPECIES_VOX], uniform.icon_state))
					icon_file = uniform.sprite_sheets[SPECIES_VOX]
					uniform.species_fitted = SPECIES_VOX
		else if(chest?.species_id in uniform.sprite_sheets)
			if(icon_exists(uniform.sprite_sheets[chest.species_id], uniform.icon_state))
				icon_file = uniform.sprite_sheets[chest.species_id]
				uniform.species_fitted = chest.species_id

		var/mutable_appearance/uniform_overlay

		if((gender == FEMALE && dna.species.is_dimorphic) && uniform.fitted != NO_FEMALE_UNIFORM)
			uniform_overlay = uniform.build_worn_icon(
				default_layer = UNIFORM_LAYER, 
				default_icon_file = icon_file, 
				isinhands = FALSE,
				femaleuniform = uniform.fitted, 
				override_state = target_overlay,
			)

		else
			uniform_overlay = uniform.build_worn_icon(
				default_layer = UNIFORM_LAYER, 
				default_icon_file = icon_file, 
				isinhands = FALSE, 
				override_state = target_overlay,
			)


		if(OFFSET_UNIFORM in dna.species.offset_features)
			uniform_overlay.pixel_x += dna.species.offset_features[OFFSET_UNIFORM][1]
			uniform_overlay.pixel_y += dna.species.offset_features[OFFSET_UNIFORM][2]
		overlays_standing[UNIFORM_LAYER] = uniform_overlay
		apply_overlay(UNIFORM_LAYER)

	update_mutant_bodyparts()


/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_ID) + 1]
		inv.update_appearance(UPDATE_ICON)

	var/mutable_appearance/id_overlay = overlays_standing[ID_LAYER]

	if(wear_id)
		wear_id.screen_loc = ui_id
		if(client && hud_used && hud_used.hud_shown)
			client.screen += wear_id
		update_observer_view(wear_id)

		//TODO: add an icon file for ID slot stuff, so it's less snowflakey
		id_overlay = wear_id.build_worn_icon(default_layer = ID_LAYER, default_icon_file = 'icons/mob/clothing/id/id.dmi')
		if(OFFSET_ID in dna.species.offset_features)
			id_overlay.pixel_x += dna.species.offset_features[OFFSET_ID][1]
			id_overlay.pixel_y += dna.species.offset_features[OFFSET_ID][2]
		overlays_standing[ID_LAYER] = id_overlay

	apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_GLOVES) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_GLOVES) + 1]
		inv.update_appearance(UPDATE_ICON)

	var/obj/item/bodypart/l_arm = get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm = get_bodypart(BODY_ZONE_R_ARM)
	if(!gloves && blood_in_hands)
		var/mutable_appearance/bloody_overlay = mutable_appearance('icons/effects/blood.dmi', "bloodyhands", -GLOVES_LAYER)
		if(icon_exists(bloody_overlay.icon, "[bloody_overlay.icon_state]_[l_arm?.species_id]"))
			bloody_overlay.icon_state = "bloodyhands_[l_arm.species_id]"
		if(get_num_arms(FALSE) < 2)
			if(has_left_hand(FALSE))
				bloody_overlay.icon_state = "bloodyhands_left"
				if(icon_exists(bloody_overlay.icon, "[bloody_overlay.icon_state]_[l_arm?.species_id]"))
					bloody_overlay.icon_state += "_[l_arm.species_id]"
			else if(has_right_hand(FALSE))
				bloody_overlay.icon_state = "bloodyhands_right"
				if(icon_exists(bloody_overlay.icon, "[bloody_overlay.icon_state]_[r_arm?.species_id]"))
					bloody_overlay.icon_state += "_[r_arm.species_id]"
		bloody_overlay.color = get_blood_dna_color(return_blood_DNA())

		overlays_standing[GLOVES_LAYER] = bloody_overlay

	var/mutable_appearance/gloves_overlay = overlays_standing[GLOVES_LAYER]
	if(gloves)
		gloves.screen_loc = ui_gloves
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += gloves
		update_observer_view(gloves,1)
		var/icon_to_use = 'icons/mob/clothing/hands/hands.dmi'
		gloves.species_fitted = null
		if(l_arm?.species_id == r_arm?.species_id)
			if(l_arm.species_id in gloves.sprite_sheets)
				if(icon_exists(gloves.sprite_sheets[l_arm.species_id], gloves.icon_state))
					icon_to_use = gloves.sprite_sheets[l_arm.species_id]
					gloves.species_fitted = l_arm.species_id
		overlays_standing[GLOVES_LAYER] = gloves.build_worn_icon(default_layer = GLOVES_LAYER, default_icon_file = icon_to_use)
		gloves_overlay = overlays_standing[GLOVES_LAYER]
		if(OFFSET_GLOVES in dna.species.offset_features)
			gloves_overlay.pixel_x += dna.species.offset_features[OFFSET_GLOVES][1]
			gloves_overlay.pixel_y += dna.species.offset_features[OFFSET_GLOVES][2]
	overlays_standing[GLOVES_LAYER] = gloves_overlay
	apply_overlay(GLOVES_LAYER)


/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(!head) //decapitated
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EYES) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(glasses)
		glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				client.screen += glasses				//Either way, add the item to the HUD
		update_observer_view(glasses,1)
		if(!(head && (head.flags_inv & HIDEEYES)) && !(wear_mask && (wear_mask.flags_inv & HIDEEYES)))
			var/icon_to_use = 'icons/mob/clothing/eyes/eyes.dmi'
			glasses.species_fitted = null
			if(head.species_id in glasses.sprite_sheets)
				if(icon_exists(glasses.sprite_sheets[head.species_id], glasses.icon_state))
					icon_to_use = glasses.sprite_sheets[head.species_id]
					glasses.species_fitted = head.species_id
			overlays_standing[GLASSES_LAYER] = glasses.build_worn_icon(default_layer = GLASSES_LAYER, default_icon_file = icon_to_use)

		var/mutable_appearance/glasses_overlay = overlays_standing[GLASSES_LAYER]
		if(glasses_overlay)
			if(OFFSET_GLASSES in dna.species.offset_features)
				glasses_overlay.pixel_x += dna.species.offset_features[OFFSET_GLASSES][1]
				glasses_overlay.pixel_y += dna.species.offset_features[OFFSET_GLASSES][2]
			overlays_standing[GLASSES_LAYER] = glasses_overlay
	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)

	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(!head) //decapitated
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EARS) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(ears)
		ears.screen_loc = ui_ears	//move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += ears					//add it to the client's screen
		update_observer_view(ears,1)
		var/icon_to_use = 'icons/mob/clothing/ears/ears.dmi'
		ears.species_fitted = null
		if(head.species_id in ears.sprite_sheets)
			if(icon_exists(ears.sprite_sheets[head.species_id], ears.icon_state))
				icon_to_use = ears.sprite_sheets[head.species_id]
				ears.species_fitted = head.species_id
		overlays_standing[EARS_LAYER] = ears.build_worn_icon(default_layer = EARS_LAYER, default_icon_file = icon_to_use)
		var/mutable_appearance/ears_overlay = overlays_standing[EARS_LAYER]
		if(OFFSET_EARS in dna.species.offset_features)
			ears_overlay.pixel_x += dna.species.offset_features[OFFSET_EARS][1]
			ears_overlay.pixel_y += dna.species.offset_features[OFFSET_EARS][2]
		overlays_standing[EARS_LAYER] = ears_overlay
	apply_overlay(EARS_LAYER)

/mob/living/carbon/human/update_inv_neck()
	remove_overlay(NECK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(wear_neck)
		wear_neck.screen_loc = ui_neck
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += wear_neck					//add it to the client's screen
		update_observer_view(wear_neck,1)
		if(!(ITEM_SLOT_NECK in check_obscured_slots()))
			overlays_standing[NECK_LAYER] = wear_neck.build_worn_icon(default_layer = NECK_LAYER, default_icon_file = 'icons/mob/clothing/neck/neck.dmi')
			var/mutable_appearance/neck_overlay = overlays_standing[NECK_LAYER]
			if(OFFSET_NECK in dna.species.offset_features)
				neck_overlay.pixel_x += dna.species.offset_features[OFFSET_NECK][1]
				neck_overlay.pixel_y += dna.species.offset_features[OFFSET_NECK][2]
			overlays_standing[NECK_LAYER] = neck_overlay
	apply_overlay(NECK_LAYER)

/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(get_num_legs(FALSE) <2)
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_FEET) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(shoes)
		var/target_overlay = RESOLVE_ICON_STATE(shoes)
		var/obj/item/bodypart/leg/left/l_leg = get_bodypart(BODY_ZONE_L_LEG)
		var/obj/item/bodypart/leg/right/r_leg = get_bodypart(BODY_ZONE_R_LEG)
		shoes.species_fitted = null
		if(istype(shoes, /obj/item/clothing/shoes))
			var/obj/item/clothing/shoes/real_shoes = shoes
			if((real_shoes.mutantrace_variation & DIGITIGRADE_VARIATION) && HAS_TRAIT(src, TRAIT_DIGITIGRADE) && !HAS_TRAIT(src, TRAIT_DIGI_SQUISH))
				target_overlay = "[target_overlay]_l"
			if("GAGS_sprite" in real_shoes.sprite_sheets)
				var/list/GAGS_species = real_shoes.sprite_sheets["GAGS_sprite"]
				if((l_leg?.species_id == r_leg?.species_id) && (l_leg.species_id in GAGS_species))
					target_overlay += "_[l_leg.species_id]"
					real_shoes.species_fitted = l_leg.species_id
		shoes.screen_loc = ui_shoes                    //move the item to the appropriate screen loc
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)            //if the inventory is open
				client.screen += shoes                    //add it to client's screen
		update_observer_view(shoes,1)
		var/icon_to_use = DEFAULT_SHOES_FILE
		if((l_leg?.species_id == r_leg?.species_id) && (l_leg.species_id in shoes.sprite_sheets))
			if(icon_exists(shoes.sprite_sheets[l_leg.species_id], shoes.icon_state))
				icon_to_use = shoes.sprite_sheets[l_leg.species_id]
				shoes.species_fitted = l_leg.species_id
		overlays_standing[SHOES_LAYER] = shoes.build_worn_icon(default_layer = SHOES_LAYER, default_icon_file = icon_to_use, override_state = target_overlay)
		var/mutable_appearance/shoes_overlay = overlays_standing[SHOES_LAYER]
		if(OFFSET_SHOES in dna.species.offset_features)
			shoes_overlay.pixel_x += dna.species.offset_features[OFFSET_SHOES][1]
			shoes_overlay.pixel_y += dna.species.offset_features[OFFSET_SHOES][2]
		overlays_standing[SHOES_LAYER] = shoes_overlay

	apply_overlay(SHOES_LAYER)


/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_SUITSTORE) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(s_store)
		s_store.screen_loc = ui_sstore1
		if(client && hud_used && hud_used.hud_shown)
			client.screen += s_store
		update_observer_view(s_store)
		var/t_state = s_store.item_state
		if(!t_state)
			t_state = s_store.icon_state
		overlays_standing[SUIT_STORE_LAYER]	= mutable_appearance('icons/mob/clothing/suit_storage.dmi', t_state, -SUIT_STORE_LAYER)
		var/mutable_appearance/s_store_overlay = overlays_standing[SUIT_STORE_LAYER]
		if(OFFSET_S_STORE in dna.species.offset_features)
			s_store_overlay.pixel_x += dna.species.offset_features[OFFSET_S_STORE][1]
			s_store_overlay.pixel_y += dna.species.offset_features[OFFSET_S_STORE][2]
		overlays_standing[SUIT_STORE_LAYER] = s_store_overlay
	apply_overlay(SUIT_STORE_LAYER)


/mob/living/carbon/human/update_inv_head()
	remove_overlay(HEAD_LAYER)
	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1]
		inv.update_appearance(UPDATE_ICON)
	if(head)
		update_hud_head(head)
		var/obj/item/bodypart/head/head_bodypart = get_bodypart(BODY_ZONE_HEAD)
		var/icon_to_use = 'icons/mob/clothing/head/head.dmi'
		head.species_fitted = null
		if(head_bodypart?.species_id in head.sprite_sheets)
			if(icon_exists(head.sprite_sheets[head_bodypart.species_id], head.icon_state))
				icon_to_use = head.sprite_sheets[head_bodypart.species_id]
				head.species_fitted = head_bodypart.species_id
		overlays_standing[HEAD_LAYER] = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = icon_to_use)
		var/mutable_appearance/head_overlay = overlays_standing[HEAD_LAYER]
		if(OFFSET_HEAD in dna.species.offset_features)
			head_overlay.pixel_x += dna.species.offset_features[OFFSET_HEAD][1]
			head_overlay.pixel_y += dna.species.offset_features[OFFSET_HEAD][2]
	update_mutant_bodyparts()
	apply_overlay(HEAD_LAYER)

/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BELT) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(belt)
		belt.screen_loc = ui_belt
		if(client && hud_used && hud_used.hud_shown)
			client.screen += belt
		update_observer_view(belt)
		var/obj/item/bodypart/chest/chest = get_bodypart(BODY_ZONE_CHEST)
		var/icon_to_use = 'icons/mob/clothing/belt.dmi'
		belt.species_fitted = null
		if(chest?.species_id in belt.sprite_sheets)
			if(icon_exists(belt.sprite_sheets[chest.species_id], belt.icon_state))
				icon_to_use = belt.sprite_sheets[chest.species_id]
				belt.species_fitted = chest.species_id
		overlays_standing[BELT_LAYER] = belt.build_worn_icon(default_layer = BELT_LAYER, default_icon_file = icon_to_use)
		var/mutable_appearance/belt_overlay = overlays_standing[BELT_LAYER]
		if(OFFSET_BELT in dna.species.offset_features)
			belt_overlay.pixel_x += dna.species.offset_features[OFFSET_BELT][1]
			belt_overlay.pixel_y += dna.species.offset_features[OFFSET_BELT][2]
		overlays_standing[BELT_LAYER] = belt_overlay

	apply_overlay(BELT_LAYER)



/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_OCLOTHING) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(istype(wear_suit, /obj/item))
		wear_suit.screen_loc = ui_oclothing
		var/obj/item/clothing/suit/suit = wear_suit
		var/worn_suit_icon = RESOLVE_ICON_STATE(suit)
		if((suit.mutantrace_variation & DIGITIGRADE_VARIATION) && HAS_TRAIT(src, TRAIT_DIGITIGRADE) && !HAS_TRAIT(src, TRAIT_DIGI_SQUISH))
			worn_suit_icon = "[wear_suit.icon_state]_l" // Checks for digitgrade version of a suit and forces the alternate if it does
		if(client && hud_used && hud_used.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += wear_suit
		var/obj/item/bodypart/chest/chest = get_bodypart(BODY_ZONE_CHEST)
		var/icon_to_use = DEFAULT_SUIT_FILE
		suit.species_fitted = null
		var/obj/item/bodypart/leg/left/l_leg = get_bodypart(BODY_ZONE_L_LEG)
		var/obj/item/bodypart/leg/right/r_leg = get_bodypart(BODY_ZONE_R_LEG)
		if(l_leg?.species_id == r_leg?.species_id == SPECIES_VOX)//for Vox, it's the Vox legs that make regular sprites not fit
			if(icon_exists(suit.sprite_sheets[l_leg.species_id], suit.icon_state))
				icon_to_use = suit.sprite_sheets[l_leg.species_id]
				suit.species_fitted = l_leg.species_id
		else if(chest?.species_id in suit.sprite_sheets)
			if(icon_exists(suit.sprite_sheets[chest.species_id], suit.icon_state))
				icon_to_use = suit.sprite_sheets[chest.species_id]
				suit.species_fitted = chest.species_id
		overlays_standing[SUIT_LAYER] = wear_suit.build_worn_icon(default_layer = SUIT_LAYER, default_icon_file = icon_to_use, override_state = worn_suit_icon)
		var/mutable_appearance/suit_overlay = overlays_standing[SUIT_LAYER]
		if(OFFSET_SUIT in dna.species.offset_features)
			suit_overlay.pixel_x += dna.species.offset_features[OFFSET_SUIT][1]
			suit_overlay.pixel_y += dna.species.offset_features[OFFSET_SUIT][2]
			overlays_standing[SUIT_LAYER] = suit_overlay
		update_observer_view(wear_suit,1)
	update_hair()
	update_mutant_bodyparts()

	apply_overlay(SUIT_LAYER)


/mob/living/carbon/human/update_inv_pockets()
	if(client && hud_used)
		var/atom/movable/screen/inventory/inv

		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_LPOCKET) + 1]
		inv.update_appearance(UPDATE_ICON)
		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_RPOCKET) + 1]
		inv.update_appearance(UPDATE_ICON)

		if(l_store)
			l_store.screen_loc = ui_storage1
			if(hud_used.hud_shown)
				client.screen += l_store
			update_observer_view(l_store)

		if(r_store)
			r_store.screen_loc = ui_storage2
			if(hud_used.hud_shown)
				client.screen += r_store
			update_observer_view(r_store)


/mob/living/carbon/human/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(wear_mask)
		var/target_overlay = RESOLVE_ICON_STATE(wear_mask)
		if("snout" in dna.species.mutant_bodyparts) //checks for snout and uses lizard mask variant
			if((wear_mask.mutantrace_variation & DIGITIGRADE_VARIATION) && (!wear_mask.mask_adjusted || (wear_mask.mutantrace_adjusted & DIGITIGRADE_VARIATION)))
				target_overlay = "[target_overlay]_l"
		update_hud_wear_mask(wear_mask)
		if(!(head && (head.flags_inv & HIDEMASK)))
			var/obj/item/bodypart/head/head_bodypart = get_bodypart(BODY_ZONE_HEAD)
			var/icon_to_use = 'icons/mob/clothing/mask/mask.dmi'
			wear_mask.species_fitted = null
			if(head_bodypart.species_id in wear_mask.sprite_sheets)
				if(icon_exists(wear_mask.sprite_sheets[head_bodypart.species_id], wear_mask.icon_state))
					icon_to_use = wear_mask.sprite_sheets[head_bodypart.species_id]
					wear_mask.species_fitted = head_bodypart.species_id
			overlays_standing[FACEMASK_LAYER] = wear_mask.build_worn_icon(default_layer = FACEMASK_LAYER, default_icon_file = icon_to_use, override_state = target_overlay)
			var/mutable_appearance/mask_overlay = overlays_standing[FACEMASK_LAYER]
			if(mask_overlay)
				remove_overlay(FACEMASK_LAYER)
				if(OFFSET_FACEMASK in dna.species.offset_features)
					mask_overlay.pixel_x += dna.species.offset_features[OFFSET_FACEMASK][1]
					mask_overlay.pixel_y += dna.species.offset_features[OFFSET_FACEMASK][2]
					overlays_standing[FACEMASK_LAYER] = mask_overlay
			apply_overlay(FACEMASK_LAYER)
	update_mutant_bodyparts() //e.g. upgate needed because mask now hides lizard snout

/mob/living/carbon/human/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv.update_appearance(UPDATE_ICON)

	if(back)
		update_hud_back(back)
		var/obj/item/bodypart/chest/chest = get_bodypart(BODY_ZONE_CHEST)
		var/icon_to_use = 'icons/mob/clothing/back.dmi'
		back.species_fitted = null
		if(chest?.species_id in back.sprite_sheets)
			if(icon_exists(back.sprite_sheets[chest.species_id], back.icon_state))
				icon_to_use = back.sprite_sheets[chest.species_id]
				back.species_fitted = chest.species_id
		overlays_standing[BACK_LAYER] = back.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = icon_to_use)
		var/mutable_appearance/back_overlay = overlays_standing[BACK_LAYER]
		if(back_overlay)
			remove_overlay(BACK_LAYER)
			if(OFFSET_BACK in dna.species.offset_features)
				back_overlay.pixel_x += dna.species.offset_features[OFFSET_BACK][1]
				back_overlay.pixel_y += dna.species.offset_features[OFFSET_BACK][2]
			overlays_standing[BACK_LAYER] = back_overlay
		apply_overlay(BACK_LAYER)

/proc/wear_female_version(t_color, icon, layer, type, greyscale_colors, flat)
	var/index = "[t_color]-[greyscale_colors]-[flat]"
	var/icon/female_clothing_icon = GLOB.female_clothing_icons[index]
	if(!female_clothing_icon) 	//Create standing/laying icons if they don't exist
		generate_female_clothing(index, t_color, icon, type, flat)
	return mutable_appearance(GLOB.female_clothing_icons[index], layer = -layer) //Grab the standing/laying icons once/if they do exist

/proc/wear_skinny_version(t_color, icon, layer, type, greyscale_colors)
	var/index = "[t_color]-[greyscale_colors]"
	var/icon/skinny_clothing_icon = GLOB.skinny_clothing_icons[index]
	if(!skinny_clothing_icon)
		generate_skinny_clothing(index, t_color, icon, type,)
	return mutable_appearance(GLOB.skinny_clothing_icons[index], layer = -layer)

/mob/living/carbon/human/proc/get_overlays_copy(list/unwantedLayers)
	var/list/out = new
	for(var/i in 1 to TOTAL_LAYERS)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out


//human HUD updates for items in our inventory

//update whether our head item appears on our hud.
/mob/living/carbon/human/update_hud_head(obj/item/I)
	I.screen_loc = ui_head
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our mask item appears on our hud.
/mob/living/carbon/human/update_hud_wear_mask(obj/item/I)
	I.screen_loc = ui_mask
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our neck item appears on our hud.
/mob/living/carbon/human/update_hud_neck(obj/item/I)
	I.screen_loc = ui_neck
	if(client && hud_used && hud_used.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_back(obj/item/I)
	I.screen_loc = ui_back
	if(client && hud_used && hud_used.hud_shown)
		client.screen += I
	update_observer_view(I)

/*
Does everything in relation to building the /mutable_appearance used in the mob's overlays list
covers:
 inhands and any other form of worn item
 centering large appearances
 layering appearances on custom layers
 building appearances from custom icon files

By Remie Richards (yes I'm taking credit because this just removed 90% of the copypaste in update_icons())

state: A string to use as the state, this is FAR too complex to solve in this proc thanks to shitty old code
so it's specified as an argument instead.

default_layer: The layer to draw this on if no other layer is specified

default_icon_file: The icon file to draw states from if no other icon file is specified

isinhands: If true then worn_icon is skipped so that default_icon_file is used,
in this situation default_icon_file is expected to match either the lefthand_ or righthand_ file var

femalueuniform: A value matching a uniform item's fitted var, if this is anything but NO_FEMALE_UNIFORM, we
generate/load female uniform sprites matching all previously decided variables


*/
/obj/item/proc/build_worn_icon(
	default_layer = 0, 
	default_icon_file = null, 
	isinhands = FALSE, 
	femaleuniform = NO_FEMALE_UNIFORM, 
	override_state = null,
)

	var/t_state
	if(override_state)
		t_state = override_state
	else
		t_state = !isinhands ? (worn_icon_state ? worn_icon_state : icon_state) : (item_state ? item_state : icon_state)

	//Find a valid icon file from variables+arguments
	var/file2use = default_icon_file
	if(!isinhands && worn_icon)
		if(!species_fitted || (species_fitted && greyscale_config))
			file2use = worn_icon

	//Find a valid layer from variables+arguments
	var/layer2use = alternate_worn_layer ? alternate_worn_layer : default_layer

	var/mob/living/carbon/human/H = loc

	var/mutable_appearance/standing
	if(femaleuniform)
		if(HAS_TRAIT(H, TRAIT_SKINNY) && (H.underwear == "Nude"))
			standing = wear_skinny_version(t_state, file2use, layer2use, femaleuniform, greyscale_colors)
		else
			standing = wear_female_version(t_state, file2use, layer2use, femaleuniform, greyscale_colors, !!(H.mob_biotypes & MOB_REPTILE)) // lizards 
	if(!standing)
		standing = mutable_appearance(file2use, t_state, -layer2use)

	//Get the overlays for this item when it's being worn
	//eg: ammo counters, primed grenade flashes, etc.
	var/list/worn_overlays = worn_overlays(standing, isinhands, file2use)
	if(worn_overlays?.len)
		standing.overlays.Add(worn_overlays)

	standing = center_image(standing, isinhands ? inhand_x_dimension : worn_x_dimension, isinhands ? inhand_y_dimension : worn_y_dimension)

	//Handle held offsets
	if(istype(H))
		var/list/L = get_held_offsets()
		if(L)
			standing.pixel_x += L["x"] //+= because of center()ing
			standing.pixel_y += L["y"]

	standing.alpha = alpha
	standing.color = color

	return standing


/obj/item/proc/get_held_offsets()
	var/list/L
	if(ismob(loc))
		var/mob/M = loc
		L = M.get_item_offsets_for_index(M.get_held_index_of_item(src))
	return L


//Can't think of a better way to do this, sadly
/mob/proc/get_item_offsets_for_index(i)
	switch(i)
		if(3) //odd = left hands
			return list("x" = 0, "y" = 16)
		if(4) //even = right hands
			return list("x" = 0, "y" = 16)
		else //No offsets or Unwritten number of hands
			return list("x" = 0, "y" = 0)//Handle held offsets

//produces a key based on the human's limbs
/mob/living/carbon/human/generate_icon_render_key()
	. = "[dna.species.limbs_id]"

	if(dna.check_mutation(HULK))
		. += "-coloured-hulk"
	else if(dna.species.use_skintones)
		. += "-coloured-[skin_tone]"
	else if(dna.species.forced_skintone)
		. += "-coloured-[dna.species.forced_skintone]"
	else if(dna.species.fixed_mut_color)
		. += "-coloured-[dna.species.fixed_mut_color]"
	else if(dna.species.get_icon_variant(src))
		. += "-limb-variant-[dna.species.get_icon_variant(src)]"
	else if(dna.features["mcolor"])
		. += "-coloured-[dna.features["mcolor"]]"
	else
		. += "-not_coloured"

	if(dna.species.is_dimorphic)
		. += "-[gender]"

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += "-[BP.body_zone]"
		if(BP.status == BODYPART_ORGANIC)
			. += "-organic"
		else
			. += "-robotic"
		if(BP.use_digitigrade)
			var/squished = HAS_TRAIT(src, TRAIT_DIGI_SQUISH)
			if("[dna.species]" == SPECIES_POLYSMORPH)
				. += "-pdigitigrade[squished]"
			else
				. += "-digitigrade[squished]"
		if(BP.dmg_overlay_type)
			. += "-[BP.dmg_overlay_type]"
		if(BP.has_static_sprite_part)
			var/static_text = "-static"
			if(BP.limb_icon_variant in dna.species.get_special_statics())
				static_text += "-special-[BP.limb_icon_variant]"
			. += static_text

	if(HAS_TRAIT(src, TRAIT_HUSK))
		. += "-husk"

/mob/living/carbon/human/load_limb_from_cache()
	..()
	update_hair()



/mob/living/carbon/human/proc/update_observer_view(obj/item/I, inventory)
	if(observers && observers.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client && observe.client.eye == src)
				if(observe.hud_used)
					if(inventory && !observe.hud_used.inventory_shown)
						continue
					observe.client.screen += I
			else
				observers -= observe
				if(!observers.len)
					observers = null
					break

// Only renders the head of the human
/mob/living/carbon/human/proc/update_body_parts_head_only()
	if (!dna)
		return

	if (!dna.species)
		return

	var/obj/item/bodypart/HD = get_bodypart("head")

	if (!istype(HD))
		return

	HD.update_limb()

	add_overlay(HD.get_limb_icon())
	update_damage_overlays()

	if(HD && !(HAS_TRAIT(src, TRAIT_HUSK)))
		// lipstick
		if(lip_style && (LIPS in dna.species.species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips_[lip_style]", -BODY_LAYER)
			lip_overlay.color = lip_color
			if(OFFSET_FACE in dna.species.offset_features)
				lip_overlay.pixel_x += dna.species.offset_features[OFFSET_FACE][1]
				lip_overlay.pixel_y += dna.species.offset_features[OFFSET_FACE][2]
			add_overlay(lip_overlay)

		// eyes
		if(!(NOEYESPRITES in dna.species.species_traits))
			var/obj/item/organ/eyes/parent_eyes = getorganslot(ORGAN_SLOT_EYES)
			if(parent_eyes)
				add_overlay(parent_eyes.generate_body_overlay(src))
			else
				var/mutable_appearance/missing_eyes = mutable_appearance('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER)
				if(OFFSET_FACE in dna.species.offset_features)
					missing_eyes.pixel_x += dna.species.offset_features[OFFSET_FACE][1]
					missing_eyes.pixel_y += dna.species.offset_features[OFFSET_FACE][2]
				add_overlay(missing_eyes)

	dna.species.handle_hair(src)

	update_inv_head()
	update_inv_wear_mask()

#undef RESOLVE_ICON_STATE
