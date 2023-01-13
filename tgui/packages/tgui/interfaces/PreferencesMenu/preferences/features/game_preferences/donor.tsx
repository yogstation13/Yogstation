import { CheckboxInput, Feature, FeatureToggle, FeatureDropdownInput } from "../base";

export const donor_hat: Feature<string> = {
  name: "Donor hat",
  category: "DONATOR",
  component: FeatureDropdownInput,
};

export const donor_item: Feature<string> = {
  name: "Donor item",
  category: "DONATOR",
  component: FeatureDropdownInput,
};

export const borg_hat: FeatureToggle = {
  name: "Equip borg hat",
  category: "GAMEPLAY",
  description: "When enabled, you will equip your selected donor hat when playing cyborg.",
  component: CheckboxInput,
};
