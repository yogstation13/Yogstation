import { NtosWindow } from '../layouts';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Collapsible, Box, Section, Tabs, NoticeBox, Flex, ProgressBar, LabeledList, NumberInput, Divider } from '../components';

export const NtosAIBenchmark = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  const [clusterTab, setClusterTab] = useLocalState(context, 'clustertab', 1);


  if (!data.has_ai_net) {
    return (
      <NtosWindow
        width={350}
        height={150}
        resizable>
        <NtosWindow.Content scrollable>
          <Section>
            <NoticeBox>
              No network connection. Please connect to ethernet cable to proceed!
            </NoticeBox>
          </Section>
        </NtosWindow.Content>
      </NtosWindow>
    );
  }

  return (
    <NtosWindow
      width={600}
      height={600}
      resizable>
      <NtosWindow.Content scrollable>
        <Section title="Global Benchmark">
          <LabeledList>
            <LabeledList.Item label="Current CPU">{data.total_cpu} THz</LabeledList.Item>
            <LabeledList.Item label="Current RAM">{data.total_ram} TB</LabeledList.Item>
          </LabeledList>
          <Collapsible title="Processing Records" mt={1}>
            {data.cpu_records.map((record, index) => {
              return (
                <Section title={"During shift #" + record.round_id} key={index}>
                  {record.score} THz
                </Section>
              );
            })}
          </Collapsible>
          <Collapsible title="Memory Records">
            {data.ram_records.map((record, index) => {
              return (
                <Section title={"During shift #" + record.round_id} key={index}>
                  {record.score} TB
                </Section>
              );
            })}
          </Collapsible>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
