import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, Chart, LabeledList, ProgressBar, Section, Stack, Table } from '../components';
import { NtosWindow } from '../layouts';

const logScale = value => Math.log2(16 + Math.max(0, value)) - 4;

export const NtosSupermatterMonitor = (props, context) => {
  return (
    <NtosWindow
      width={600}
      height={500}
      resizable>
      <NtosWindow.Content scrollable>
        <NtosSupermatterMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosSupermatterMonitorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    SM_integrity,
    SM_power,
    SM_radiation,
    SM_ambienttemp,
    SM_ambientpressure,
    SM_moles,
  } = data;
  if (!active) {
    return (
      <SupermatterList />
    );
  }
  const gases = flow([
    gases => gases.filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(data.gases || []);
  const gasMaxAmount = Math.max(1, ...gases.map(gas => gas.amount));
  return (
    <>
      <Stack>
        <Stack.Item width="270px">
          <Section title="Metrics">
            <LabeledList>
              <LabeledList.Item label="Integrity">
                <ProgressBar
                  value={SM_integrity / 100}
                  ranges={{
                    good: [0.90, Infinity],
                    average: [0.5, 0.90],
                    bad: [-Infinity, 0.5],
                  }} />
              </LabeledList.Item>
              <LabeledList.Item label="Relative EER" labelColor="yellow">
                <ProgressBar
                  value={SM_power}
                  minValue={0}
                  maxValue={5000}
                  ranges={{
                    good: [-Infinity, 5000],
                    average: [5000, 7000],
                    bad: [7000, Infinity],
                  }}>
                  {toFixed(SM_power) + ' MeV/cm3'}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Radiation" labelColor="green">
                <ProgressBar
                  value={SM_radiation}
                  minValue={0}
                  maxValue={7000}
                  ranges={{
                    // The threshold where enough radiation gets to the
                    // collectors to start generating power. Experimentally
                    // determined, because radiation waves are inscrutable.
                    grey: [-Infinity, 320],
                    good: [320, 5000],
                    average: [5000, 7000],
                    bad: [7000, Infinity],
                  }}>
                  {toFixed(SM_radiation) + ' Sv/h'}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Temperature" labelColor="red">
                <ProgressBar
                  value={logScale(SM_ambienttemp)}
                  minValue={0}
                  maxValue={logScale(10000)}
                  ranges={{
                    teal: [-Infinity, logScale(80)],
                    good: [logScale(80), logScale(373)],
                    average: [logScale(373), logScale(1000)],
                    bad: [logScale(1000), Infinity],
                  }}>
                  {toFixed(SM_ambienttemp) + ' K'}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Pressure" labelColor="white">
                <ProgressBar
                  value={logScale(SM_ambientpressure)}
                  minValue={0}
                  maxValue={logScale(50000)}
                  ranges={{
                    good: [logScale(1), logScale(300)],
                    average: [-Infinity, logScale(1000)],
                    bad: [logScale(1000), +Infinity],
                  }}>
                  {toFixed(SM_ambientpressure) + ' kPa'}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Total Moles" labelColor="purple">
                <ProgressBar
                  value={logScale(SM_moles)}
                  minValue={0}
                  maxValue={logScale(50000)}
                  ranges={{
                    good: [-Infinity, logScale(1800 * 0.75)],
                    average: [
                      logScale(1800 * 0.75),
                      logScale(1800),
                    ],
                    bad: [logScale(1800), Infinity],
                  }}>
                  {toFixed(SM_moles) + ' moles'}
                </ProgressBar>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
        <Stack.Item grow={1} basis={0}>
          <Section
            title="Gases"
            buttons={(
              <Button
                icon="arrow-left"
                content="Back"
                onClick={() => act('PRG_clear')} />
            )}>
            <LabeledList>
              {gases.map((gas, index) => (
                <LabeledList.Item
                  key={index}
                  label={gas.name}>
                  <ProgressBar
                    value={gas.amount}
                    color={gas.ui_color}
                    minValue={0}
                    maxValue={gasMaxAmount}>
                    {toFixed(gas.amount, 2) + '%'}
                  </ProgressBar>
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
      <StatsHistory />
    </>
  );
};

export const StatsHistory = (props, context) => {
  const { act, data } = useBackend(context);
  const powerData = data.powerData.map((value, i) => [i, value]);
  const radsData = data.radsData.map((value, i) => [i, value]);
  const tempData = data.tempData.map((value, i) => [i, value]);
  const kpaData = data.kpaData.map((value, i) => [i, value]);
  const molesData = data.molesData.map((value, i) => [i, value]);
  return (
    <Section fill title="History:" height="200px" mt={1}>
      <Chart.Line
        fillPositionedParent
        data={powerData}
        rangeX={[0, powerData.length - 1]}
        rangeY={[0, Math.max(10000, ...data.powerData)]}
        strokeColor="rgba(255, 215, 0, 1)"
        fillColor="rgba(255, 215, 0, 0.1)" />
      <Chart.Line
        fillPositionedParent
        data={radsData}
        rangeX={[0, radsData.length - 1]}
        rangeY={[0, Math.max(10000, ...data.radsData)]}
        strokeColor="rgba(0, 255, 0 , 1)"
        fillColor="rgba(0, 255, 0 , 0.1)" />
      <Chart.Line
        fillPositionedParent
        data={tempData}
        rangeX={[0, tempData.length - 1]}
        rangeY={[0, Math.max(10000, ...data.tempData)]}
        strokeColor="rgba(255, 0, 0 , 1)"
        fillColor="rgba(255, 0, 0 , 0.1)" />
      <Chart.Line
        fillPositionedParent
        data={kpaData}
        rangeX={[0, kpaData.length - 1]}
        rangeY={[0, Math.max(5000, ...data.kpaData)]}
        strokeColor="rgba(255, 255, 255 , 1)"
        fillColor="rgba(255, 255, 255 , 0.1)" />
      <Chart.Line
        fillPositionedParent
        data={molesData}
        rangeX={[0, molesData.length - 1]}
        rangeY={[0, Math.max(2500, ...data.molesData)]}
        strokeColor="rgba(255, 0, 255 , 1)"
        fillColor="rgba(255, 0, 255 , 0.1)" />
    </Section>
  );
};

const SupermatterList = (props, context) => {
  const { act, data } = useBackend(context);
  const { supermatters = [] } = data;
  return (
    <Section
      title="Detected Supermatters"
      buttons={(
        <Button
          icon="sync"
          content="Refresh"
          onClick={() => act('PRG_refresh')} />
      )}>
      <Table>
        {supermatters.map(sm => (
          <Table.Row key={sm.uid}>
            <Table.Cell>
              {sm.uid + '. ' + sm.area_name}
            </Table.Cell>
            <Table.Cell collapsing color="label">
              Integrity:
            </Table.Cell>
            <Table.Cell collapsing width="120px">
              <ProgressBar
                value={sm.integrity / 100}
                ranges={{
                  good: [0.90, Infinity],
                  average: [0.5, 0.90],
                  bad: [-Infinity, 0.5],
                }} />
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                content="Details"
                onClick={() => act('PRG_set', {
                  target: sm.uid,
                })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
