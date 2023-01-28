import { CheckboxInput, FeatureToggle } from "../base";

export const show_credits: FeatureToggle = {
  name: "Show credits",
  category: "GAMEPLAY",
  description: "Display the credits at the end of the round.",
  component: CheckboxInput,
};
