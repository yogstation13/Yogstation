// Invocation Defines
#define SPELL_INVOCATION_NONE		0	// Doesn't have an invocation
#define SPELL_INVOCATION_SAY		1	// Forces the user to say the invocation message
#define SPELL_INVOCATION_WHISPER	2	// Forces the user to whisper the invocation message
#define SPELL_INVOCATION_EMOTE		3	// Forces the user to emote the invocation message
#define SPELL_INVOCATION_MESSAGE	4	// The user creates a visible message, with the invocation being visaible to others and invocation_emote_self being visible to the user

// Charge Type Defines
#define SPELL_CHARGE_TYPE_RECHARGE	0	// Spell needs to recharge between uses
#define SPELL_CHARGE_TYPE_CHARGES	1	// Spell has a set number of uses
#define SPELL_CHARGE_TYPE_HOLDERVAR	2	// Spell adjusts the users 'holder_var_type' by 'holder_var_amount' on use
