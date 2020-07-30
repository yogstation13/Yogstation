import { map } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed, clamp } from 'common/math';
import { vecLength, vecSubtract } from 'common/vector';
import { useBackend } from '../backend';
import { Button, Icon, Flex, LabeledList, ProgressBar, Section, Table } from '../components';
import { NtosWindow, Box } from '../layouts';

const getColor = (distance, stage) => {
  let dangerRange = 0;
  if (stage<5) {
    dangerRange = (stage*2) + 2;
  } else {
    dangerRange = 15;
  }
  return (("red" && (distance<dangerRange))
    || ("orange" && (distance>dangerRange && distance < dangerRange*2))
    || ("green" && (distance>dangerRange*3))
  );
};

export const NtosSingularityMonitor = (props, context) => {
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <NtosSingularityMonitorContent />

        <Section title="debug data">
          <ul>
            <li> test</li>

          </ul>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosSingularityMonitorContent = (props, context) => {
  const { act, data } = useBackend(context);
  if (!data.active) {
    return (
      <SingularityList />
    );
  } else {
    return <SingularityWindow />;
  }
};

const SingularityList = (props, context) => {
  const { act, data } = useBackend(context);
  const { singularities = [] } = data;
  return (
    <Section
      title="Detected singularities"
      buttons={(
        <Button
          icon="sync"
          content="Refresh"
          onClick={() => act('PRG_refresh')} />
      )}>
      <Table>
        {singularities.map(sing => (
          <Table.Row key={sing.uid}>
            <Table.Cell color={getColor(sing.distance, sing.size)}>
              {sing.uid + '. In: ' + sing.area + '  '}
              <Icon
                opacity={sing.dist !== undefined && (
                  clamp(
                    1.2 / Math.log(Math.E + sing.dist / 20),
                    0.4, 1)
                )}
                mr={1}
                size={1.2}
                name="arrow-up"
                rotation={sing.degrees} />
              {sing.dist !== undefined && (
                Math.round(sing.dist, 1) + 'm'
              )}
            </Table.Cell>
            <Table.Cell collapsing color="label">
              Energy
            </Table.Cell>
            <Table.Cell collapsing width="120px">
              <ProgressBar
                value={sing.energy/100}
                ranges={{
                  good: [-Infinity, 9.99],
                  average: [100, 19.99],
                  bad: [20.00, Infinity],
                }} />
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                content="Details"
                onClick={() => act('PRG_set', {
                  target: sing.uid,
                })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const SingularityWindow = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    area,
    x,
    y,
    energy,
    size,
  } = data;
  return (
    <Section
      title="Singularity Data"
      buttons={(
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => act('PRG_clear')} />
      )} >
      <p>active: {active}</p>
      <p>area: {area}</p>
      <p>energy: {energy}</p>
      <p>size: {size}</p>
      <p>x: {x} </p>
      <p>y: {y}</p>
    </Section>
  );
};
