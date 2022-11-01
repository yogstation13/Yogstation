/obj/structure/blob/factory
	name = "factory blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	desc = "A thick spire of tendrils."
	max_integrity = BLOB_FACTORY_MAX_HP
	health_regen = BLOB_FACTORY_HP_REGEN
	point_return = BLOB_REFUND_FACTORY_COST
	resistance_flags = LAVA_PROOF
	var/max_spores = BLOB_FACTORY_MAX_SPORES
	var/list/spores = list()
	var/mob/living/simple_animal/hostile/blob/blobbernaut/naut = null
	COOLDOWN_DECLARE(spore_delay)
	var/spore_cooldown = BLOBMOB_SPORE_SPAWN_COOLDOWN //8 seconds between spores and after spore death

/obj/structure/blob/factory/creation_action()
	if(overmind)
		overmind.factory_blobs += src

/obj/structure/blob/factory/scannerreport()
	if(naut)
		return "It is currently sustaining a blobbernaut, making it fragile and unable to produce blob spores."
	return "Will produce a blob spore every few seconds."

/obj/structure/blob/factory/Destroy()
	for(var/mob/living/simple_animal/hostile/blob/blobspore/spore in spores)
		if(spore.factory == src)
			spore.factory = null
	if(naut)
		naut.factory = null
		to_chat(naut, span_userdanger("Your factory was destroyed! You feel yourself dying!"))
		naut.throw_alert("nofactory", /obj/screen/alert/nofactory)
	spores = null
	if(overmind)
		overmind.factory_blobs -= src
	return ..()

/obj/structure/blob/factory/Be_Pulsed()
	. = ..()
	if(naut)
		return
	if(spores.len >= max_spores)
		return
	if(!COOLDOWN_FINISHED(src, spore_delay))
		return
	COOLDOWN_START(src, spore_delay, spore_cooldown)
	flick("blob_factory_glow", src)
	var/mob/living/simple_animal/hostile/blob/blobspore/BS = new/mob/living/simple_animal/hostile/blob/blobspore(src.loc, src)
	if(overmind) //if we don't have an overmind, we don't need to do anything but make a spore
		BS.overmind = overmind
		BS.update_icons()
		overmind.blob_mobs.Add(BS)
