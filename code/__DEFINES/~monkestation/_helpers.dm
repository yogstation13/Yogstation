/// Basically, this is UNTIL(Condition),
/// but it also checks to see if Src has been qdeleted, and returns if so.
#define UNTIL_WHILE_EXISTS(Src, Condition) \
	while(!(Condition)) { \
		if(QDELETED(Src)) return; \
		stoplag(); \
	} \
	if(QDELETED(Src)) return;
