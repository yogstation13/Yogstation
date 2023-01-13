import { Feature, FeatureDropdownInput } from "../base";

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
