import { useBackend } from "../../../../../backend";
import { PreferencesMenuData } from "../../../data";
import { FeatureChoiced, FeatureChoicedServerData, FeatureValueProps, StandardizedDropdown } from "../base";

const SkillcapeDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData> & {
    disabled?: boolean,
}, context) => {
  const serverData = props.serverData;
  if (!serverData) {
    return null;
  }

  const { data } = useBackend<PreferencesMenuData>(context);

  const displayNames = serverData.display_names
    || Object.fromEntries(
      serverData.choices.map(choice => [choice, choice]) // Shouldn't be here, skillcapes provide display names
    );

  return (<StandardizedDropdown
    choices={data.earned_skillcapes}
    disabled={props.disabled}
    displayNames={displayNames}
    onSetValue={props.handleSetValue}
    value={props.value}
  />);
};

export const skillcape_id: FeatureChoiced = {
  name: "Skillcape",
  category: "GAMEPLAY",
  description: "Prove your expertise of a job by wearing a special skillcape, only unlocked after 500 hours of playtime.",
  component: SkillcapeDropdownInput,
};
