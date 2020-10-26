/// Signifies that this proc is used to handle signals.
/// Every proc you pass to RegisterSignal must have this.
#define SIGNAL_HANDLER SHOULD_NOT_SLEEP(TRUE)

/// Signifies that this proc is used to handle signals, but also sleeps.
/// Do not use this for new work.
#define SIGNAL_HANDLER_DOES_SLEEP

/// A wrapper for _AddElement that allows us to pretend we're using normal named arguments
#define AddElement(arguments...) _AddElement(list(##arguments))
/// A wrapper for _RemoveElement that allows us to pretend we're using normal named arguments
#define RemoveElement(arguments...) _RemoveElement(list(##arguments))

/// A wrapper for __AddComponent that allows us to pretend we're using normal named arguments
#define AddComponent(arguments...) __AddComponent(list(##arguments))
