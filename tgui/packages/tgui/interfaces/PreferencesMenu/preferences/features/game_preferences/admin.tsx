import { CheckboxInput, FeatureColorInput, Feature, FeatureDropdownInput, FeatureToggle } from "../base";

export const asaycolor: Feature<string> = {
  name: "Admin chat color",
  category: "ADMIN",
  description: "The color of your messages in Adminsay. Doesn't work, shout at Jamie.",
  component: FeatureColorInput,
};

export const fast_mc_refresh: FeatureToggle = {
  name: "Enable fast MC stat panel refreshes",
  category: "ADMIN",
  description: "Whether or not the MC tab of the Stat Panel refreshes fast. This is expensive so make sure you need it.",
  component: CheckboxInput,
};
