import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, ProgressBar, Section, Slider } from '../components';
import { formatPower } from '../format';
import { Window } from '../layouts';

export const EnergyHarvester = (props, context) => {
  const { act, data } = useBackend(context);
  const {
  inputEnergy,
	manualPowerSetting,
	accumulatedPower,
	projectedIncome,
	lastPayout,
	lastAccumulatedPower
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>

      </Window.Content>
    </Window>
  )
}
