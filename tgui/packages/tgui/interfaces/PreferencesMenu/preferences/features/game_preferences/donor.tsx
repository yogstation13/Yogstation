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
  category: "DONATOR",
  description: "When enabled, you will equip your selected donor hat when playing cyborg.",
  component: CheckboxInput,
};

export const donor_pda: Feature<string> = {
  name: "Donor PDA",
  category: "DONATOR",
  component: FeatureDropdownInput,
};

export const purrbation: FeatureToggle = {
  name: "Purrbation",
  category: "DONATOR",
  description: "When enabled and you are human, will turn you into a felinid.",
  component: CheckboxInput,
};
