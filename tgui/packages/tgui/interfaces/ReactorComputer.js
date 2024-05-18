import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Chart, Flex, ProgressBar, Section, Tabs, Slider, LabeledList, Stack } from '../components';
import { FlexItem } from '../components/Flex';
import { formatSiUnit } from '../format';

export const ReactorComputer = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, "tab-index", 1);
  return (
    <Window
      resizable
      width={400}
      height={588}>
      <Window.Content>
        <ReactorStats />
        <ReactorControl />
        <ReactorHistory />
      </Window.Content>
    </Window>
  );
};

export const ReactorStats = (props, context) => {
  const { act, data } = useBackend(context);
  const { section_buttons } = props;
  return (
    <Section title="Legend:" buttons={section_buttons}>
      <LabeledList>
        <LabeledList.Item label="Integrity">
          <ProgressBar
            value={data.integrity / 100}
            ranges={{
              good: [0.90, Infinity],
              average: [0.5, 0.90],
              bad: [-Infinity, 0.5],
            }}>
            {data.integrity}%
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Reactor Power">
          <ProgressBar
            value={data.power}
            minValue={0}
            maxValue={10000000}
            color="yellow">
            {formatSiUnit(data.power, 0, "W")}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Reactor Pressure">
          <ProgressBar
            value={data.kpa}
            minValue={0}
            maxValue={10000}
            color="white" >
            {formatSiUnit(data.kpa*1000, 1, "Pa")}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Coolant Temperature">
          <ProgressBar
            value={data.coolantInput}
            minValue={0}
            maxValue={1500}
            color="blue">
            {data.coolantInput} K
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Outlet Temperature">
          <ProgressBar
            value={data.coolantOutput}
            minValue={0}
            maxValue={1500}
            color="orange">
            {data.coolantOutput} K
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Core Temperature">
          <ProgressBar
            value={data.coreTemp}
            minValue={0}
            maxValue={1500}
            color="bad">
            {data.coreTemp} K
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Criticality (K)">
          <ProgressBar
            value={data.k / 5}
            ranges={{
              good: [-Infinity, 0.4],
              average: [0.4, 0.6],
              bad: [0.6, Infinity],
            }}>
            {data.k}
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const ReactorHistory = (props, context) => {
  const { act, data } = useBackend(context);
  const powerData = data.powerData.map((value, i) => [i, value]);
  const kpaData = data.kpaData.map((value, i) => [i, value]);
  const tempCoreData = data.tempCoreData.map((value, i) => [i, value]);
  const tempInputData = data.tempInputData.map((value, i) => [i, value]);
  const tempOutputData = data.tempOutputData.map((value, i) => [i, value]);
  return (
    <Section fill title="Reactor Statistics:" height="200px" mt={1}>
      <Chart.Line
        fillPositionedParent
        data={powerData}
        rangeX={[0, powerData.length - 1]}
        rangeY={[0, Math.max(15000000, ...data.powerData)]}
        strokeColor="rgba(255, 215,0, 1)"
        fillColor="rgba(255, 215, 0, 0.1)" />
      <Chart.Line
        fillPositionedParent
        data={kpaData}
        rangeX={[0, kpaData.length - 1]}
        rangeY={[0, Math.max(10000, ...data.kpaData)]}
        strokeColor="rgba(255,250,250, 1)"
        fillColor="rgba(255,250,250, 0.1)" />
      <Chart.Line
        fillPositionedParent
        data={tempCoreData}
        rangeX={[0, tempCoreData.length - 1]}
        rangeY={[0, Math.max(1800, ...data.tempCoreData)]}
        strokeColor="rgba(255, 0, 0 , 1)"
        fillColor="rgba(255, 0, 0 , 0.1)" />
      <Chart.Line
        fillPositionedParent
        data={tempInputData}
        rangeX={[0, tempInputData.length - 1]}
        rangeY={[0, Math.max(1800, ...data.tempInputData)]}
        strokeColor="rgba(127, 179, 255 , 1)"
        fillColor="rgba(127, 179, 255 , 0.1)" />
      <Chart.Line
        fillPositionedParent
        data={tempOutputData}
        rangeX={[0, tempOutputData.length - 1]}
        rangeY={[0, Math.max(1800, ...data.tempOutputData)]}
        strokeColor="rgba(255, 129, 25 , 1)"
        fillColor="rgba(255, 129, 25 , 0.1)" />
    </Section>
  );
};

export const ReactorControl = (props, context) => {
  const { act, data } = useBackend(context);
  const control_rods = data.control_rods;
  const k = data.k;
  const desiredK = data.desiredK;
  const fuel_rods = data.rods.length;
  const shutdown_temp = data.shutdownTemp;
  return (
    <Section title="Controls:">
      <LabeledList>
        <LabeledList.Item label="Reactor Power">
          <Button
            disabled={
              (data.coreTemp > shutdown_temp && data.active) ||
              (fuel_rods <= 0 && !data.active) ||
              k > 0
            }
            icon={data.active ? 'power-off' : 'times'}
            content={data.active ? 'On' : 'Off'}
            selected={data.active}
            onClick={() => act('power')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Control Rod Insertion">
          <ProgressBar
            value={(control_rods / 100 * 100) * 0.01}
            ranges={{
              good: [0.7, Infinity],
              average: [0.4, 0.7],
              bad: [-Infinity, 0.4],
            }} />
        </LabeledList.Item>
        <LabeledList.Item label="Target Criticality">
          <Slider
            value={Math.round(desiredK*10)/10}
            fillValue={Math.round(k*10)/10}
            minValue={0}
            maxValue={5}
            step={0.1}
            stepPixelSize={5}
            onDrag={(e, value) => act('input', {
              target: value,
            })} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const ReactorFuel = (props, context) => {
  const { act, data } = useBackend(context);
  const shutdown_temp = data.shutdownTemp;
  return (
    <Section title="Fuel Rod Management">
      {data.rods.length > 0 ? (
        <Box>
          <Flex direction="column">
            {Object.keys(data.rods).map(rod => (
              <FlexItem key={rod}>
                <Box inline mr={"3rem"} my={"0.5rem"}>
                  {data.rods[rod].rod_index}. {data.rods[rod].name}
                </Box>
                <Button
                  inline
                  icon={'times'}
                  content={'Eject'}
                  disabled={data.coreTemp > shutdown_temp}
                  onClick={() => act('eject', {
                    rod_index: data.rods[rod].rod_index,
                  })} />
                <ProgressBar
                  value={100-data.rods[rod].depletion}
                  minValue={0}
                  maxValue={100}
                  ranges={{
                    good: [75, Infinity],
                    average: [40, 75],
                    bad: [-Infinity, 40],
                  }}
                />
              </FlexItem>
            ))}
          </Flex>
        </Box>
      ) : (
        <Box fontSize={3}>
          No rods found.
        </Box>
      )}
    </Section>
  );
};
