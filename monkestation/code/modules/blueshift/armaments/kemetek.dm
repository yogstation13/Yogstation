//TODO add organ harvesting suit module
/datum/armament_entry/company_import/kemetek
	category = KEMETEK_NAME
	company_bitflag = CARGO_COMPANY_KEMETEK

/datum/armament_entry/company_import/kemetek/medical_tools
	subcategory = "Medical Tools"

/datum/armament_entry/company_import/kemetek/medical_tools/canopic_box
	item_type = /obj/item/storage/box/canopic_box
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/kemetek/medical_tools/canopic_stocked
	item_type = /obj/item/storage/box/canopic_box/stocked
	cost = PAYCHECK_COMMAND * 7

/datum/armament_entry/company_import/kemetek/medical_tools/sarcophagusroyale
	item_type = /obj/structure/closet/crate/coffin/sarcophagus
	cost = PAYCHECK_COMMAND * 5
