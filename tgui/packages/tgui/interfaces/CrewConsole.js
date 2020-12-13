import { useBackend } from '../backend';
import { Box, Button, ColorBox, Section, Table, Flex } from '../components';
import { COLORS } from '../constants';
import { Window } from '../layouts';

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#2ecc71',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#ed2814',
];

const jobIsHead = jobId => jobId % 10 === 0;

const jobToColor = jobId => {
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
  if (jobId >= 200 && jobId < 230) {
    return COLORS.department.centcom;
  }
  return COLORS.department.other;
};

const healthToColor = (oxy, tox, burn, brute) => {
  const healthSum = oxy + tox + burn + brute;
  const level = Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  return HEALTH_COLOR_BY_LEVEL[level];
};

const HealthStat = props => {
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
  const { act, data } = useBackend(context);
  const sensors = data.sensors || [];

  return (
    <Window
      title="Crew Monitor"
      width={1400}
      height={800}
      resizable>
      <Window.Content scrollable>
        <Flex>
          <Flex.Item>
            <Section>
              {data.z === 2 && (
                <div className="map">
                  {data["sensors"].map(sensor => (
                    sensor.pos_x && (
                      <div className="blip" style={
                        `left:${
                          (sensor.pos_x-data.minx)*(600/(data.maxx-data.minx))}px;
                    top:${
                      (data.maxy-sensor.pos_y)*(600/(data.maxx-data.minx))}px`
                      } />
                    )
                  ))}
                  <img src={data.map_filename} width="600px"
                    style={`-ms-interpolation-mode: nearest-neighbor`} />
                </div>
              )}
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section minHeight={90}>
              <Table>
                <Table.Row>
                  <Table.Cell bold>
                    Name
                  </Table.Cell>
                  <Table.Cell bold collapsing />
                  <Table.Cell bold collapsing textAlign="center">
                    Vitals
                  </Table.Cell>
                  <Table.Cell bold>
                    Position
                  </Table.Cell>
                  {!!data.link_allowed && (
                    <Table.Cell bold collapsing>
                      Tracking
                    </Table.Cell>
                  )}
                </Table.Row>
                {sensors.map(sensor => (
                  <Table.Row key={sensor.name}>
                    <Table.Cell
                      bold={jobIsHead(sensor.ijob)}
                      color={jobToColor(sensor.ijob)}>
                      {sensor.name} ({sensor.assignment})
                    </Table.Cell>
                    <Table.Cell collapsing textAlign="center">
                      <ColorBox
                        color={sensor.oxydam !== null
                          ? healthToColor(
                            sensor.oxydam,
                            sensor.toxdam,
                            sensor.brutedam,
                            sensor.brutedam) : (
                            sensor.life_status
                              ? HEALTH_COLOR_BY_LEVEL[0]
                              : HEALTH_COLOR_BY_LEVEL[5])} />
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
                      {sensor.pos_x !== null ? sensor.area : 'N/A'}
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
      </Window.Content>
    </Window>

  );
};
