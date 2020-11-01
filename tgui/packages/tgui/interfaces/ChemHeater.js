import { round, toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

export const ChemHeater = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    targetTemp,
    isActive,
    isBeakerLoaded,
    currentTemp,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents = [],
  } = data;
  return (
    <Window
      width={275}
      height={320}
      resizable>
      <Window.Content scrollable>
        <Section
          title="Thermostat"
          buttons={(
            <Button
              icon={isActive ? 'power-off' : 'times'}
              selected={isActive}
              content={isActive ? 'On' : 'Off'}
              onClick={() => act('power')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Heating">
              {data.coilheating}K
            </LabeledList.Item>
            <LabeledList.Item label="Coil Power">
              {data.coil}x
            </LabeledList.Item>
            <LabeledList.Item label="Adjust coil">
              <Button
                icon="minus"
                onClick={() => act('lower_coil')}>
                1
              </Button>
              <Button
                icon="plus"
                onClick={() => act('higher_coil')}>
                1
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Reading">
              <Box
                width="60px"
                textAlign="left">
                {isBeakerLoaded && (
                  <AnimatedNumber
                    value={currentTemp}
                    format={value => toFixed(value) + ' K'} />
                ) || '—'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Beaker"
          buttons={!!isBeakerLoaded && (
            <Fragment>
              <Box inline color="label" mr={2}>
                {beakerCurrentVolume} / {beakerMaxVolume} units
              </Box>
              <Button
                icon="eject"
                content="Eject"
                onClick={() => act('eject')} />
            </Fragment>
          )}>
          <BeakerContents
            beakerLoaded={isBeakerLoaded}
            beakerContents={beakerContents} />
        </Section>
      </Window.Content>
    </Window>
  );
};
