import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Table, Flex, Icon } from '../components';
import { COLORS } from '../constants';
import { Window } from '../layouts';

export const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#c4cf2d',
  '#e89517',
  '#fa301b',
  '#e60505',
  '#e60505',
  '#c71402',
];

const HEALTH_ICON_BY_LEVEL = [
  'heart',
  'heart',
  'heart',
  'heart',
  'heartbeat',
  'heartbeat',
  'skull-crossbones',
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
  // Yogs -- show deadness
  if (is_alive === null || is_alive)
  {
    if (oxy === null) // No damage data -- just show that they're alive
    {
      return attributeList[0];
    }
    const healthSum = oxy + tox + burn + brute;
    const level = Math.min(Math.max(Math.ceil(healthSum / 40), 0), 5);
    return attributeList[level];
  }
  return attributeList[6]; // Dead is dead, son
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
              <Table.Cell bold collapsing />
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
                  {sensor.is_irradiated ? <Icon name="radiation" color="#f0e21d" size={1} /> : ""}
                  {sensor.is_husked ? <Icon name="ribbon" color="#ad1c09" size={1} /> : ""}
                  {sensor.is_onfire ? <Icon name="fire" color="#f24f0f" size={1} /> : ""}
                  {sensor.is_wounded ? <Icon name="star-of-life" color="#f50505" size={1} /> : ""}
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  {sensor.is_robot ? (<Icon name="robot" color="#2e46cc" size={1} />
                  ) : (
                    sensor.is_catperson ? (<Icon name="paw" color="#f52ab4" size={1} />
                    ) : (
                      sensor.is_moth ? (<Icon name="feather-alt" color="#ffebb8" size={1} />
                      ) : (
                        sensor.is_lizard ? (<Icon name="dragon" color="#8bf76a" size={1} />
                        ) : (
                          sensor.is_polysmorph ? (<Icon name="certificate" color="#802496" size={1} />
                          ) : (
                            sensor.is_podperson ? (<Icon name="seedling" color="#05fa46" size={1} />
                            ) : (
                              sensor.is_plasmaman ? (<Icon name="skull" color="#d60b66" size={1} />
                              ) : (
                                sensor.is_ethereal ? (<Icon name="sun" color="#f0ff66" size={1} />
                                ) : (
                                  sensor.is_skeleton ? (<Icon name="skull" color="#fffcfa" size={1} />
                                  ) : (
                                    sensor.is_slime ? (<Icon name="cloud" color="#f2505d" size={1} />
                                    ) : (
                                      sensor.is_fly ? (<Icon name="bug" color="#039162" size={1} />
                                      ) : (
                                        sensor.is_human ? (
                                          <Icon name="user" color="#2ee81a" size={1} />
                                        ) : (
                                          <Icon name="user" color="#f70505" size={1} />
                                        ))))))))))))}
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
                      <Icon name="skull-crossbones" color="#c71402" size={1} />
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
