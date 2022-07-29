#define PSI_COERCION           "coercion"
#define PSI_PSYCHOKINESIS      "psychokinesis"
#define PSI_REDACTION          "redaction"
#define PSI_ENERGISTICS        "energistics"

#define PSI_RANK_BLUNT         0
#define PSI_RANK_LATENT        1
#define PSI_RANK_OPERANT       2
#define PSI_RANK_MASTER        3
#define PSI_RANK_GRANDMASTER   4
#define PSI_RANK_PARAMOUNT     5

#define INVOKE_PSI_POWERS(holder, powers, target, return_on_invocation) \
	if(holder && holder.psi && holder.psi.can_use()) { \
		for(var/thing in powers) { \
			var/datum/psionic_power/power = thing; \
			var/obj/item/result = power.invoke(holder, target); \
			if(result) { \
				power.handle_post_power(holder, target); \
				if(istype(result)) { \
					holder.playsound_local(soundin = 'sound/effects/psi/power_evoke.ogg'); \
					LAZYADD(holder.psi.manifested_items, result); \
					holder.put_in_hands(result); \
				} \
				return return_on_invocation; \
			} \
		} \
	}
