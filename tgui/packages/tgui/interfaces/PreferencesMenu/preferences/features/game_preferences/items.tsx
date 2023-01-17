import { CheckboxInput, FeatureToggle } from "../base";

export const flare: FeatureToggle = {
  name: "Spawn with flare",
  category: "GAMEPLAY",
  description: "If enabled, you will spawn with a flare in your backpack.",
  component: CheckboxInput,
};

export const map: FeatureToggle = {
  name: "Spawn with map",
  category: "GAMEPLAY",
  description: "If enabled, you will spawn with a map in your backpack.",
  component: CheckboxInput,
};
