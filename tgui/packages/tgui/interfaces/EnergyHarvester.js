import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, ProgressBar, Section, NumberInput } from '../components';
import { formatPower } from '../format';
import { toFixed } from 'common/math';
import { Window } from '../layouts';
import { log10 } from 'core-js/fn/number';

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
  //bruh just use the format imports
  const getunit = (power) => {
    var order = log10(power);
    switch(order){
      case 0: return "W"
      case 1: return "KW"
      case 2: return "MW"
      case 3: return "GW"
    }

 };

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Input">
          <LabeledList>
          <LabeledList.Item
            label = "Input Energy"
            buttons={
                <Button
                  icon={manualPowerSetting ? 'power-off' : 'times'}
                  selected={manualPowerSetting}
                  onClick={() => act('switch')}>
                  {manualPowerSetting ? 'On' : 'Off'}
                </Button>
            }>
            <Box color='lightgreen'>
              {inputEnergy}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label = "Manual Input">
          <NumberInput
                animate
                minValue={0}
                maxValue={1000000000000000}
                value={manualPowerSetting}
                format={value => toFixed(value, 1)}
                width="160px"
                />
          </LabeledList.Item>
          </LabeledList>


        </Section>
      </Window.Content>
    </Window>
  )
}
