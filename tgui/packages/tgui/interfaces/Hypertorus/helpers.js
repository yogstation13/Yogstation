import { Icon, Tooltip } from '../../components';

// Exponential rendering specifically for HFR values.
// Note that we don't want to use unicode exponents as anything over ^3
// is more or less unreadable.
export const to_exponential_if_big = (value) => {
  if (Math.abs(value) > 5000) {
    return value.toExponential(1);
  }
  return Math.round(value);
};

// Simple question mark icon with a hover tooltip
export const HoverHelp = (props) => (
  <Tooltip content={props.content}>
    <Icon name="question-circle" width="12px" mr="6px" />
  </Tooltip>
);

// When no hover help is available, but we want a placeholder for spacing
export const HelpDummy = (props) => <Icon name="" width="12px" mr="6px" />;

// Returns gas color based on gasId
export const getGasColor = (gasId, gases) => {
  if (!gasId) return 'white';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < gases.length; idx++) {
    if (gases[idx].id === gasSearchString) {
      return gases[idx].ui_color;
    }
  }

  return 'white';
};

// Returns gas label based on gasId
export const getGasLabel = (gasId, gases) => {
  if (!gasId) return "";

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < gases.length; idx++) {
    if (gases[idx].id === gasSearchString) {
      return gases[idx].label;
    }
  }

  return gasId;
};
