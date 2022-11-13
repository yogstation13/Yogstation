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

const speciesmap = {
  "IPC": {
    "icon": "tv",
    "color": "#2e46cc",
  },
  "Robot": {
    "icon": "robot",
    "color": "#edee1b",
  },
  "Android": {
    "icon": "cog",
    "color": "#06b4cf",
  },
  "Felinid": {
    "icon": "paw",
    "color": "#f52ab4",
  },
  "Moth": {
    "icon": "feather-alt",
    "color": "#ffebb8",
  },
  "Lizard": {
    "icon": "dragon",
    "color": "#8bf76a",
  },
  "Polysmorph": {
    "icon": "certificate",
    "color": "#802496",
  },
  "Podperson": {
    "icon": "seedling",
    "color": "#07f58a",
  },
  "Plasmaman": {
    "icon": "skull",
    "color": "#d60b66",
  },
  "Ethereal": {
    "icon": "sun",
    "color": "#f0ff66",
  },
  "Skeleton": {
    "icon": "skull",
    "color": "#fffcfa",
  },
  "Slime": {
    "icon": "cloud",
    "color": "#f2505d",
  },
  "Fly": {
    "icon": "bug",
    "color": "#039162",
  },
  "Human": {
    "icon": "user",
    "color": "#2ee81a",
  },
  "Zombie": {
    "icon": "skull",
    "color": "#186310",
  },
  "Snail": {
    "icon": "strikethrough",
    "color": "#08ccb8",
  },
  "Alien": {
    "icon": "question-circle",
    "color": "#d40db9",
  },
};

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
              <Table.Cell bold collapsing textAlign="center">
                Warnings
              </Table.Cell>
              <Table.Cell bold collapsing textAlign="center">
                Species
              </Table.Cell>
              <Table.Cell bold collapsing textAlign="center">
                Status
              </Table.Cell>
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
                    sensor.no_warnings ? (
                      <Box>
                        {sensor.is_irradiated ? <Icon name="radiation" color="#f0e21d" size={1} /> : ""}
                        {sensor.is_husked ? <Icon name="ribbon" color="#ad1c09" size={1} /> : ""}
                        {sensor.is_onfire ? <Icon name="fire" color="#f24f0f" size={1} /> : ""}
                        {sensor.is_wounded ? <Icon name="star-of-life" color="#d412ff" size={1} /> : ""}
                        {sensor.is_bonecrack ? <Icon name="bone" color="#f50505" size={1} /> : ""}
                        {sensor.is_disabled ? <Icon name="crutch" color="#fafcfb" size={1} /> : ""}
                      </Box>
                    ) : (
                      <Icon name="check" color="#10d820" size={1} />)
                  ) : (
                    <Icon name="question" color="#f70505" size={1} />
                  )}
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  {speciesmap[sensor.species] ? <Icon name={speciesmap[sensor.species].icon} color={speciesmap[sensor.species].color} size={1} /> : <Icon name="question" color="#f70505" size={1} />}
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
