import { Feature, FeatureValueProps, StandardizedPalette } from '../../base';

const furPresets = {
  // these need to be short color (3 byte) compatible
  '#cd8765': 'Monkey', // also the define used for monkestation\code\__DEFINES\colors.dm's COLOR_MONKEY_BROWN
  '#ffffff': 'Albino',
  '#ffb089': 'Chimp',
  '#aeafb3': 'Grey',
  '#bfd0ca': 'Snow',
  '#ce7d54': 'Orange',
  '#c47373': 'Red',
  '#f4e2d5': 'Cream',
};

export const fur: Feature<string> = {
  name: 'Fur Color',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(furPresets)}
        displayNames={furPresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        featureId={featureId}
        act={act}
        maxWidth="100%"
        includeHex
      />
    );
  },
};
