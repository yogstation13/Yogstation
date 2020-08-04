
import { Button, Icon, Flex, LabeledList, ProgressBar, Section, Table, Box, ColorableProgressBar } from '../components';
import { NtosWindow } from '../layouts';
import { clamp } from 'common/math';
import { useBackend } from '../backend';

const getStageColor = stage => {
  let colors = ["yellow", "purple", "pink"];
  switch (stage) {
    default:
      return "blue";
    case 3:
      return "green";
    case 4:
      return "orange";
    case 5:
      return "red";
    case 6:
      return colors[(Math.floor(Math.random() * colors.length))];
  }
};

const getDistColor = (dist, consume, pull) => {
  if (dist>=pull) {
    return computeGradient((dist-pull)/(60-pull), "#f0de18", "#42f563");
    // yellow to green transition
  } else if (dist<=pull && dist>=consume) {
    return computeGradient((dist-consume)/(pull-consume), "#ff0000", "#f0de18");
    // red to yellow transition
  } else {
    return "red";
  }
};

const rgbToHex = (r, g, b) => {
  return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
};

const hexToRGB = hex => {
  return [parseInt(hex.substring(1, 3), 16),
    parseInt(hex.substring(3, 5), 16),
    parseInt(hex.substring(5, 7), 16)];
};

const computeGradient= (value, color1, color2) => {
  value = clamp(value, 0, 1);
  let rgbColor1 = hexToRGB(color1);
  let rgbColor2 = hexToRGB(color2);
  return [rgbToHex(rgbColor1[0] + (Math.round((rgbColor2[0]-rgbColor1[0])*value)),
    Math.round(rgbColor1[1] + ((rgbColor2[1]-rgbColor1[1])*value)),
    Math.round(rgbColor1[2] + ((rgbColor2[2]-rgbColor1[2])*value)))];
};

export const NtosSingularityMonitor = (props, context) => {
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <NtosSingularityMonitorContent />
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
            <Table.Cell>
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
                rotation={sing.degrees}
                color={"#8A2BE2"} />
              {sing.dist !== undefined && (
                Math.round(sing.dist, 1) + 'm'
              )}
            </Table.Cell>
            <Table.Cell collapsing color="label">
              Energy
            </Table.Cell>
            <Table.Cell collapsing width="120px">
              <ProgressBar
                value={sing.energy/2000}
                minvalue={0}
                maxvalue={1}
                ranges={{
                  teal: [-Infinity, 0.1],
                  good: [0.1, 0.495],
                  average: [0.5, 0.995],
                  bad: [1, Infinity],
                }}>
                {sing.energy + " MT"}
              </ProgressBar>
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
  return (
    <Section
      title="Singularity Data"
      buttons={(
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => act('PRG_clear')} />
      )} >
      <LabeledList>
        <LabeledList.Item label="Stage">
          <ProgressBar
            value={data.size}
            minValue={0}
            maxValue={5}
            color={getStageColor(data.size)}>
            {"Stage " + data.size }
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Energy">
          <ProgressBar
            value={data.energy}
            minValue={data.down_threshold}
            maxValue={data.up_threshold}
            ranges={{
              teal: [-Infinity, 0.1],
              good: [0.1, 0.495],
              average: [0.5, 0.995],
              bad: [1, Infinity],
            }}>
            {data.energy + " MT"}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item
          label="Proximity Data">
          <Box color={getDistColor(data.dist, data.consume_range, data.pull_range)}>
            {data.area + " " + Math.round(data.dist, 1) + 'm '}
            <Icon
              mr={1}
              size={1.2}
              name="arrow-up"
              rotation={data.degrees}
              color={getDistColor(data.dist, data.consume_range, data.pull_range)} />
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
