import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, Section, NumberInput } from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

export const EnergyHarvester = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    inputEnergy,
    manualPowerSetting,
    manualSwitch,
    accumulatedPower,
    projectedIncome,
    lastPayout,
    lastAccumulatedPower,
  } = data;

  return (
    <Window width={300} height={270} resizable>
      <Window.Content scrollable>
        <Section title="Input">
          <LabeledList>
            <LabeledList.Item
              label="Input Energy"
              buttons={
                <Button
                  color={manualSwitch ? 'green' : 'default'}
                  icon={manualSwitch ? 'power-off' : 'times'}
                  onClick={() => act('switch')}>
                  {manualSwitch ? 'On' : 'Off'}
                </Button>
              }>
              <Box color="lightgreen">
                {formatSiUnit(inputEnergy, 0, 'W')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Input Limit">
              <Flex inline width="100%">
                <Flex.Item>
                  <Button
                    icon="fast-backward"
                    disabled={manualPowerSetting === 0}
                    onClick={() => act('setinput', {
                      target: 'min',
                    })} />
                </Flex.Item>
                <Flex.Item>
                  <NumberInput
                    animate
                    minValue={0}
                    maxValue={1000000000000000}
                    value={manualPowerSetting}
                    format={value => formatSiUnit(value, 0, 'W')}
                    width="120px"
                    onChange={(e, value) => act('setinput', {
                      target: value,
                    })}
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    disabled={manualPowerSetting === 1000000000000000}
                    icon="fast-forward"
                    onClick={() => act('setinput', {
                      target: 'max',
                    })} />
                </Flex.Item>
              </Flex>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Metrics">
          <LabeledList>
            <LabeledList.Item label="Power Transmitted">
              <Box color={accumulatedPower ? "good":"bad"}>
                {formatSiUnit(accumulatedPower, 0, 'J')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Estimated Income">
              <Box color={projectedIncome ? "good":"bad"}>
                {Math.floor(projectedIncome)+" cr"}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Last Transmitted">
              <Box color={lastAccumulatedPower ? "good":"bad"}>
                {formatSiUnit(lastAccumulatedPower, 0, 'J')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Last Payout">
              <Box color={lastPayout ? "good":"bad"}>
                {Math.floor(lastPayout)+" cr"}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

