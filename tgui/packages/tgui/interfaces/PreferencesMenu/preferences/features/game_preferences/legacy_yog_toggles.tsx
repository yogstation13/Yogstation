import { FeatureToggle, CheckboxInput, FeatureValueProps } from "../base";
import { BooleanLike } from "common/react";
import { useBackend } from "../../../../../backend";
import { PreferencesMenuData } from "../../../data";

export const quiet_mode: FeatureToggle = {
  name: "Quiet mode",
  category: "DONATOR",
  description: "You cannot be chosen as an antagonist or antagonist target.",
  component: (
    props: FeatureValueProps<BooleanLike, boolean>,
    context,
  ) => {
    const { data } = useBackend<PreferencesMenuData>(context);

    return (<CheckboxInput
      {...props}
      disabled={(data.content_unlocked & 2) === 0}
    />);
  },
};

export const pref_mood: FeatureToggle = {
  name: "Enable mood",
  category: "GAMEPLAY",
  description: "Enable the mood system.",
  component: CheckboxInput,
};
