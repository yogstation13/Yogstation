/obj/item/clothing/suit/costume/cirno
	name = "\improper Cirno's dress"
	desc = "A dress that is styled like Cirno's."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "cirno_dress"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/head/costume/cirno
	name = "Cirno wig"
	desc = "A wig that is styled like Cirno."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "cirno_hat"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR

/obj/item/clothing/head/costume/pot
	name = "pot shaped hat"
	desc = "You are literally just putting a pot on your head."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "pot"
	inhand_icon_state = null

/obj/item/clothing/mask/zoro
	name = "zoro mask"
	desc = "A mask made to look like an old hero."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "zoro"
	inhand_icon_state = null
	flags_inv = HIDEFACE

/obj/item/clothing/suit/hooded/shark_costume
	name = "shark costume"
	desc = "A costume from Space Sweden"
	icon_state = "blahaj_costume"
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	inhand_icon_state = "blahaj_costume"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET

	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/gun/ballistic/rifle/boltaction/harpoon)
	hoodtype = /obj/item/clothing/head/hooded/shark_hood
	inhand_icon_state = null

/obj/item/clothing/head/hooded/shark_hood
	name = "shark hood"
	desc = "A hood attached to a shark costume."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "blahaj_hood"
	body_parts_covered = HEAD

	flags_inv = HIDEHAIR|HIDEEARS
	inhand_icon_state = null

/obj/item/clothing/under/costume/navy_uniform_gold
	name = "Naval Officer Uniform"
	desc = "A immaculate navy suit studded with gold."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "navy_gold"
	can_adjust = FALSE
	inhand_icon_state = null

/obj/item/clothing/under/costume/syndie_pajamas
	name = "Syndicate Pajamas"
	desc = "Luxurious silk pajamas striped with a blood red accent."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "syndie_pajamas"
	can_adjust = FALSE
	inhand_icon_state = null


/obj/item/clothing/suit/costume/dark_hos
	name = "\improper Dark Head of Security Trench"
	desc = "It's like you're authority, but edgier.  There's a syndicate snake embroidered on the back."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "dark_hos"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/head/costume/dark_hos
	name = "\improper Dark Head of Security Cap"
	desc = "Slip this on and you're gonna be cutting people with that edge."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "dark_hos_cap"
	inhand_icon_state = null

/obj/item/clothing/suit/jacket/bomber/lemon
	name = "lemon assault vest"
	desc = "You can store combustible lemons in this!  Complete with lemon bandolier."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "lemon_bandolier"
	body_parts_covered = CHEST
	inhand_icon_state = null

/obj/item/clothing/under/costume/whitebeard
	name = "\improper Whitebeard's Attire"
	desc = "The garb of a world renowned pirate."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "wbunder"
	worn_icon_state = "wbunder"
	inhand_icon_state = null
	body_parts_covered = LEGS

/obj/item/clothing/neck/whitebeard
	name = "Whitebeard's Jacket"
	desc = "The jacket of a world renowned pirate."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "wbcloak"
	worn_icon_state = "wbcloak"

/obj/item/clothing/suit/costume/beegirl
	name = "Bee's Costume"
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "beegirl"
	body_parts_covered = CHEST|ARMS
	inhand_icon_state = null


/obj/item/clothing/head/costume/space_marine
	name = "Space Marine Helmet"
	desc = "A replica helmet of a Space Marine.  Can be used as a gas mask, but cannot utilize filters."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "space_marine"
	inhand_icon_state = null
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | HEADINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT|HIDEHAIR
	w_class = WEIGHT_CLASS_NORMAL
	armor_type = /datum/armor/mask_gas
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH | PEPPERPROOF

/obj/item/clothing/under/costume/krieg
	name = "\improper Krieg's Attire"
	desc = "The garb of a malicious psycho from the Pandora sector."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "kriegunder"
	worn_icon_state = "kriegunder"
	inhand_icon_state = null
	body_parts_covered = LEGS|ARMS

/obj/item/clothing/mask/krieg
	name = "\improper Krieg's Mask"
	desc = "The mask of a malicious psycho from the Pandora sector."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "kriegmask"
	inhand_icon_state = null
	flags_inv = HIDEFACE

/obj/item/clothing/suit/hooded/aotcloak
	name = "survey corps cloak"
	desc = "A lightweight but durable cloak with an emblem emblazoned on the back."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "aotcloak"
	body_parts_covered = CHEST|ARMS

	allowed = list()
	armor_type = /datum/armor/hooded_wintercoat
	hoodtype = /obj/item/clothing/head/hooded/aotcloak
	layer = NECK_LAYER

/obj/item/clothing/suit/hooded/aotcloak/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/pda,
		/obj/item/radio,
		/obj/item/storage/bag/books,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
	)

/obj/item/clothing/under/costume/aotuniform
	name = "\improper Survey Corps Uniform"
	desc = "The uniform of a Survey Corps member."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "aotuniform"
	worn_icon_state = "aotuniform"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS|LEGS


/obj/item/clothing/head/hooded/aotcloak
	name = "survey corps cloak hood"
	desc = "A cozy winter hood attached to a heavy winter jacket."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "aotcloak_hood"
	body_parts_covered = HEAD

	flags_inv = HIDEHAIR|HIDEEARS
	armor_type = /datum/armor/hooded_winterhood

/obj/item/clothing/head/costume/bells
	name = "Hair ribbons with bells"
	desc = "A cute hair accessory adorned with red ribbons and small bells."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "bells"

/obj/item/clothing/head/costume/zed_officercap
	name = "\improper Zed Officer Cap"
	desc = "Only dumb furries wear this. You notice a smiley face on the insignia."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "zed_officercap"
	inhand_icon_state = null

/obj/item/clothing/mask/igor
	name = "\improper Igor Mask"
	desc = "A mask that resembles a peculiar man named Igor."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "igor_mask"
	inhand_icon_state = null
	flags_inv = HIDEFACE

/obj/item/clothing/suit/costume/violet_jacket
	name = "\improper Violet's Jacket"
	desc = "A jacket resembling the outfit worn by the Phantom Thief known as Violet."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "violet_jacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/toggle/quilark
	name = "discontinued winter coat"
	desc = "An old world coat, it has an old red cross no longer in use. It smells strangely of iron around the neck."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "coat_quilark"
	toggle_noun = "zipper"
	body_parts_covered = CHEST|GROIN|ARMS

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/toggle/quilark/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/pda,
		/obj/item/radio,
		/obj/item/storage/bag/books,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
	)


/obj/item/clothing/head/costume/fur_cap_quilark
	name = "discontinued cross hat"
	desc = "An old world hat, it has a red cross no longer in use. The inside has a strong scent of iron."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "fur_hat_quilark"

/obj/item/clothing/suit/lambcloak
	name = "lamb's cloak"
	desc = "A brilliant red cloak adorned with a bell."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "lambcloak"
	body_parts_covered = CHEST|ARMS

	layer = NECK_LAYER

/obj/item/clothing/suit/hooded/org_thirteen
	name = "\improper Organization 13 Cloak"
	desc = "A large, hooded jacket belonging to an Organization 13 member."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "org_thirteen"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS

	allowed = list()
	armor_type = /datum/armor/hooded_wintercoat
	hoodtype = /obj/item/clothing/head/hooded/org_thirteen


/obj/item/clothing/suit/hooded/org_thirteen/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/pda,
		/obj/item/radio,
		/obj/item/storage/bag/books,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
	)

/obj/item/clothing/head/hooded/org_thirteen
	name = "organization 13 hood"
	desc = "A cozy winter hood attached to a heavy winter jacket."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "org_thirteen_hood"
	body_parts_covered = HEAD

	flags_inv = HIDEHAIR|HIDEEARS
	armor_type = /datum/armor/hooded_winterhood

/obj/item/clothing/suit/jacket/kimono_kumi
	name = "shrine keeper's kimono"
	desc = "An ornately patterned shrine keeper's kimono, it seems a little big?"
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "kimono_kumi"

/obj/item/clothing/under/sarashi_kumi
	name = "shrine keeper's sarashi"
	desc = "Some chest wraps paired with a skirt. It digs at the waist a little."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "sarashi_kumi"
	can_adjust = FALSE

/obj/item/clothing/shoes/sandal/kumi
	name = "shrine keeper's sandals"
	desc = "A fancy pair of sandals made of hinoki."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "sandals_kumi"

/obj/item/clothing/neck/bell
	name = "bell necklace"
	desc = "A bell attached to some string. We really are living in the future."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "neck_bell"

/obj/item/clothing/gloves/fingerless/long
	name = "long fingerless gloves"
	desc = "A pair of fingerless gloves that reaches the elbow."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "fingerless_long"


/obj/item/clothing/suit/toggle/jacket_oliver
	name = "scarved jacket"
	desc = "A jacket that has a scarf. Dandy."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "jacket_oliver"
	toggle_noun = "scarf"

/obj/item/clothing/suit/toggle/jacket_oliver/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/pda,
		/obj/item/radio,
		/obj/item/storage/bag/books,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
	)
/obj/item/clothing/glasses/hud/security/terminated
	name = "terminated security HUD"
	desc = "My job is to protect you."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "sechud_terminated"


/obj/item/clothing/suit/costume/gumball_wizard_robe
	name = "\improper Gumball Wizard Robe"
	desc = "A robe adorned with brightly colored gumballs."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "gumball_wizard_robe"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS|LEGS

/obj/item/clothing/head/costume/gumball_wizard_hat
	name = "\improper Gumball Wizard Robe"
	desc = "A hat adorned with a brightly colored jewel."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "gumball_wizard_hat"
	inhand_icon_state = null

/obj/item/clothing/mask/breath/poob_mask
	name = "yellow gas mask"
	desc = "An old mask that seems fitted for a lizard person, it's yellow with straps everywhere."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "poob_mask"
	inhand_icon_state = null
	flags_inv = HIDEFACE

/obj/item/clothing/suit/toggle/menacing_jacket
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "menacing_jacket"
	name = "menacing jacket"
	desc = "There can only be one dragon."
	body_parts_covered = CHEST|GROIN|ARMS

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/mask/gas/bluedragon66_trenchbiomask
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "bluedragon66_trenchbiomask"
	name = "plague doctor bio-mask"
	desc = "A respiratory mask and hood combo used to keep the wearer from breathing in viral biohazards. Comes with an insulated gas tube. Unlike normal gas masks, it has a long and unnerving beak-shape, resembling the medieval plague doctors of old."

/obj/item/clothing/suit/bio_suit/bluedragon66_biocoat
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "bluedragon66_biocoat"
	name = "plague doctor bio-suit"
	desc = "A sterile biosuit under a thick coat, offering two layers of protection against potential biohazards. Although it's meant to be paired together with it's counterpart, it's sleek and functional- making it quite appealing."

/obj/item/clothing/head/costume/western_wizard_hat
	name = "western wizard hat"
	desc = "A man, a hero, a traveler- the western wizard."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "western_wizard_hat"
	inhand_icon_state = null
	worn_y_offset = 16

/obj/item/clothing/mask/gas/holstein_cow_mask
	name = "holstein cow mask"
	desc = "It's an internals mask covered in paper mache and paint to look like a cow's head. It smells like grass."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "holstein_cow_mask"
	worn_icon_state = "holstein_cow_mask"
	inhand_icon_state = null
	flags_inv = HIDEFACE

/obj/item/clothing/under/costume/holstein_cow_jumpsuit
	name = "holstein cow jumpsuit"
	desc = "A frumpy black and white holstein cow jumpsuit. It smells like grass."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "holstein_cow_jumpsuit"
	worn_icon_state = "holstein_cow_jumpsuit"
	inhand_icon_state = null

/obj/item/clothing/head/costume/noobskyboi_golden_tophat
	name = "golden tophat"
	desc = "A golden tophat. It smells like sulfur and chocolate?"
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing_32x48.dmi'
	icon_state = "noobskyboi_golden_tophat"
	worn_icon_state = "noobskyboi_golden_tophat"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/ophaq_rainbowcoat
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "rainbowcoat"
	name = "rainbow coat"
	desc = "Woah, it's a RAINBOW coat. How's it doing that?"
	body_parts_covered = CHEST|GROIN|ARMS

	armor_type = /datum/armor/hooded_wintercoat
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
/obj/item/clothing/suit/toggle/ophaq_rainbowcoat/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/pda,
		/obj/item/radio,
		/obj/item/storage/bag/books,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/storage/bag/xeno,
	)

/obj/item/clothing/shoes/kindle_kicks/jackboot
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "jackboot_kindle_kicks"
	name = "jackboot kindle kicks"
	desc = "They look just like kindle kicks! But these are boots!"

/obj/item/clothing/suit/hooded/mothysmantle
	name = "mothys mantle"
	desc = "A thick garment that keeps warm and protects those precious wings from harsh weather, also commonly used during festivities. Feels much heavier than it looks. This one seems as if it were specially tailored for someone and has a hood unlike others of it's type."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "mothysmantle"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/mothysmantle
/obj/item/clothing/head/hooded/mothysmantle
	name = "mothys mantle hood"
	desc = "A thick garment that keeps warm and protects those precious wings from harsh weather, also commonly used during festivities. Feels much heavier than it looks. This one seems as if it were specially tailored for someone."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "mothysmantle_hood"

/obj/item/clothing/suit/toggle/centcom_jacket
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "centcom_jacket"
	name = "centcom jacket"
	desc = "A varsity jacket in design of centcom! It seems well made."
	body_parts_covered = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/head/costume/purple_gold_tophat_kid
	name = "purple and gold tophat"
	desc = "It's a purple and gold tophat. Feels like it's from another world almost..."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "purple_gold_tophat_kid"
	inhand_icon_state = null
	worn_y_offset = 6

/obj/item/clothing/mask/dark_skeletal_visage
	name = "dark skeletal visage"
	desc = "It's.. a skull that has been turned into a mask. It's coated in a strong smelling oil."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "dark_skeletal_visage"
	inhand_icon_state = null
	flags_inv = HIDEFACE

/obj/item/clothing/suit/toggle/traxs_jacket
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "traxs_jacket"
	name = "trax's jacket"
	desc = "A comfortable jacket with a yellow scorpion on the back! It seems well made."
	body_parts_covered = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/neck/mist_cloak
	name = "mist cloak"
	desc = "It's a mist cloak. When someone grabs it, it somewhat rips it self appart so that thier enemy can't use the cloak to thier advantage."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "mist_cloak"
	worn_icon_state = "mist_cloak"

/obj/item/clothing/neck/linen_tombstone_shroud
	name = "linen tombstone shroud"
	desc = "It's a dark linen cloak with a tombstone symbol on it. It seems covered in strands of blue hair and filth. It also has a pungent stench of cigarette smoke."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "linen_tombstone_shroud"
	worn_icon_state = "linen_tombstone_shroud"

/obj/item/clothing/head/costume/samuraihelmetmask
	name = "samurai helmet"
	desc = "It's an old samuri helmet with a red face mask connected to it."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "samuraihelmetmask"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR

/obj/item/clothing/under/costume/syndicatepajamas
	name = "syndicatepajamas"
	desc = "Black and red Syndicate branded pajamas. They smell of gunpowder."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "syndicatepajamas"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/suit/flleeppyy_dreamers
	name = "dreamers trenchcoat"
	desc = "A vibrant garment woven from the threads of (REDACTED). They say when you put it on, you can see 15 milliseconds into the future, but that's just a rumor."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "dreamers"
	body_parts_covered = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	inhand_icon_state = null

/obj/item/clothing/suit/flleeppyy_lesbian
	name = "lesbian trenchcoat"
	desc = "Found in a long bacon store, this coat strangely makes you thinks of girls. It smells of flowers."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "lesbian"
	body_parts_covered = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	inhand_icon_state = null

/obj/item/clothing/under/costume/donatorgrayscaleturtleneck
	name = "turtleneck with pants"
	desc = "A turtleneck with a pair of pants, this one is easily dyeable."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "donatorgrayscaleturtleneck"
	can_adjust = FALSE
	inhand_icon_state = null
	greyscale_colors = "#8cd4a2#404577"
	greyscale_config = /datum/greyscale_config/donatorgrayscaleturtleneck
	greyscale_config_worn = /datum/greyscale_config/donatorgrayscaleturtleneckworn
	flags_1 = IS_PLAYER_COLORABLE_1
/datum/greyscale_config/donatorgrayscaleturtleneck
	name = "turtleneck with pants"
	icon_file = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	json_config = 'monkestation/code/modules/donator/code/greyscale/turtleneck.json'
	expected_colors = 2
/datum/greyscale_config/donatorgrayscaleturtleneckworn
	name = "turtleneck with pants"
	icon_file = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	json_config = 'monkestation/code/modules/donator/code/greyscale/turtleneck.json'
	expected_colors = 2

/obj/item/clothing/neck/donatorwhitefurshawl
	name = "white fur shawl"
	desc = "A wonderful fur shaw that is colored white. You typically wear it with a dress on the shoulders."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "whitefurshawl"
	worn_icon_state = "whitefurshawl"

/obj/item/clothing/suit/toggle/labcoat/elchorico_big_labcoat
	name = "huge labcoat"
	desc = "A suit that protects against minor chemical spills. This one is HUGE and has a purple stripe!"
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "elchorico_big_labcoat"

/obj/item/clothing/suit/jacket/formal_overcoat
	name = "Formal Overcoat"
	desc = "A snazzy black suit jacket with 6 shiny gold buttons."
	icon = 'monkestation/code/modules/donator/icons/obj/clothing.dmi'
	worn_icon = 'monkestation/code/modules/donator/icons/mob/clothing.dmi'
	icon_state = "formal_overcoat"
	worn_icon_state = "formal_overcoat"
