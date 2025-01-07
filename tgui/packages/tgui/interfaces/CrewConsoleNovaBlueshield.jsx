// THIS IS A NOVA SECTOR UI FILE
import { sortBy } from 'common/collections';

import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Table } from '../components';
import { COLORS } from '../constants';
import { Window } from '../layouts';
import { jobIsHead, jobToColor } from './CrewConsoleNova';

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#c4cf2d',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#801308',
];
const HEALTH_ICON_BY_LEVEL = [
  'heart',
  'heart',
  'heart',
  'heart',
  'heartbeat',
  'skull',
];

const healthToAttribute = (oxy, tox, burn, brute, attributeList) => {
  const healthSum = oxy + tox + burn + brute;
  const level = Math.min(Math.max(Math.ceil(healthSum / 50), 0), 5);
  // 200 Default Health, Sum Divided by 50, 6 Health States
  return attributeList[level];
};

const HealthStat = (props) => {
  const { type, value } = props;
  return (
    <Box inline width={2} color={COLORS.damageType[type]} textAlign="center">
      {value}
    </Box>
  );
};

// all of this just to change the name
export const CrewConsoleNovaBlueshield = () => {
  return (
    <Window title="Blueshield Monitor" width={600} height={300}>
      <Window.Content scrollable>
        <Section minHeight="540px">
          <CrewTable />
        </Section>
      </Window.Content>
    </Window>
  );
};

const CrewTable = (props) => {
  const { act, data } = useBackend();
  const sensors = sortBy((s) => s.ijob)(data.sensors ?? []);
  return (
    <Table cellpadding="3">
      <Table.Row>
        <Table.Cell bold colspan="2">
          Name
        </Table.Cell>
        <Table.Cell bold collapsing textAlign="center">
          Status
        </Table.Cell>
        <Table.Cell bold collapsing textAlign="center">
          Vitals
        </Table.Cell>
        <Table.Cell bold width="180px" collapsing textAlign="center">
          Position
        </Table.Cell>
      </Table.Row>
      {sensors.map((sensor) => (
        <CrewTableEntry sensor_data={sensor} key={sensor.ref} />
      ))}
    </Table>
  );
};

const CrewTableEntry = (props) => {
  const { act, data } = useBackend();
  const { link_allowed } = data;
  const { sensor_data } = props;
  const {
    name,
    assignment,
    ijob,
    is_robot,
    life_status,
    oxydam,
    toxdam,
    burndam,
    brutedam,
    area,
    can_track,
  } = sensor_data;

  return (
    <Table.Row>
      <Table.Cell bold={jobIsHead(ijob)} color={jobToColor(ijob)}>
        {name}
        {assignment !== undefined ? ` (${assignment})` : ''}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {is_robot ? <Icon name="wrench" color="#B7410E" size={1} /> : ''}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined && life_status ? (
          <Icon
            name={healthToAttribute(
              oxydam,
              toxdam,
              burndam,
              brutedam,
              HEALTH_ICON_BY_LEVEL,
            )}
            color={healthToAttribute(
              oxydam,
              toxdam,
              burndam,
              brutedam,
              HEALTH_COLOR_BY_LEVEL,
            )}
            size={1}
          />
        ) : life_status ? (
          <Icon name="heart" color="#17d568" size={1} />
        ) : (
          <Icon name="skull" color="#801308" size={1} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Box inline>
            <HealthStat type="oxy" value={oxydam} />
            {'/'}
            <HealthStat type="toxin" value={toxdam} />
            {'/'}
            <HealthStat type="burn" value={burndam} />
            {'/'}
            <HealthStat type="brute" value={brutedam} />
          </Box>
        ) : life_status ? (
          'Alive'
        ) : (
          'Dead'
        )}
      </Table.Cell>
      <Table.Cell>
        {area !== undefined ? (
          area
        ) : (
          <Icon name="question" color="#ffffff" size={1} />
        )}
      </Table.Cell>
      {!!link_allowed && (
        <Table.Cell collapsing>
          <Button
            content="Track"
            disabled={!can_track}
            onClick={() =>
              act('select_person', {
                name: name,
              })
            }
          />
        </Table.Cell>
      )}
    </Table.Row>
  );
};
