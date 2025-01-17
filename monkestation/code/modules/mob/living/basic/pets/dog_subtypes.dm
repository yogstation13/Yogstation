/mob/living/basic/pet/dog/pug
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held.dmi'

/mob/living/basic/pet/dog/bullterrier
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held_large.dmi'

/mob/living/basic/pet/dog/corgi
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held.dmi'

/mob/living/basic/pet/dog/corgi/puppy
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held.dmi'

/mob/living/basic/pet/dog/corgi/puppy/void
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held.dmi'

/mob/living/basic/pet/dog/corgi/lisa
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held.dmi'

/mob/living/basic/pet/dog/corgi/narsie
	worn_slot_flags = null

/mob/living/basic/pet/dog/corgi/exoticcorgi
	worn_slot_flags = null

/mob/living/basic/pet/dog/australianshepherd
	name = "\improper australian shepherd"
	real_name = "australian shepherd"
	desc = "It's an australian shepherd."
	icon = 'monkestation/icons/mob/pets.dmi'
	icon_state = "australianshepherd"
	icon_living = "australianshepherd"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 1) //theres no generic dog meat type
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held.dmi'
	held_state = "australianshepherd"

/mob/living/basic/pet/dog/australianshepherd/captain
	name = "Captain"
	real_name = "Captain"
	gender = MALE
	desc = "Captain Butthole Nugget on deck!"
	unique_pet = TRUE
