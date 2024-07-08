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

#define PSI_IMPLANT_AUTOMATIC  "Security Level Derived"
#define PSI_IMPLANT_SHOCK      "Issue Neural Shock"
#define PSI_IMPLANT_WARN       "Issue Reprimand"
#define PSI_IMPLANT_LOG        "Log Incident"
#define PSI_IMPLANT_DISABLED   "Disabled"

#define INVOKE_PSI_POWERS(holder, powers, target, return_on_invocation) \
	if(holder?.psi?.can_use()) { \
		for(var/datum/psionic_power/power as anything in powers) { \
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
