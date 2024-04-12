/obj/item/clothing/neck
	name = "necklace"
	icon = 'icons/obj/clothing/neck.dmi'
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK
	strip_delay = 40
	equip_delay_other = 40

/obj/item/clothing/neck/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		return
	if(!(body_parts_covered & HEAD))
		return
	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask")
	if(HAS_BLOOD_DNA(src))
		var/mutable_appearance/bloody_mask = mutable_appearance('icons/effects/blood.dmi', "maskblood")
		bloody_mask.color = get_blood_dna_color(return_blood_DNA())
		. += bloody_mask

/obj/item/clothing/neck/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	w_class = WEIGHT_CLASS_SMALL
	custom_price = 15

/obj/item/clothing/neck/tie/blue
	name = "blue tie"
	icon_state = "bluetie"

/obj/item/clothing/neck/tie/red
	name = "red tie"
	icon_state = "redtie"

/obj/item/clothing/neck/tie/black
	name = "black tie"
	icon_state = "blacktie"

/obj/item/clothing/neck/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"

/obj/item/clothing/neck/tie/detective
	name = "loose tie"
	desc = "A loosely tied necktie, a perfect accessory for the over-worked detective."
	icon_state = "detective"

/obj/item/clothing/neck/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"

/obj/item/clothing/neck/stethoscope/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] puts \the [src] to [user.p_their()] chest! It looks like [user.p_they()] wont hear much!"))
	return OXYLOSS

/obj/item/clothing/neck/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user.a_intent == INTENT_HELP)
			var/body_part = parse_zone(user.zone_selected)

			var/heart_strength = span_danger("no")
			var/lung_strength = span_danger("no")

			var/obj/item/organ/heart/heart = M.getorganslot(ORGAN_SLOT_HEART)
			var/obj/item/organ/lungs/lungs = M.getorganslot(ORGAN_SLOT_LUNGS)

			if(!(M.stat == DEAD || (HAS_TRAIT(M, TRAIT_FAKEDEATH))))
				if(heart && istype(heart))
					heart_strength = heart.HeartStrengthMessage()
					if(heart.beating)
						heart_strength = heart.HeartStrengthMessage()
				if(lungs && istype(lungs))
					lung_strength = span_danger("strained")
					if(!(M.failed_last_breath || M.losebreath))
						lung_strength = "healthy"

			if(M.stat == DEAD && heart && world.time - M.timeofdeath < DEFIB_TIME_LIMIT)
				heart_strength = span_boldannounce("a faint, fluttery")

			var/diagnosis = (body_part == BODY_ZONE_CHEST ? "You hear [heart_strength] pulse and [lung_strength] respiration." : "You faintly hear [heart_strength] pulse.")
			user.visible_message("[user] places [src] against [M]'s [body_part] and listens attentively.", span_notice("You place [src] against [M]'s [body_part]. [diagnosis]"))
			return
	return ..(M,user)

///////////
//SCARVES//
///////////

/obj/item/clothing/neck/scarf //Default white color, same functionality as beanies.
	name = "white scarf"
	icon_state = "scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	dog_fashion = /datum/dog_fashion/head
	custom_price = 10

/obj/item/clothing/neck/scarf/black
	name = "black scarf"
	icon_state = "scarf"
	color = "#4A4A4B" //Grey but it looks black

/obj/item/clothing/neck/scarf/pink
	name = "pink scarf"
	icon_state = "scarf"
	color = "#F699CD" //Pink

/obj/item/clothing/neck/scarf/red
	name = "red scarf"
	icon_state = "scarf"
	color = "#D91414" //Red

/obj/item/clothing/neck/scarf/green
	name = "green scarf"
	icon_state = "scarf"
	color = "#5C9E54" //Green

/obj/item/clothing/neck/scarf/darkblue
	name = "dark blue scarf"
	icon_state = "scarf"
	color = "#1E85BC" //Blue

/obj/item/clothing/neck/scarf/purple
	name = "purple scarf"
	icon_state = "scarf"
	color = "#9557C5" //Purple

/obj/item/clothing/neck/scarf/yellow
	name = "yellow scarf"
	icon_state = "scarf"
	color = "#E0C14F" //Yellow

/obj/item/clothing/neck/scarf/orange
	name = "orange scarf"
	icon_state = "scarf"
	color = "#C67A4B" //Orange

/obj/item/clothing/neck/scarf/cyan
	name = "cyan scarf"
	icon_state = "scarf"
	color = "#54A3CE" //Cyan


//Striped scarves get their own icons

/obj/item/clothing/neck/scarf/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"

/obj/item/clothing/neck/scarf/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/neck/stripedredscarf
	name = "striped red scarf"
	icon_state = "stripedredscarf"
	custom_price = 10

/obj/item/clothing/neck/stripedgreenscarf
	name = "striped green scarf"
	icon_state = "stripedgreenscarf"
	custom_price = 10

/obj/item/clothing/neck/stripedbluescarf
	name = "striped blue scarf"
	icon_state = "stripedbluescarf"
	custom_price = 10

/obj/item/clothing/neck/petcollar
	name = "pet collar"
	desc = "It has a little bell!"
	icon_state = "petcollar"
	var/tagname = null

/obj/item/clothing/neck/petcollar/Initialize(mapload)
	.= ..()
	AddComponent(/datum/component/squeak, list('sound/effects/collarbell1.ogg'=1,'sound/effects/collarbell2.ogg'=1), 50, 100, 2)

/obj/item/clothing/neck/petcollar/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(ishuman(M))
		return FALSE
	return ..()

/obj/item/clothing/neck/petcollar/attack_self(mob/user)
	tagname = stripped_input(user, "Would you like to change the name on the tag?", "Name your new pet", "Spot", MAX_NAME_LEN)
	name = "[initial(name)] - [tagname]"

/obj/item/clothing/neck/artist
	name = "post-modern scarf"
	icon_state = "artist"
	custom_price = 10

/obj/item/clothing/neck/anti_magic_collar
	name = "anti-magic collar"
	desc = "A tight collar used on prisoners to restrict their use of magic, while leaving them vulnerable to it's effects"
	icon_state = "antimagiccollar"
	resistance_flags = FIRE_PROOF
	var/inmate_name = "none"

/obj/item/clothing/neck/anti_magic_collar/Initialize(mapload)
	..()
	GLOB.tracked_collars += src

/obj/item/clothing/neck/anti_magic_collar/Destroy()
	. = ..()
	GLOB.tracked_collars -= src

/obj/item/clothing/neck/anti_magic_collar/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if((slot & slot_flags))
		to_chat(user, span_danger("You hear the collar click as it locks around your neck!"))
		ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))
		RegisterSignal(user, COMSIG_MOB_RESTRICT_MAGIC, PROC_REF(restrict_casting_magic))
		inmate_name = user.name
		return
	
/obj/item/clothing/neck/anti_magic_collar/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_RESTRICT_MAGIC)
	inmate_name = "none"

///Prevents any magic from being used by the user.
/obj/item/clothing/neck/anti_magic_collar/proc/restrict_casting_magic(mob/user, magic_flags)
	SIGNAL_HANDLER
	return COMPONENT_MAGIC_BLOCKED

/obj/item/clothing/neck/anti_magic_collar/proc/unlock()
	audible_message(span_danger("You hear a click, the collar unlocks!"))
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))

//////////////
//DOPE BLING//
//////////////

/obj/item/clothing/neck/necklace/dope
	name = "gold necklace"
	desc = "Damn, it feels good to be a gangster."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bling"

/obj/item/clothing/neck/neckerchief
	icon = 'icons/obj/clothing/masks.dmi' //In order to reuse the bandana sprite
	w_class = WEIGHT_CLASS_TINY
	var/sourceBandanaType

/obj/item/clothing/neck/neckerchief/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		return
	var/mutable_appearance/realOverlay = mutable_appearance('icons/mob/clothing/mask/mask.dmi', icon_state)
	realOverlay.pixel_y = -3
	. += realOverlay

/obj/item/clothing/neck/neckerchief/AltClick(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.get_item_by_slot(ITEM_SLOT_NECK) == src)
			to_chat(user, span_warning("You can't untie [src] while wearing it!"))
			return
		if(user.is_holding(src))
			var/obj/item/clothing/mask/bandana/newBand = new sourceBandanaType(user)
			var/currentHandIndex = user.get_held_index_of_item(src)
			var/oldName = src.name
			qdel(src)
			user.put_in_hand(newBand, currentHandIndex)
			user.visible_message("[user] unties [oldName] back into a [newBand.name].", "You untie [oldName] back into a [newBand.name].")
		else
			to_chat(user, span_warning("You must be holding [src] in order to untie it!"))

//CentCom

/obj/item/clothing/neck/pauldron
	name = "major's pauldron"
	icon_state = "major"
	item_state = "major"
	desc = "A red padded pauldron signifying the rank of Major; offers a small amount of protection to the wearer."
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST
	armor = list(MELEE = 15, BULLET = 25, LASER = 10, ENERGY = 10, BOMB = 5, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/neck/pauldron/commander
	name = "commodore's pauldron"
	desc = "A gold alloy reinforced pauldron signifying the rank of Commodore;offers a moderate amount of protection to the wearer."
	icon_state = "commodore"
	item_state = "commodore"
	armor = list(MELEE = 25, BULLET = 25, LASER = 20, ENERGY = 20, BOMB = 5, BIO = 10, RAD = 0, FIRE = 0, ACID = 50)

/obj/item/clothing/neck/pauldron/colonel
	name = "colonel's pauldrons"
	desc = "Gold alloy reinforced pauldrons signifying the rank of Colonel; offers slightly more protection than the Commander's pauldron to the wearer."
	icon_state = "colonel"
	item_state = "colonel"
	armor = list(MELEE = 35, BULLET = 30, LASER = 35, ENERGY = 35, BOMB = 5, BIO = 20, RAD = 0, FIRE = 0, ACID = 90)

/obj/item/clothing/neck/cape
	name = "admiral's cape"
	desc = "A sizable green cape with gold connects."
	icon_state = "admiralcape"
	item_state = "admiralcape"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESUITSTORAGE

/obj/item/clothing/neck/cape/grand
	name = "grand admiral's cape"
	desc = "A sizable white cape with gold connects."
	icon_state = "grandadmiral"
	item_state = "grand_admiral"


//Cloaks. No, not THAT kind of cloak.


/obj/item/clothing/neck/cloak
	name = "brown cloak"
	desc = "It's a cape that can be worn around your neck."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "leather"
	item_state = "leather"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESUITSTORAGE

/obj/item/clothing/neck/cloak/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(OXYLOSS)

/obj/item/clothing/neck/cloak/hos
	name = "head of security's cloak"
	desc = "Worn by a stressed spaceman. Also comes in red."
	icon_state = "hoscloak"

/obj/item/clothing/neck/cloak/qm
	name = "quartermaster's cloak"
	desc = "Worn by a false idol. Possibly stolen property."
	icon_state = "qmcloak"

/obj/item/clothing/neck/cloak/cmo
	name = "chief medical officer's cloak"
	desc = "Worn by a dedicated life-saver. It's remarkably clean, and elegant."
	icon_state = "cmocloak"

/obj/item/clothing/neck/cloak/ce
	name = "chief engineer's cloak"
	desc = "Worn by the wielder of an unlimited power. Fireproof!"
	icon_state = "cecloak"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/cloak/rd
	name = "research director's external fabric accentuator"
	desc = "Worn by the head of plasma research. Not fireproof."
	icon_state = "rdcloak"

/obj/item/clothing/neck/cloak/cap
	name = "captain's cloak"
	desc = "Worn by the commander of Space Station 13."
	icon_state = "capcloak"

/obj/item/clothing/neck/cloak/hop
	name = "head of personnel's cloak"
	desc = "Worn by the right hand of the captain. It smells faintly of bureaucracy."
	icon_state = "hopcloak"

/obj/item/clothing/neck/cloak/nukie
	name = "tactical ablative shawl"
	desc = "Worn by the leader of an elite team of nuclear operatives. Commit mass murder in style!"
	icon_state = "nukie_cloak"

/obj/item/clothing/neck/cloak/tribalmantle
	name = "ornate mantle"
	desc = "An ornate mantle commonly worn by a shaman or chieftain."
	icon_state = "tribal-mantle"


///////////
// OTHER //
///////////

/obj/item/clothing/neck/falcon
	name = "falconry pauldron"
	desc = "A thick leather pad for a falcon to rest on. This one comes with a fake bird, free of charge."
	icon = 'icons/obj/clothing/neck.dmi'
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "falcon"
	item_state = "falcon"

/obj/item/clothing/neck/falcon/secconwhistle
	name = "constable's whistle"
	desc = "A small cylindrical whistle meant for blowing out crooks' eardrums."
	icon_state = "secconwhistle"
	item_state = "secconwhistle"
	COOLDOWN_DECLARE(recharge_time)
	var/recharge_rate = 5 SECONDS
	actions_types = list(/datum/action/item_action/blow_whistle)

/obj/item/clothing/neck/falcon/secconwhistle/ui_action_click(mob/user)
	if(!COOLDOWN_FINISHED(src, recharge_time))
		user.balloon_alert(user, "Catch your breath first!")
		return
	playsound(get_turf(src), 'sound/misc/policewhistle.ogg', 30, TRUE, -1)
	user.visible_message(span_warning("[user] blows their whistle!"))
	COOLDOWN_START(src, recharge_time, recharge_rate)

/datum/action/item_action/blow_whistle
	name = "Blow Your Whistle"

// Stealth cloaks

/obj/item/clothing/neck/cloak/ranger
	name = "ranger cloak"
	desc = "A cape that uses light-altering magic to make the wearer invisible and allow them to dodge projectiles. The illusion weakens the more the wearer moves."
	icon_state = "ranger_cloak"

	/// The mob currently wearing this
	var/mob/current_user
	/// How much the user is cloaked as a percentage, which effects the wearer's transparency and dodge chance
	var/cloak = 0
	/// What cloak is capped to
	var/max_cloak = 100
	/// How much the cloak charges per process
	var/cloak_charge_rate = 35
	/// How much the cloak decreases when moving
	var/cloak_move_loss = 7
	/// How much the cloak decreases on a successful dodge
	var/cloak_dodge_loss = 30

	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 75, ACID = 75)	//Resistant to the dangers of the natural world or something

/obj/item/clothing/neck/cloak/ranger/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(on_unequip))

/obj/item/clothing/neck/cloak/ranger/equipped(mob/user, slot)
	. = ..()
	update_signals()

/obj/item/clothing/neck/cloak/ranger/dropped(mob/user)
	. = ..()
	update_signals()

/obj/item/clothing/neck/cloak/ranger/proc/on_unequip(force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	current_user = null
	update_signals()

/obj/item/clothing/neck/cloak/ranger/Destroy()
	set_cloak(0)
	. = ..()

/obj/item/clothing/neck/cloak/ranger/proc/update_signals(user)
	if((!user || (current_user == user)) && current_user == loc && istype(current_user) && current_user.get_item_by_slot(ITEM_SLOT_NECK) == src)
		return TRUE

	set_cloak(0)
	UnregisterSignal(current_user, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_BULLET_ACT))
	if(user)
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_BULLET_ACT))

	var/mob/new_user = loc
	if(istype(new_user) && new_user.get_item_by_slot(ITEM_SLOT_NECK) == src)
		current_user = new_user
		RegisterSignal(current_user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
		RegisterSignal(current_user, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_projectile_hit))
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/neck/cloak/ranger/proc/set_cloak(ammount)
	cloak = clamp(ammount, 0, max_cloak)
	var/mob/user = loc
	if(istype(user))
		animate(user, alpha = round(clamp(255 * (1 - (cloak * 0.01)), 0, 255)), time = 0.5 SECONDS)

/obj/item/clothing/neck/cloak/ranger/process(delta_time)
	if(!update_signals())
		return
	var/mob/user = loc
	if(!istype(user) || !user.get_item_by_slot(ITEM_SLOT_NECK) == src)

		return
	set_cloak(cloak + (cloak_charge_rate * delta_time))

/obj/item/clothing/neck/cloak/ranger/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!isprojectile(hitby) && dodge(owner, hitby, attack_text))
		return TRUE
	return ..()

/obj/item/clothing/neck/cloak/ranger/proc/on_move(mob/user, Dir, Forced = FALSE)
	if(update_signals(user))
		set_cloak(cloak - cloak_move_loss)

/obj/item/clothing/neck/cloak/ranger/proc/on_projectile_hit(mob/living/carbon/human/user, obj/projectile/P, def_zone)
	SIGNAL_HANDLER
	if(dodge(user, P, "[P]"))
		return BULLET_ACT_FORCE_PIERCE

/obj/item/clothing/neck/cloak/ranger/proc/dodge(mob/living/carbon/human/user, atom/movable/hitby, attack_text)
	if(!update_signals(user) || current_user.incapacitated() || !prob(cloak))
		return FALSE

	set_cloak(cloak - cloak_dodge_loss)
	current_user.SpinAnimation(7,1)
	current_user.balloon_alert_to_viewers("Dodged!", "Dodged!", COMBAT_MESSAGE_RANGE)
	current_user.visible_message(span_danger("[current_user] dodges [attack_text]!"), span_userdanger("You dodge [attack_text]"), null, COMBAT_MESSAGE_RANGE)
	return TRUE

/obj/item/clothing/neck/cloak/ranger/syndie
	name = "shadow cloak"
	desc = "A dark red cape that uses advanced chameleon technology to make the wearer nearly invisible and aid them in dodging projectiles. Unable to sustain its image under distress or EMP."
	icon_state = "syndie_cloak"
	max_cloak = 75 //Max 75% dodge is a little quirky
	cloak_move_loss = 5
	cloak_charge_rate = 20
	cloak_dodge_loss = 40
	var/cloak_emp_disable_duration = 10 SECONDS
	var/cloak_emp_loss = 5

/obj/item/clothing/neck/cloak/ranger/syndie/emp_act(severity)
	. = ..()
	if(CHECK_BITFIELD(., EMP_PROTECT_SELF))
		return
	if(severity > EMP_LIGHT)
		TIMER_COOLDOWN_START(src, "cloak_emp_disable", cloak_emp_disable_duration)
	set_cloak(max(cloak - (cloak_emp_loss * severity), 0))

/obj/item/clothing/neck/cloak/ranger/syndie/process(delta_time)
	if(TIMER_COOLDOWN_CHECK(src, "cloak_emp_disable"))
		return
	return ..()
