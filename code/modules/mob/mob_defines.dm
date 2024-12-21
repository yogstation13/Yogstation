/**
  * The mob, usually meant to be a creature of some type
  *
  * Has a client attached that is a living person (most of the time), although I have to admit
  * sometimes it's hard to tell they're sentient
  *
  * Has a lot of the creature game world logic, such as health etc
  */
/mob
	density = TRUE
	layer = MOB_LAYER
	animate_movement = 2
	hud_possible = list(ANTAG_HUD)
	pressure_resistance = 8
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	throwforce = 10
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	// we never want to hide a turf because it's not lit
	// We can rely on the lighting plane to handle that for us
	see_in_dark = 1e6

	/// Whether the context menu is opened with shift-right-click as opposed to right-click
	var/shift_to_open_context_menu = TRUE

	/// Percentage of how much rgb to max the lighting plane at
	/// This lets us brighten it without washing out color
	/// Scale from 0-100, reset off update_sight()
	var/lighting_cutoff = LIGHTING_CUTOFF_VISIBLE
	// Individual color max for red, we can use this to color darkness without tinting the light
	var/lighting_cutoff_red = 0
	// Individual color max for green, we can use this to color darkness without tinting the light
	var/lighting_cutoff_green = 0
	// Individual color max for blue, we can use this to color darkness without tinting the light
	var/lighting_cutoff_blue = 0
	/// A list of red, green and blue cutoffs
	/// This is what actually gets applied to the mob, it's modified by things like glasses
	var/list/lighting_color_cutoffs = null
	var/datum/mind/mind
	var/static/next_mob_id = 0
	/// The current client inhabiting this mob. Managed by login/logout
	/// This exists so we can do cleanup in logout for occasions where a client was transfere rather then destroyed
	/// We need to do this because the mob on logout never actually has a reference to client
	/// We also need to clear this var/do other cleanup in client/Destroy, since that happens before logout
	/// HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
	var/client/canon_client

	/// List of movement speed modifiers applying to this mob
	var/list/movespeed_modification				//Lazy list, see mob_movespeed.dm
	/// The calculated mob speed slowdown based on the modifiers list
	var/cached_multiplicative_slowdown
	/// List of action hud items the user has
	var/list/datum/action/actions = list()
	/// Actions that belong to this mob used in observers
	var/list/datum/action/originalactions = list()
	/// A list of chameleon actions we have specifically
	/// This can be unified with the actions list
	var/list/datum/action/item_action/chameleon/chameleon_item_actions

	/// Whether a mob is alive or dead. TODO: Move this to living - Nodrak (2019, still here)
	var/stat = CONSCIOUS

	/* A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/

	///How many legs does this mob currently have. Should only be changed through set_num_legs()
	var/num_legs = 2

	/// The zone this mob is currently targeting
	var/zone_selected = BODY_ZONE_CHEST

	var/computer_id = null
	var/list/logging = list()

	/// The machine the mob is interacting with (this is very bad old code btw)
	var/obj/machinery/machine = null

	/// Tick time the mob can next move
	var/next_move = null

	/**
	  * Magic var that stops you moving and interacting with anything
	  *
	  * Set when you're being turned into something else and also used in a bunch of places
	  * it probably shouldn't really be
	  */
	var/notransform = null	//Carbon

	/// Is the mob blind
	var/eye_blind = 0		//Carbon
	/// Does the mob have blurry sight
	var/eye_blurry = 0		//Carbon
	/// What is the mobs real name (name is overridden for disguises etc)
	var/real_name = null
	/// Is the mob pixel shifted
	var/is_shifted = FALSE
	/// can this mob move freely in space (should be a trait)
	var/spacewalk = FALSE

	/**
	  * back up of the real name during admin possession
	  *
	  * If an admin possesses an object it's real name is set to the admin name and this
	  * stores whatever the real name was previously. When possession ends, the real name
	  * is reset to this value
	  */
	var/name_archive //For admin things like possession

	/// Default body temperature
	var/bodytemperature = BODYTEMP_NORMAL	//310.15K / 98.6F
	var/nutrition = NUTRITION_LEVEL_START_MIN // randomised in Initialize
	/// Satiation level of the mob
	var/satiety = 0//Carbon

	/// How many ticks this mob has been over reating
	var/overeatduration = 0		// How long this guy is overeating //Carbon

	///Whether grab mode is enabled
	var/grab_mode = FALSE
	///Whether combat mode is enabled
	var/combat_mode = FALSE
	///Whether combat mode can be toggled
	var/can_toggle_combat = TRUE

	/// The movement intent of the mob (run/wal)
	var/m_intent = MOVE_INTENT_RUN//Living

	/// The last known IP of the client who was in this mob
	var/lastKnownIP = null

	/// movable atoms buckled to this mob
	var/atom/movable/buckled = null//Living
	/// movable atom we are buckled to
	var/atom/movable/buckling

	//Hands
	///What hand is the active hand
	var/active_hand_index = 1
	/**
	  * list of items held in hands
	  *
	  * len = number of hands, eg: 2 nulls is 2 empty hands, 1 item and 1 null is 1 full hand
	  * and 1 empty hand.
	  *
	  * NB: contains nulls!
	  *
	  * held_items[active_hand_index] is the actively held item, but please use
	  * get_active_held_item() instead, because OOP
	  */
	var/list/held_items = list()

	//HUD things

	/// Storage component (for mob inventory)
	var/datum/component/storage/active_storage
	/// Active hud
	var/datum/hud/hud_used = null
	/// I have no idea tbh
	var/research_scanner = FALSE
	/// What icon the mob uses for typing indicators
	var/bubble_icon = BUBBLE_DEFAULT

	/// Is the mob throw intent on
	var/in_throw_mode = 0

	/// What job does this mob have
	var/job = null//Living

	/// A list of factions that this mob is currently in, for hostile mob targetting, amongst other things
	var/list/faction = list("neutral")

	/// Can this mob enter shuttles
	var/move_on_shuttle = 1

	///A weakref to the last mob/living/carbon to push/drag/grab this mob (exclusively used by slimes friend recognition)
	var/datum/weakref/LAssailant = null

	/// bitflags defining which status effects can be inflicted (replaces canknockdown, canstun, etc)
	var/status_flags = CANSTUN|CANKNOCKDOWN|CANUNCONSCIOUS|CANPUSH

	/// Can they be tracked by the AI?
	var/digitalcamo = 0
	///Are they ivisible to the AI?
	var/digitalinvis = 0
	///what does the AI see instead of them?
	var/image/digitaldisguise = null

	/// Can they interact with station electronics
	var/has_unlimited_silicon_privilege = 0

	///Used by admins to possess objects. All mobs should have this var
	var/obj/control_object

	///Calls relay_move() to whatever this is set to when the mob tries to move
	var/atom/movable/remote_control

	/**
	  * The sound made on death
	  *
	  * leave null for no sound. used for *deathgasp
	  */
	var/deathsound

	///the current turf being examined in the stat panel
	var/turf/listed_turf = null

	///The list of people observing this mob.
	var/list/observers = null

	///List of progress bars this mob is currently seeing for actions
	var/list/progressbars = null	//for stacking do_after bars

	///List of datums that this has which make use of MouseMove()
	var/list/mousemove_intercept_objects

	///Allows a datum to intercept all click calls this mob is the so
	var/datum/click_intercept

	///For storing what do_after's someone has, in case we want to restrict them to only one of a certain do_after at a time
	var/list/do_afters

	///THe z level this mob is currently registered in
	var/registered_z = null

	///Size of the user's memory(IC notes)
	var/memory_amt = 0

	/// Used for tracking last uses of emotes for cooldown purposes
	var/list/emotes_used

	///Whether the mob is updating glide size when movespeed updates or not
	var/updating_glide_size = TRUE

	/// A mock client, provided by tests and friends
	var/datum/client_interface/mock_client

	var/create_area_cooldown

	var/sound_environment_override = SOUND_ENVIRONMENT_NONE

	var/action_speed_modifier = 1 //Value to multiply action delays by //yogs start: fuck

	var/list/alerts = list() // contains /atom/movable/screen/alert only // On /mob so clientless mobs will throw alerts properly

	///Contains the fullscreen overlays the mob can see (from 'code/_onclick/hud/fullscreen.dm')
	var/list/screens = list()

	///The HUD type the mob will gain on Initialize. (from 'code/_onclick/hud/hud.dm')
	var/hud_type = /datum/hud

	///The client colors the mob is looking at. (from 'code/modules/client/client_color.dm')
	var/list/client_colours = list()

	///What receives our keyboard inputs. src by default. (from 'code/modules/keybindings/focus.dm')
	var/datum/focus

	var/fake_client = FALSE // Currently only used for examines

