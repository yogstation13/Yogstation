import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Chart, Flex, ProgressBar, Section, Tabs, Slider } from '../components';
import { FlexItem } from '../components/Flex';

export const RbmkComputer = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, "tab-index", 1);
  return (
    <Window
      resizable
      width={350}
      height={500}>
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}>
            Status
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 2}
            onClick={() => setTabIndex(2)}>
            Control Rods
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 3}
            onClick={() => setTabIndex(3)}>
            Fuel Rods
          </Tabs.Tab>
        </Tabs>
        {tabIndex === 1 && <RbmkStatsSection />}
        {tabIndex === 2 && <RbmkControlRodControl />}
        {tabIndex === 3 && <RbmkFuelControl />}
      </Window.Content>
    </Window>
  );
};

export const RbmkStatsSection = (props, context) => {
  const { act, data } = useBackend(context);
  const powerData = data.powerData.map((value, i) => [i, value]);
  const psiData = data.psiData.map((value, i) => [i, value]);
  const tempInputData = data.tempInputData.map((value, i) => [i, value]);
  const tempOutputdata = data.tempOutputdata.map((value, i) => [i, value]);
  return (
    <Box height="100%">
      <Section title="Legend:">
        Reactor Power (%):
        <ProgressBar
          value={data.power}
          minValue={0}
          maxValue={100}
          color="yellow" />
        <br />
        Reactor Pressure (PSI):
        <ProgressBar
          value={data.psi}
          minValue={0}
          maxValue={2000}
          color="white" >
          {data.psi} PSI
        </ProgressBar>
        Coolant temperature (°C):
        <ProgressBar
          value={data.coolantInput}
          minValue={-273.15}
          maxValue={1227}
          color="blue">
          {data.coolantInput} °C
        </ProgressBar>
        Outlet temperature (°C):
        <ProgressBar
          value={data.coolantOutput}
          minValue={-273.15}
          maxValue={1227}
          color="bad">
          {data.coolantOutput} °C
        </ProgressBar>
      </Section>
      <Section fill title="Reactor Statistics:" height="200px">
        <Chart.Line
          fillPositionedParent
          data={powerData}
          rangeX={[0, powerData.length - 1]}
          rangeY={[0, 1500]}
          strokeColor="rgba(255, 215,0, 1)"
          fillColor="rgba(255, 215, 0, 0.1)" />
        <Chart.Line
          fillPositionedParent
          data={psiData}
          rangeX={[0, psiData.length - 1]}
          rangeY={[0, 1500]}
          strokeColor="rgba(255,250,250, 1)"
          fillColor="rgba(255,250,250, 0.1)" />
        <Chart.Line
          fillPositionedParent
          data={tempInputData}
          rangeX={[0, tempInputData.length - 1]}
          rangeY={[-273.15, 1227]}
          strokeColor="rgba(127, 179, 255 , 1)"
          fillColor="rgba(127, 179, 255 , 0.1)" />
        <Chart.Line
          fillPositionedParent
          data={tempOutputdata}
          rangeX={[0, tempOutputdata.length - 1]}
          rangeY={[-273.15, 1227]}
          strokeColor="rgba(255, 0, 0 , 1)"
          fillColor="rgba(255, 0, 0 , 0.1)" />
      </Section>
    </Box>
  );
};

export const RbmkControlRodControl = (props, context) => {
  const { act, data } = useBackend(context);
  const control_rods = data.control_rods;
  const k = data.k;
  const desiredK = data.desiredK;
  return (
    <Section title="Control Rod Management:" height="100%">
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
      <Slider
        value={Math.round(desiredK*10)/10}
        fillValue={Math.round(k*10)/10}
        minValue={0}
        maxValue={3}
        step={0.1}
        stepPixelSize={5}
        onDrag={(e, value) => act('input', {
          target: value,
        })} />
    </Section>
  );
};

export const RbmkFuelControl = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title="Fuel Rod Management" height="100%">
      {data.rods.length ? (
        <Box>
          <Flex direction="column">
            {Object.keys(data.rods).map(rod => (
              <FlexItem key={rod}>
                <Box inline mr={"3rem"} my={"0.5rem"}>
                  {data.rods[rod].name}
                </Box>
                <Button
                  inline
                  icon={'times'}
                  content={'Eject'}
                  disabled={data.power >= 20}
                  onClick={() => act('eject', {
                    rodRef: rod,
                  })} />
                <ProgressBar
                  value={100-data.rods[rod].depletion}
                  minValue={0}
                  maxValue={100}
                />
              </FlexItem>
            ))}
          </Flex>
        </Box>
      ) : (
        <Box fontSize={3}>
          No Rods Found
        </Box>
      )}
    </Section>
  );
};
