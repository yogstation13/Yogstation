import { CheckboxInputInverse, FeatureToggle } from "../base";

export const spawn_flare: FeatureToggle = {
  name: "Spawn with flare",
  category: "GAMEPLAY",
  description: "If enabled, you will spawn with a flare in your backpack.",
  component: CheckboxInputInverse,
};

export const spawn_map: FeatureToggle = {
  name: "Spawn with map",
  category: "GAMEPLAY",
  description: "If enabled, you will spawn with a map in your backpack.",
  component: CheckboxInputInverse,
};
