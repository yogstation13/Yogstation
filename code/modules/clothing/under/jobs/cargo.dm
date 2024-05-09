/obj/item/clothing/under/rank/cargo
	worn_icon = 'icons/mob/clothing/uniform/cargo.dmi'

/obj/item/clothing/under/rank/cargo/qm
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "lb_suit"
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/cargo/qm/turtleneck
	name = "quartermaster's turtleneck jumpsuit"
	desc = "It's a fashionable turtleneck worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "turtleneck_qm"
	item_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/qm/skirt
	name = "quartermaster's jumpskirt"
	desc = "It's a jumpskirt worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_skirt"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/cargo/qm/skirt/turtleneck
	name = "quartermaster's skirtleneck"
	desc = "It's a stylish skirtleneck worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "skirtleneckQM"
	item_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	mutantrace_variation = DIGITIGRADE_VARIATION
	alt_covers_chest = TRUE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/cargo/tech/turtleneck
	name = "cargo technician's turtleneck jumpsuit"
	desc = "Perfect for pushing crates and looking good while doing it! Shorts not included."
	icon_state = "turtleneck_cargo"
	item_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "cargo technician's jumpskirt"
	desc = "Skiiiiirts! They're comfy and easy to wear!"
	icon_state = "cargo_skirt"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	mutantrace_variation = NONE
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NONE

/obj/item/clothing/under/rank/cargo/tech/skirt/turtleneck
	name = "cargo technician's skirtleneck"
	desc = "Skiiiiirtlenecks! Even comfier and easier to wear!"
	icon_state = "skirtleneck"
	item_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 0, WOUND = 10)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/cargo/miner/lavaland
	desc = "A green uniform for operating in hazardous environments."
	name = "shaft miner's jumpsuit"
	icon_state = "explorer"
	item_state = "explorer"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/rank/cargo/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state = "lb_suit"
	can_adjust = FALSE
	custom_price = 20
	mutantrace_variation = DIGITIGRADE_VARIATION
