import { sortBy } from "../../../../../common/collections";
import { Box, Stack } from "../../../../components";
import { FeatureColorInput, FeatureChoicedServerData, FeatureValueProps, StandardizedDropdown, Feature, FeatureChoiced, FeatureDropdownInput } from "./base";
import { HexValue } from "./character_preferences/skin_tone";
import { SkinToneServerData } from "./character_preferences/skin_tone";
import { sortHexValues } from "./character_preferences/skin_tone";

export const eye_color: Feature<string> = {
  name: "Eye color",
  component: FeatureColorInput,
};

export const facial_hair_color: Feature<string> = {
  name: "Facial hair color",
  component: FeatureColorInput,
};

export const hair_color: Feature<string> = {
  name: "Hair color",
  component: FeatureColorInput,
};

export const feature_gradientstyle: FeatureChoiced = {
  name: "Hair gradient",
  component: FeatureDropdownInput,
};

export const feature_gradientcolor: Feature<string> = {
  name: "Hair gradient color",
  component: FeatureColorInput,
};

export const feature_lizard_legs: FeatureChoiced = {
  name: "Legs",
  component: FeatureDropdownInput,
};

export const feature_lizard_snout: FeatureChoiced = {
  name: "Snout",
  component: FeatureDropdownInput,
};

export const feature_lizard_spines: FeatureChoiced = {
  name: "Spines",
  component: FeatureDropdownInput,
};

export const feature_lizard_tail: FeatureChoiced = {
  name: "Tail",
  component: FeatureDropdownInput,
};

export const feature_mcolor: Feature<string> = {
  name: "Mutant color",
  component: FeatureColorInput,
};

export const feature_mcolor_secondary: Feature<string> = {
  name: "Secondary mutant color",
  component: FeatureColorInput,
};

export const feature_quill_color: Feature<string> = {
  name: "Quill Color",
  component: FeatureColorInput,
};

export const feature_facial_quill_color: Feature<string> = {
  name: "Facial Quill Color",
  component: FeatureColorInput,
};

export const feature_body_markings_color: Feature<string> = {
  name: "Body Markings Color",
  component: FeatureColorInput,
};

export const feature_tail_markings_color: Feature<string> = {
  name: "Tail Markings Color",
  component: FeatureColorInput,
};

export const feature_ipc_screen: FeatureChoiced = {
  name: "Screen",
  component: FeatureDropdownInput,
};

export const feature_ipc_screen_color: Feature<string> = {
  name: "Screen color",
  component: FeatureColorInput,
};

export const feature_ipc_antenna: FeatureChoiced = {
  name: "Antenna",
  component: FeatureDropdownInput,
};

export const feature_ipc_antenna_color: Feature<string> = {
  name: "Antenna color",
  component: FeatureColorInput,
};

export const feature_ipc_chassis: FeatureChoiced = {
  name: "Chassis",
  component: FeatureDropdownInput,
};

export const feature_polysmorph_tail: FeatureChoiced = {
  name: "Tail",
  component: FeatureDropdownInput,
};

export const feature_polysmorph_teeth: FeatureChoiced = {
  name: "Teeth",
  component: FeatureDropdownInput,
};

export const feature_polysmorph_dome: FeatureChoiced = {
  name: "Dome",
  component: FeatureDropdownInput,
};

export const feature_polysmorph_dorsal_tubes: FeatureChoiced = {
  name: "Dorsal tubes",
  component: FeatureDropdownInput,
};

export const feature_pod_hair: FeatureChoiced = {
  name: "Pod hair style",
  component: FeatureDropdownInput,
};

export const feature_pod_hair_color: Feature<string> = {
  name: "Hair color",
  component: FeatureColorInput,
};

export const feature_pod_flower_color: Feature<string> = {
  name: "Flower color",
  component: FeatureColorInput,
};

export const feature_plasmaman_helmet: FeatureChoiced = {
  name: "Helmet style",
  component: FeatureDropdownInput,
};

export const feature_ethereal_mark: FeatureChoiced = {
  name: "Mark",
  component: FeatureDropdownInput,
};

export const feature_preternis_weathering: FeatureChoiced = {
  name: "Weathering",
  component: FeatureDropdownInput,
};

export const feature_preternis_antenna: FeatureChoiced = {
  name: "Antenna",
  component: FeatureDropdownInput,
};

export const feature_preternis_eye: FeatureChoiced = {
  name: "Eye",
  component: FeatureDropdownInput,
};

export const feature_vox_quills: FeatureChoiced = {
  name: 'Quillstyle',
  component: FeatureDropdownInput,
};

export const feature_vox_facial_quills: FeatureChoiced = {
  name: 'Facial Quillstyle',
  component: FeatureDropdownInput,
};

export const feature_vox_tail_markings: FeatureChoiced = {
  name: 'Tail Markings',
  component: FeatureDropdownInput,
};

export const feature_vox_body_markings: FeatureChoiced = {
  name: 'Body Markings',
  component: FeatureDropdownInput,
};

export const feature_vox_skin_tone: Feature<string, string, SkinToneServerData> = {
  name: "Skin Tone",
  component: (props: FeatureValueProps<string, string, SkinToneServerData>) => {
    const {
      handleSetValue,
      serverData,
      value,
    } = props;

    if (!serverData) {
      return null;
    }

    return (
      <StandardizedDropdown
        choices={sortHexValues(Object.entries(serverData.to_hex))
          .map(([key]) => key)}
        displayNames={Object.fromEntries(
          Object.entries(serverData.display_names)
            .map(([key, displayName]) => {
              const hexColor = serverData.to_hex[key];

              return [key, (
                <Stack align="center" fill key={key}>
                  <Stack.Item>
                    <Box style={{
                      background: hexColor.value.startsWith("#")
                        ? hexColor.value
                        : `#${hexColor.value}`,
                      "box-sizing": "content-box",
                      "height": "11px",
                      "width": "11px",
                    }} />
                  </Stack.Item>

                  <Stack.Item grow>
                    {displayName}
                  </Stack.Item>
                </Stack>
              )];
            })
        )}
        onSetValue={handleSetValue}
        value={value}
      />
    );
  },
};

export const feature_vox_underwear: FeatureChoiced = {
  name: 'Underwear',
  component: FeatureDropdownInput,
};

export const feature_vox_socks: FeatureChoiced = {
  name: 'Socks',
  component: FeatureDropdownInput,
};

export const feature_vox_undershirt: FeatureChoiced = {
  name: 'Undershirt',
  component: FeatureDropdownInput,
};
