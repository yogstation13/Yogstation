import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const SciProbe = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    probestatus,
    foundmobs,
    science,
    calibration,
  } = data;
  return (
    <Section>
      <Section title="Power and Calibration">
        <Button
          icon={probestatus ? 'power-off' : 'times'}
          selected={probestatus}
          content={probestatus ? 'On' : 'Off'}
          onClick={() => act('status')} />
        <Button
          icon={'power-off'}
          content={"Calibrate"}
          onClick={() => act('calibrate')} />
      </Section>
      <Section title="Statistics">
        <ProgressBar
          ranges={{
            good: [0.5, Infinity],
            average: [0.25, 0.5],
            bad: [-Infinity, 0.25],
          }}
          value={calibration} />
        <Box mb={1} />
        <LabeledList>
          <LabeledList.Item label="Detected Megafauna">
            {foundmobs} Megafauna Detected
          </LabeledList.Item>
          <LabeledList.Item label="Science Generation">
            {Math.round(science*calibration)} points per minute
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Section>
  );
};

