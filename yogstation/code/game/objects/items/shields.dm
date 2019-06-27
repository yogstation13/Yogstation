/obj/item/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, args)
	if(transparent && (hitby.pass_flags & PASSGLASS))
		return FALSE
	if(!is_A_facing_B(owner, hitby))
		return FALSE
	owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
	return TRUE