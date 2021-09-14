import { Fragment } from 'inferno';
import { useBackend, useSharedState } from '../backend';
import { Box, Button, LabeledList, Slider, ProgressBar, Section, Flex } from '../components';
import { Window } from '../layouts';

export const AiResources = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
      width={500}
      height={450}
      resizable>
      <Window.Content scrollable>

        <Section title="Cloud CPU Resources">
          <ProgressBar ranges={{
            good: [-Infinity, data.total_cpu],
            bad: [data.total_cpu, Infinity]
          }}
          value={data.total_assigned_cpu}
          maxValue={data.total_cpu}>{data.total_assigned_cpu}/{data.total_cpu} THz</ProgressBar>
          </Section>
          <Section title="Cloud RAM Resources">
          <ProgressBar ranges={{
            good: [-Infinity, 1],
            bad: [data.total_cpu, Infinity]
          }}
          value={data.total_assigned_ram}
          maxValue={data.total_ram}>{data.total_assigned_ram}/{data.total_ram} TB</ProgressBar>
          </Section>
        <Section title="Active AI's">
          <LabeledList>


        {data.ais.map(ai => {
              return (
                <Section title={ai.name}>
                  <LabeledList.Item>
                    CPU Capacity:
                    <Flex>
                      <ProgressBar minValue={0} value={data.assigned_cpu[ai.name]} maxValue={data.total_cpu} >{data.assigned_cpu[ai.name] ? data.assigned_cpu[ai] : 0} THz</ProgressBar>
                      <Button mr={1} ml={1} height={1.75} icon="plus" onClick={() => act("add_cpu", {
                        targetAI: ai.ref
                      })}></Button>
                      <Button height={1.75} icon="minus" onClick={() => act("remove_cpu", {
                        targetAI: ai.ref
                      })}></Button>
                    </Flex>

                  </LabeledList.Item>
                  <LabeledList.Item>
                    RAM Capacity:
                    <Flex>
                      <ProgressBar minValue={0} value={data.assigned_ram[ai.name]} maxValue={data.total_rap} >{data.assigned_ram[ai.name] ? data.assigned_ram[ai] : 0} TB</ProgressBar>
                      <Button mr={1} ml={1} height={1.75} icon="plus" onClick={() => act("add_ram", {
                        targetAI: ai.ref
                      })}></Button>
                      <Button height={1.75} icon="minus" onClick={() => act("remove_ram", {
                        targetAI: ai.ref
                      })}></Button>
                    </Flex>

                  </LabeledList.Item>
                </Section>
              );
            })}
            </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
