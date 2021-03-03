import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, Section, NumberInput, Icon } from '../components';
import { formatSiUnit } from '../format';
import { NtosWindow } from '../layouts';

export const NtosEnergyHarvesterController = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    status,
    x,
    y,
    area,
    dist,
    rotation,
    power,
    power_setting,
    input,
    power_switch,
    payout,
    last_power,
    last_payout,
  } = data;
  return (
    <NtosWindow width={300} height={270} resizable>
      <NtosWindow.Content scrollable>
        <Section title="Input">
          <LabeledList>
            <LabeledList.Item
              label="Input Energy"
              buttons={
                <Button
                  color={power_switch ? 'green' : 'default'}
                  icon={power_switch ? 'power-off' : 'times'}
                  onClick={() => act('switch')}>
                  {power_switch ? 'On' : 'Off'}
                </Button>
              }>
              <Box color="lightgreen">
                {formatSiUnit(input, 0, 'W')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Input Limit">
              <Flex inline width="100%">
                <Flex.Item>
                  <Button
                    icon="fast-backward"
                    disabled={power_setting === 0}
                    onClick={() => act('setinput', {
                      target: 'min',
                    })} />
                </Flex.Item>
                <Flex.Item>
                  <NumberInput
                    animate
                    minValue={0}
                    maxValue={1000000000000000}
                    value={power_setting}
                    format={value => formatSiUnit(value, 0, 'W')}
                    width="100px"
                    onChange={(e, value) => act('setinput', {
                      target: value,
                    })}
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    disabled={100 === 1000000000000000}
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
              <Box color={power ? "good":"bad"}>
                {formatSiUnit(power, 0, 'J')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Estimated Income">
              <Box color={payout ? "good":"bad"}>
                {Math.floor(payout)+" cr"}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Last Transmitted">
              <Box color={last_power ? "good":"bad"}>
                {formatSiUnit(last_power, 0, 'J')}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Last Payout">
              <Box color={last_payout ? "good":"bad"}>
                {Math.floor(last_payout)+" cr"}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Location and Status">
          <LabeledList>
            <LabeledList.Item label="Position">
              {area + " (" + x + "," + y + ")"}
            </LabeledList.Item>
            <LabeledList.Item label="Compass">
              <Icon
                mr={1}
                size={1.2}
                name={dist===0 ? "circle" : "arrow-up"}
                rotation={rotation} />
              {dist !== undefined && (
                Math.round(dist) + 'm'
              )}
            </LabeledList.Item>
            <LabeledList.Item
              label="Status"
              color={status==="Working" ? 'green' : 'red'}>
              {status === "null" ? "Energy Harvester not linked to NTNet!" : status}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
