import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Section, ProgressBar, LabeledList, NumberInput } from '../components';

export const RbmkControlRods = props => {
  const { state } = props;
  const { act, data } = useBackend(props);
  const control_rods = data.control_rods;
  const k = data.k;
  const desiredK = data.desiredK;
  return (
    <Section title="Control Rod Management:">
      Control Rod Insertion:
      <ProgressBar
        value={(control_rods / 100 * 100) * 0.01}
        ranges={{
          good: [0.7, Infinity],
          average: [0.4, 0.7],
          bad: [-Infinity, 0.4],
        }} />
      <br />
      Neutrons per generation (K):
      <br />
      <ProgressBar
        value={(k / 3 * 100) * 0.01}
        ranges={{
          good: [-Infinity, 0.4],
          average: [0.4, 0.6],
          bad: [0.6, Infinity],
        }}>
        {k}
      </ProgressBar>
      <br />
      Target criticality:
      <br />
      <LabeledList>
        <LabeledList.Item label="Target">
          <NumberInput
            animated
            value={desiredK}
            unit="k"
            width="125px"
            minValue={0}
            maxValue={3}
            step={0.1}
            onChange={(e, value) => act('input', {
              target: value,
            })} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
