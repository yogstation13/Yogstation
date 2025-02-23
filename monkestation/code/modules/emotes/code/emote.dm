/datum/emote/living/click
	key = "click"
	key_third_person = "clicks their tongue"
	message = "clicks their tongue."
	message_ipc = "makes a click sound."
	message_insect = "clicks their mandibles."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/click/get_sound(mob/living/user)
	if(ismoth(user) || isflyperson(user) || isarachnid(user) || istype(user, /mob/living/basic/mothroach))
		return 'monkestation/sound/creatures/rattle.ogg'
	else if(isipc(user))
		return 'sound/machines/click.ogg'
	else
		return FALSE

/datum/emote/living/zap
	key = "zap"
	key_third_person = "zaps"
	message = "zaps."
	message_param = "zaps %t."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/zap/can_run_emote(mob/user, status_check = TRUE , intentional)
	return ..() && isethereal(user)

/datum/emote/living/zap/get_sound(mob/living/user)
	return 'sound/machines/defib_zap.ogg'

/datum/emote/living/hum
	key = "hum"
	key_third_person = "hums"
	message = "hums."
	message_robot = "lets out a droning hum."
	message_AI = "lets out a droning hum."
	message_ipc = "lets out a droning hum."
	message_mime = "silently hums."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "lets out a hiss."
	message_robot = "plays a hissing noise."
	message_AI = "plays a hissing noise."
	message_ipc = "plays a hissing noise."
	message_mime = "acts out a hiss."
	message_param = "hisses at %t."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/hiss/get_sound(mob/living/user)
	if(islizard(user) || isipc(user) || isAI(user) || iscyborg(user))
		return pick('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg', 'sound/voice/hiss5.ogg', 'sound/voice/hiss6.ogg')
	else if(is_cat_enough(user, include_all_anime = TRUE))
		return pick('monkestation/sound/voice/feline/hiss1.ogg', 'monkestation/sound/voice/feline/hiss2.ogg', 'monkestation/sound/voice/feline/hiss3.ogg')

/datum/emote/living/thumbs_up
	key = "thumbsup"
	key_third_person = "thumbsup"
	message = "flashes a thumbs up."
	message_robot = "makes a crude thumbs up with their 'hands'."
	message_AI = "flashes a quick hologram of a thumbs up."
	message_ipc = "flashes a thumbs up icon."
	message_animal_or_basic = "attempts a thumbs up."
	message_param = "flashes a thumbs up at %t."
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE

/datum/emote/living/thumbs_down
	key = "thumbsdown"
	key_third_person = "thumbsdown"
	message = "flashes a thumbs down."
	message_robot = "makes a crude thumbs down with their 'hands'."
	message_AI = "flashes a quick hologram of a thumbs down."
	message_ipc = "flashes a thumbs down icon."
	message_animal_or_basic = "attempts a thumbs down."
	message_param = "flashes a thumbs down at %t."
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE

/datum/emote/living/whistle
	key = "whistle"
	key_third_person="whistle"
	message = "whistles a few notes."
	message_robot = "whistles a few synthesized notes."
	message_AI = "whistles a synthesized song."
	message_ipc = "whistles a few synthesized notes."
	message_param = "whistles at %t."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_mime = "acts out a scream!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = FALSE

/datum/emote/living/clap1
	key = "clap1"
	key_third_person = "claps once"
	message = "claps once."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	vary = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/clap1/get_sound(mob/living/user)
	return pick('monkestation/code/modules/emotes/sound/claponce1.ogg',
				'monkestation/code/modules/emotes/sound/claponce2.ogg')

/datum/emote/living/clap1/can_run_emote(mob/living/carbon/user, status_check = TRUE , intentional)
	if(user.usable_hands < 2)
		return FALSE
	return ..()

/datum/emote/living/snap2
	key = "snap2"
	key_third_person = "snaps twice"
	message = "snaps twice."
	message_param = "snaps twice at %t."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	vary = TRUE
	sound = 'monkestation/code/modules/emotes/sound/snap2.ogg'

/datum/emote/living/snap3
	key = "snap3"
	key_third_person = "snaps thrice"
	message = "snaps thrice."
	message_param = "snaps thrice at %t."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	vary = TRUE
	sound = 'monkestation/code/modules/emotes/sound/snap3.ogg'

/datum/emote/living/scream/run_emote(mob/user, params, type_override, intentional = FALSE)
	if(!intentional && HAS_TRAIT(user, TRAIT_ANALGESIA))
		return
	return ..()

/datum/emote/living/scream/get_sound(mob/living/user)
	if ((is_cat_enough(user, TRUE) && issilicon(user)) || (is_cat_enough(user, FALSE) && isipc(user)))
		return pick(
			'monkestation/sound/voice/screams/silicon/catscream1.ogg',
			'monkestation/sound/voice/screams/silicon/catscream2.ogg',
			'monkestation/sound/voice/screams/silicon/catscream3.ogg',
			'monkestation/sound/voice/screams/silicon/catscream4.ogg',
			'monkestation/sound/voice/screams/silicon/catscream5.ogg',
		)
	if(issilicon(user))
		return pick(
			'monkestation/sound/voice/screams/silicon/robotAUGH1.ogg',
			'monkestation/sound/voice/screams/silicon/robotAUGH2.ogg',
			'monkestation/sound/voice/screams/silicon/robotAUGH3.ogg',
			'monkestation/sound/voice/screams/silicon/robotAUGH4.ogg',
			'monkestation/sound/voice/screams/silicon/robotAUGH5.ogg')
	if(is_cat_enough(user))
		return pick('monkestation/sound/voice/feline/scream1.ogg', 'monkestation/sound/voice/feline/scream2.ogg', 'monkestation/sound/voice/feline/scream3.ogg')
	// It's not fair to NOT scream like a cat when we're cat, so alt screams get lowest priority
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(length(human_user.alternative_screams))
			return pick(human_user.alternative_screams)
		var/obj/item/organ/internal/tongue/tongue = human_user.get_organ_slot(ORGAN_SLOT_TONGUE)
		. = tongue?.get_scream_sound()
	if(isbasicmob(user))
		var/mob/living/basic/mob = user
		. = mob.get_scream_sound()

/datum/emote/living/scream/should_vary(mob/living/user)
	if(ishuman(user) && !is_cat_enough(user))
		return TRUE
	return ..()

/datum/emote/living/scream/screech //If a human tries to screech it'll just scream.
	key = "screech"
	key_third_person = "screeches"
	message = "screeches!"
	message_mime = "screeches silently."
	emote_type = EMOTE_AUDIBLE
	vary = FALSE

/datum/emote/living/scream/screech/should_play_sound(mob/user, intentional)
	if(ismonkey(user))
		return TRUE
	return ..()

/datum/emote/living/meow
	key = "meow"
	key_third_person = "meows"
	message = "meows."
	message_mime = "acts out a meow."
	message_param = "meows at %t."
	emote_type = EMOTE_AUDIBLE
	audio_cooldown = 1.5 SECONDS

/datum/emote/living/meow/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	return ..() && is_cat_enough(user, include_all_anime = TRUE)

/datum/emote/living/meow/get_sound(mob/living/user)
	if(issilicon(user) || isipc(user))
		return pick(
			'monkestation/sound/voice/feline/silicon/meow1.ogg',
			'monkestation/sound/voice/feline/silicon/meow2.ogg',
			'monkestation/sound/voice/feline/silicon/meow3.ogg',
		)
	if(prob(5))
		return 'monkestation/sound/voice/feline/funnymeow.ogg'
	return pick('monkestation/sound/voice/feline/meow1.ogg', 'monkestation/sound/voice/feline/meow2.ogg', 'monkestation/sound/voice/feline/meow3.ogg', 'monkestation/sound/voice/feline/meow4.ogg')

/datum/emote/living/mggaow
	key = "mggaow"
	key_third_person = "meows loudly"
	message = "meows loudly!"
	message_mime = "emphasizes a meow!"
	message_param = "loudly meows at %t!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	audio_cooldown = 1.5 SECONDS

/datum/emote/living/mggaow/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	return ..() && is_cat_enough(user, include_all_anime = TRUE)

/datum/emote/living/mggaow/get_sound(mob/living/user)
	return 'monkestation/sound/voice/feline/mggaow.ogg'

/datum/emote/living/bark
	key = "bark"
	key_third_person = "barks"
	message = "barks!"
	message_mime = "barks out silence!"
	message_ipc = "makes a synthetic bark!"
	message_param = "barks at %t!"
	emote_type = EMOTE_AUDIBLE
	audio_cooldown = 1.5 SECONDS

/datum/emote/living/bark/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	return ..() && HAS_TRAIT(user, TRAIT_ANIME)

/datum/emote/living/bark/get_sound(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY))
		return 'monkestation/sound/voice/feline/bark.ogg'
	else
		return pick('monkestation/sound/voice/feline/bark.ogg', 'monkestation/sound/voice/feline/bark2.ogg') // Yes, bark trait in feline folder [Bad To The Bone]

/datum/emote/living/purr
	key = "purr"
	key_third_person = "purrs"
	message = "purrs."
	message_mime = "acts out a purr."
	message_param = "purr at %t."
	emote_type = EMOTE_AUDIBLE
	audio_cooldown = 8 SECONDS

/datum/emote/living/purr/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	return ..() && is_cat_enough(user, include_all_anime = TRUE)

/datum/emote/living/purr/get_sound(mob/living/user)
	return 'monkestation/sound/voice/feline/purr.ogg'

/datum/emote/living/weh
	key = "weh"
	key_third_person = "wehs"
	message = "wehs!"
	message_param = "wehs at %t!"
	message_mime = "wehs silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/weh/get_sound(mob/living/user)
	return 'monkestation/sound/voice/weh.ogg'

/datum/emote/living/weh/can_run_emote(mob/user, status_check, intentional)
	return ..() && islizard(user)

/datum/emote/living/squeal
	key = "squeal"
	key_third_person = "squeals"
	message = "squeals!"
	message_param = "squeals at %t!"
	message_mime = "squeals silently!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/squeal/get_sound(mob/living/user)
	return 'monkestation/sound/voice/lizard/squeal.ogg' //This is from Bay

/datum/emote/living/squeal/can_run_emote(mob/user, status_check, intentional)
	return ..() && islizard(user)

/datum/emote/living/tailthump
	key = "thump"
	key_third_person = "thumps their tail"
	message = "thumps their tail!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/tailthump/get_sound(mob/living/user)
	return 'monkestation/sound/voice/lizard/tailthump.ogg' //https://freesound.org/people/TylerAM/sounds/389665/

/datum/emote/living/tailthump/can_run_emote(mob/user, status_check, intentional)
	return ..() && islizard(user)

/datum/emote/squint
	key = "squint"
	key_third_person = "squints"
	message = "squints."
	message_param = "squints at %t."

/datum/emote/living/nodnod
	key = "nodnod"
	key_third_person = "nodnods"
	message = "nodnods."
	message_param = "nodnods at %t."

//The code from 'Start' to 'End' was ported from Russ-station, with permission.
//All credit to 'bitch fish'
//Start
/datum/emote/living/spit
	key = "spit"
	key_third_person = "spits"

/datum/emote/living/spit/run_emote(mob/user, params, type_override, intentional)
	. = ..()

	if(!.)
		return

	if (locate(/datum/action/cooldown/spell/pointed/projectile/spit) in user.actions)
		to_chat(user, "<B>You already have spit in your mouth!</B>")
		return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user

		if(!(human_user.get_bodypart(BODY_ZONE_HEAD)))
			//Aint got no HEAD what da hell
			to_chat(user,"<B>You try to spit but you have no head!</B>")
			return FALSE

	var/datum/action/cooldown/spell/pointed/projectile/spit/spit_action
	if(HAS_TRAIT(user, TRAIT_MIMING))//special spit action for mimes
		spit_action = new /datum/action/cooldown/spell/pointed/projectile/spit/mime(src)
	else
		spit_action = new /datum/action/cooldown/spell/pointed/projectile/spit(src)

	spit_action.Grant(user)

/datum/action/cooldown/spell/pointed/projectile/spit
	name = "Spit"
	desc = "Spit on someone or something."
	button_icon = 'monkestation/code/modules/emotes/icons/actions_spit.dmi'
	button_icon_state = "spit"
	spell_requirements = NONE

	active_msg = "You fill your mouth with phlegm, mucus and spit."
	deactive_msg = "You decide to swallow your spit."

	cast_range = 3
	projectile_type = /obj/projectile/spit
	projectile_amount = 1

	var/emote_gurgle_msg = "gurgles their mouth"
	var/emote_spit_msg = "spits"

	var/boolPlaySound = TRUE

/datum/action/cooldown/spell/pointed/projectile/spit/Grant(mob/grant_to)
	. = ..()

	src.set_click_ability(grant_to)

	if(!owner)
		return

/datum/action/cooldown/spell/pointed/projectile/spit/on_activation(mob/on_who)
	SHOULD_CALL_PARENT(FALSE)

	to_chat(on_who, span_notice("[active_msg]"))
	build_all_button_icons()

	var/mob/living/spitter = on_who
	spitter.audible_message("[emote_gurgle_msg].", deaf_message = span_emote("You see <b>[spitter]</b> gurgle their mouth."), audible_message_flags = EMOTE_MESSAGE)

	if(boolPlaySound)
		playsound(
			spitter,
			'monkestation/code/modules/emotes/sound/spit_windup.ogg',
			vol = 50,
			vary = TRUE,
			ignore_walls = FALSE,
			mixer_channel = CHANNEL_MOB_EMOTES,
		)

	return TRUE

/datum/action/cooldown/spell/pointed/projectile/spit/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	var/mob/living/L = on_who
	src.Remove(L)

/datum/action/cooldown/spell/pointed/projectile/spit/InterceptClickOn(mob/living/user, params, atom/target)
	var/mob/living/spitter = user

	if(ishuman(spitter))
		var/mob/living/carbon/human/humanoid = user
		if(humanoid.is_mouth_covered())
			humanoid.audible_message("[emote_spit_msg] in their mask!", deaf_message = span_emote("You see <b>[spitter]</b> spit in their mask."), audible_message_flags = EMOTE_MESSAGE)
			if(boolPlaySound)
				playsound(
					spitter,
					'monkestation/code/modules/emotes/sound/spit_release.ogg',
					vol = 50,
					vary = TRUE,
					ignore_walls = FALSE,
					mixer_channel = CHANNEL_MOB_EMOTES,
				)
			src.Remove(user)
			return

	. = ..()
	spitter.audible_message("[emote_spit_msg].", deaf_message = span_emote("You see <b>[spitter]</b> spit."), audible_message_flags = EMOTE_MESSAGE)
	if(boolPlaySound)
		playsound(
			spitter,
			'monkestation/code/modules/emotes/sound/spit_release.ogg',
			vol = 50,
			vary = TRUE,
			extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE,
			ignore_walls = FALSE,
			mixer_channel = CHANNEL_MOB_EMOTES,
		)
	src.Remove(user)


/datum/action/cooldown/spell/pointed/projectile/spit/mime
	name = "Silent Spit"
	button_icon = 'monkestation/code/modules/emotes/icons/actions_spit.dmi'
	button_icon_state = "mime_spit"
	active_msg = "You silently fill your mouth with phlegm, mucus and spit."
	background_icon_state = "bg_mime"

	emote_gurgle_msg = "silently gurgles their mouth"
	emote_spit_msg = "silently spits"
	boolPlaySound = FALSE

	projectile_type = /obj/projectile/spit/mime

/obj/projectile/spit
	name = "spit"
	icon = 'monkestation/code/modules/emotes/icons/spit.dmi'
	icon_state = "spit"
	speed = 3
	range = 5
	damage = 0
	armour_penetration = 0
	sharpness = 0
	damage_type = NONE
	wound_bonus = 0
	pass_flags = PASSTABLE | PASSFLAPS

/obj/projectile/spit/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(istype(target, /obj/item/food))
		var/obj/item/food/F = target
		F.reagents.add_reagent(/datum/reagent/consumable/spit,1) //Yummy

/obj/projectile/spit/mime
	hitsound = NONE
	hitsound_wall = NONE

/datum/reagent/consumable/spit
	name = "Spit"
	description = "Saliva, usually from a creatures mouth."
	color = "#b0eeaa"
	reagent_state = LIQUID
	taste_mult = 1
	taste_description = "metallic saltiness"
	nutriment_factor = 0.5 * REAGENTS_METABOLISM
	penetrates_skin = NONE

/datum/emote/spin/speen
	key = "speen"
	key_third_person = "speens"
	message = "speens!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(/mob/living/brain)
	audio_cooldown = 2 SECONDS
	vary = TRUE

/datum/emote/spin/speen/get_sound(mob/living/user)
	return 'monkestation/sound/voice/speen.ogg'
//End
