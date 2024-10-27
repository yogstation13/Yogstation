import { useBackend } from "../../../../../backend";
import { PreferencesMenuData } from "../../../data";
import { sortStrings } from "common/collections";
import { StandardizedDropdown, capitalizeFirstLetter, FeatureChoiced, FeatureChoicedServerData, FeatureValueProps } from "../base";

const VoiceDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData> & {
    disabled?: boolean,
}, context) => {
  const serverData = props.serverData;
  if (!serverData) {
    return null;
  }

  const { data } = useBackend<PreferencesMenuData>(context);

  const displayNames = serverData.display_names || Object.fromEntries(serverData.choices.map(choice => [choice, capitalizeFirstLetter(choice)]));

  let choices = sortStrings(data.available_voices);

  return (<StandardizedDropdown
    choices={choices}
    disabled={props.disabled}
    displayNames={displayNames}
    onSetValue={props.handleSetValue}
    value={props.value}
  />);
};

  export const voice_type: FeatureChoiced = {
    name: "Voice",
    component: VoiceDropdownInput,
  };
