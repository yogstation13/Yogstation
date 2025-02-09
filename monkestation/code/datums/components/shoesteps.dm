#define DOAFTER_SOURCE_SHOESTEP_TOGGLE "doafter_shoestep_toggle"

///A simple element that lets shoes have togglable custom sounds
/datum/component/shoesteps
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/custom_sounds = list()
	var/sounds = TRUE

/datum/component/shoesteps/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_CLICK_CTRL, PROC_REF(on_ctrl_click))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/component/shoesteps/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_CLICK_CTRL, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/component/shoesteps/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("There seems to be a noisemaker inside, which will change your walking sounds. You can enable or disable it using Ctrl Click.")
	examine_text += span_notice("The noisemaker is currently [(sounds) ? "on" : "off"].")

/datum/component/shoesteps/proc/on_ctrl_click(datum/source, mob/living/carbon/clicker)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(toggle_sounds), clicker)

/datum/component/shoesteps/proc/toggle_sounds(mob/living/carbon/clicker)
	if(!DOING_INTERACTION(clicker, DOAFTER_SOURCE_SHOESTEP_TOGGLE))
		if(do_after(clicker, 1.5 SECONDS, interaction_key = DOAFTER_SOURCE_SHOESTEP_TOGGLE))
			sounds = !sounds
			to_chat(clicker, span_warning("You turn the noisemaker [sounds ? "on" : "off"]."))

/datum/component/shoesteps/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(ishuman(equipper) && (slot & ITEM_SLOT_FEET))
		RegisterSignal(equipper, COMSIG_MOB_PREPARE_STEP_SOUND, PROC_REF(prepare_steps), override = TRUE)

/datum/component/shoesteps/proc/on_drop(datum/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	if(user.get_item_by_slot(ITEM_SLOT_FEET) == source)
		UnregisterSignal(user, COMSIG_MOB_PREPARE_STEP_SOUND)

/datum/component/shoesteps/proc/prepare_steps(mob/living/carbon/source, list/steps)
	SIGNAL_HANDLER
	if(sounds)
		steps[STEP_SOUND_SHOE_OVERRIDE] = custom_sounds

///
//This area is for custom shoe sound lists. Your lists must match the format of the global lists seen in code\__DEFINES\footsteps.dm
//If replacing shoes match the footstep lists. Other footstep overrides can be added later. Their override lists will also have to match their specific formats.
///
/*

custom_sounds = list(
list(sounds),
base volume,
extra range addition
)

*/
/datum/component/shoesteps/combine_boot_sounds
	custom_sounds = list(
		FOOTSTEP_WOOD = list(list(
			'monkestation/sound/effects/hl2/footstep/combinewood1.ogg',
			'monkestation/sound/effects/hl2/footstep/combinewood2.ogg',
			'monkestation/sound/effects/hl2/footstep/combinewood3.ogg',
			'monkestation/sound/effects/hl2/footstep/combinewood4.ogg',
			'monkestation/sound/effects/hl2/footstep/combinewood5.ogg'), 20, 0),
		FOOTSTEP_FLOOR = list(list(
			'monkestation/sound/effects/hl2/footstep/combine1.ogg',
			'monkestation/sound/effects/hl2/footstep/combine2.ogg',
			'monkestation/sound/effects/hl2/footstep/combine3.ogg',
			'monkestation/sound/effects/hl2/footstep/combine4.ogg',
			'monkestation/sound/effects/hl2/footstep/combine5.ogg'), 20, -1),
		FOOTSTEP_PLATING = list(list(
			'monkestation/sound/effects/hl2/footstep/combinemetal1.ogg',
			'monkestation/sound/effects/hl2/footstep/combinemetal2.ogg',
			'monkestation/sound/effects/hl2/footstep/combinemetal3.ogg',
			'monkestation/sound/effects/hl2/footstep/combinemetal4.ogg',
			'monkestation/sound/effects/hl2/footstep/combinemetal5.ogg'), 20, 1),
		FOOTSTEP_CARPET = list(list(
			'monkestation/sound/effects/hl2/footstep/combinedirt1.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt2.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt3.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt4.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt5.ogg'), 20, -1),
		FOOTSTEP_SAND = list(list(
			'monkestation/sound/effects/hl2/footstep/combinedirt1.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt2.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt3.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt4.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt5.ogg'), 20, 0),
		FOOTSTEP_GRASS = list(list(
			'monkestation/sound/effects/hl2/footstep/combinedirt1.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt2.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt3.ogg',
			'monkestation/sound/effects/hl2/footstep/combinedirt4.ogg'), 20, 0),
		FOOTSTEP_WATER = list(list(
			'sound/effects/footstep/water1.ogg',
			'sound/effects/footstep/water2.ogg',
			'sound/effects/footstep/water3.ogg',
			'sound/effects/footstep/water4.ogg'), 100, 1),
		FOOTSTEP_LAVA = list(list(
			'sound/effects/footstep/lava1.ogg',
			'sound/effects/footstep/lava2.ogg',
			'sound/effects/footstep/lava3.ogg'), 100, 0),
		FOOTSTEP_MEAT = list(list(
			'sound/effects/meatslap.ogg'), 100, 0),
		FOOTSTEP_CATWALK = list(list(
			'monkestation/sound/effects/hl2/footstep/combinemetalwalkway1.ogg',
			'monkestation/sound/effects/hl2/footstep/combinemetalwalkway2.ogg',
			'monkestation/sound/effects/hl2/footstep/combinemetalwalkway3.ogg',
			'monkestation/sound/effects/hl2/footstep/combinemetalwalkway4.ogg',
			'monkestation/sound/effects/hl2/footstep/combinemetalwalkway5.ogg'), 20, 1),
		FOOTSTEP_BALL = list(list(
			'monkestation/sound/effects/ballpit.ogg'), 100, 0),
		)

/datum/component/shoesteps/orchestra_hit
	custom_sounds = list(
		FOOTSTEP_WOOD = list(list( // I would like to apologize for this. It was intended as a ohoho joke during development to show off it works
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_FLOOR = list(list(
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_PLATING = list(list(
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_CARPET = list(list(
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_SAND = list(list(
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_GRASS = list(list(
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_WATER = list(list(
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_LAVA = list(list(
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_MEAT = list(list(
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_CATWALK = list(list(
			'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
			'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'), 100, 0),
		FOOTSTEP_BALL = list(list(
			'monkestation/sound/effects/ballpit.ogg'), 100, 0),
		)

/obj/item/clothing/shoes/clown_shoes/orchestra
	name = "musical shoes"
	desc = "the prankster's standard issue clowning shoes. But somethings off about this pair, maybe the band over to the side, off camera, can help us identify whats wrong."
	squeak_sound = list('sound/misc/null.ogg'=1)

/obj/item/clothing/shoes/clown_shoes/orchestra/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shoesteps/orchestra_hit)

#undef DOAFTER_SOURCE_SHOESTEP_TOGGLE
