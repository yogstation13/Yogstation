import { FeatureToggle, CheckboxInput } from "../base";

export const quiet_mode: FeatureToggle = {
  name: "Quiet mode",
  category: "DONATOR",
  description: "You cannot be chosen as an antagonist or antagonist target.",
  component: CheckboxInput,
};
