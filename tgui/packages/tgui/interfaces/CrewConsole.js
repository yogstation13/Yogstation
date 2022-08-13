import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Table, Flex, Icon } from '../components';
import { COLORS } from '../constants';
import { Window } from '../layouts';

export const HEALTH_COLOR_BY_LEVEL = [
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

export const jobIsHead = jobId => jobId % 10 === 0;

export const jobToColor = jobId => {
  if (jobId === 0) {
    return COLORS.department.captain;
  }
  if (jobId >= 10 && jobId < 20) {
    return COLORS.department.security;
  }
  if (jobId >= 20 && jobId < 30) {
    return COLORS.department.medbay;
  }
  if (jobId >= 30 && jobId < 40) {
    return COLORS.department.science;
  }
  if (jobId >= 40 && jobId < 50) {
    return COLORS.department.engineering;
  }
  if (jobId >= 50 && jobId < 60) {
    return COLORS.department.cargo;
  }
  if (jobId >= 60 && jobId < 80) { // Yogs: Extended this to 80 as we have more than 9 civilian jobs
    return COLORS.department.civilian; // Yogs: Also added a new civilian color
  }
  if (jobId >= 200 && jobId < 230) {
    return COLORS.department.centcom;
  }
  if (jobId === 999) { // Yogs Start: Assistants need the new color too
    return COLORS.department.civilian;
  } // Yogs End
  return COLORS.department.other;
};

export const healthToAttribute = (oxy, tox, burn, brute, is_alive, attributeList) => {
  if (is_alive === null || is_alive)
  {
    if (oxy === null) // No damage data -- just show that they're alive
    {
      return attributeList[0];
    }
    const healthSum = oxy + tox + burn + brute;
    const level = Math.min(Math.max(Math.ceil(healthSum / 31), 0), 5);
    return attributeList[level];
  }
  return attributeList[5]; // Dead is dead, son
};
// Yogs end

export const HealthStat = props => {
  const { type, value } = props;
  return (
    <Box
      inline
      width={4}
      color={COLORS.damageType[type]}
      textAlign="center">
      {value}
    </Box>
  );
};

export const CrewConsole = (props, context) => {
  const [
    originalTitles,
    setoriginalTitles,
  ] = useLocalState(context, 'originalTitles', false);
  const { act, data } = useBackend(context);
  const sensors = data.sensors || [];

  return (
    <Window
      title="Crew Monitor"
      width={1000}
      height={800}
      resizable>
      <Window.Content scrollable>
        <CrewConsoleContent />
      </Window.Content>
    </Window>

  );
};

export const CrewConsoleContent = (props, context) => {
  const [
    originalTitles,
    setoriginalTitles,
  ] = useLocalState(context, 'originalTitles', false);
  const { act, data } = useBackend(context);
  const sensors = data.sensors || [];

  return (
    <Flex>
      <Flex.Item>
        <Section minHeight={90} title="Crew Monitor"
          buttons={(
            <Button.Checkbox checked={originalTitles}
              onClick={() => setoriginalTitles(!originalTitles)}>
              Use Original Job Titles
            </Button.Checkbox>
          )}>
          <Table>
            <Table.Row>
              <Table.Cell bold>
                Name
              </Table.Cell>
              <Table.Cell bold collapsing />
              <Table.Cell bold collapsing textAlign="center">
                Vitals
              </Table.Cell>
              <Table.Cell bold textAlign="center">
                Position
              </Table.Cell>
              {!!data.link_allowed && (
                <Table.Cell bold collapsing textAlign="center">
                  Tracking
                </Table.Cell>
              )}
            </Table.Row>
            {sensors.map(sensor => (
              <Table.Row key={sensor.name}>
                <Table.Cell
                  bold={jobIsHead(sensor.ijob)}
                  color={jobToColor(sensor.ijob)}>
                  {sensor.name}
                  ({!originalTitles ? sensor.assignment_title : sensor.assignment})
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  {sensor.oxydam !== null ? (
                    <Icon
                      name={healthToAttribute( // yogs -- show death when dead
                        sensor.oxydam,
                        sensor.toxdam,
                        sensor.burndam,
                        sensor.brutedam,
                        sensor.life_status,
                        HEALTH_ICON_BY_LEVEL)}
                      color={healthToAttribute(
                        sensor.oxydam,
                        sensor.toxdam,
                        sensor.burndam,
                        sensor.brutedam,
                        sensor.life_status,
                        HEALTH_COLOR_BY_LEVEL)}
                      size={1} />
                  ) : (
                    sensor.life_status ? (
                      <Icon name="heart" color="#17d568" size={1} />
                    ) : (
                      <Icon name="skull" color="#B7410E" size={1} />
                    ))}
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  {sensor.oxydam !== null ? (
                    <Box inline>
                      <HealthStat type="oxy" value={sensor.oxydam} />
                      {'/'}
                      <HealthStat type="toxin" value={sensor.toxdam} />
                      {'/'}
                      <HealthStat type="burn" value={sensor.burndam} />
                      {'/'}
                      <HealthStat type="brute" value={sensor.brutedam} />
                    </Box>
                  ) : (
                    sensor.life_status ? 'Alive' : 'Dead'
                  )}
                </Table.Cell>
                <Table.Cell>
                  {sensor.pos_x !== null ? sensor.area : <Icon name="question" color="#ffffff" size={1} /> }
                </Table.Cell>
                {!!data.link_allowed && (
                  <Table.Cell collapsing>
                    <Button
                      content="Track"
                      disabled={!sensor.can_track}
                      onClick={() => act('select_person', {
                        name: sensor.name,
                      })} />
                  </Table.Cell>
                )}
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Flex.Item>
    </Flex>
  );
};
