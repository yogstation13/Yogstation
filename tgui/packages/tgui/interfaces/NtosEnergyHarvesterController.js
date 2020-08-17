import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, Section, NumberInput } from '../components';
import { formatSiUnit } from '../format';
import { Window, NtosWindow } from '../layouts';


export const NtosEnergyHarvesterController = (props, context) => {
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <NtosEnergyHarvesterControlWindow />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosEnergyHarvesterControlWindow = (props, context) => {
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
    <Box>
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
              {projectedIncome}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Last Transmitted">
            <Box color={lastAccumulatedPower ? "good":"bad"}>
              {formatSiUnit(lastAccumulatedPower, 0, 'J')}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Last Payout">
            <Box color={lastPayout ? "good":"bad"}>
              {lastPayout}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Box>
  );
};

