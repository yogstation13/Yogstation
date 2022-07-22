import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, NumberInput, NoticeBox, LabeledList, Collapsible, ProgressBar } from '../components';
import { Window } from '../layouts';


export const AiOverclocking = (props, context) => {
  const { act, data } = useBackend(context);

  const [increment, setIncrement] = useLocalState(context, 'increment', 0.1);

  let applyResult = function (index) {
    act('set_speed', { new_speed: data.last_values[index].speed });
    act('set_power', { new_power: data.last_values[index].power });
  };

  return (
    <Window
      width={600}
      height={550}>
      <Window.Content scrollable>
        {!data.overclock_progress && (
          <Section title="Overclocking" buttons={(<Button color="bad" icon="eject" onClick={(e, value) => act('eject_cpu')}>Eject CPU</Button>)}>
            {data.has_cpu && (
              <Fragment>
                <Collapsible title="Past Results">
                  {data.last_values.map((result, index) => (
                    <Section key={index} title={"Result #" + (index+1)} buttons={(<Button icon="check" onClick={(e, value) => applyResult(index)}>Apply</Button>)}>
                      <LabeledList>
                        <LabeledList.Item label="Clock Speed">
                          {result.speed}THz &nbsp;
                        </LabeledList.Item>
                        <LabeledList.Item label="Power Multiplier">
                          {result.power}THz &nbsp;
                        </LabeledList.Item>
                        <LabeledList.Item label="Valid Overclock">
                          {result.valid && (
                            <Box color="good">Valid</Box>
                          ) || (
                            <Box color="bad">Invalid</Box>
                          )}
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  ))}
                </Collapsible>
                <Section title="Settings" buttons={(<Button color="good" icon="vial" onClick={(e, value) => act('test_overclock')}>Test Overclock</Button>)}>
                  <LabeledList>
                    <LabeledList.Item label="Increment">
                      <NumberInput value={increment} minValue={0.1} maxValue={1} step="0.1" onChange={(e, value) => setIncrement(value)} />
                    </LabeledList.Item>
                    <LabeledList.Item label="Clock Speed">
                      {data.speed}THz &nbsp;
                      <Button icon="minus" onClick={(e, value) => act('set_speed', {
                        new_speed: data.speed - increment,
                      })} />
                      <NumberInput value={data.speed} minValue={1} maxValue={10} onChange={(e, value) => act('set_speed', {
                        new_speed: value,
                      })} />
                      <Button icon="plus" onClick={(e, value) => act('set_speed', {
                        new_speed: data.speed + increment,
                      })} />
                    </LabeledList.Item>
                    <LabeledList.Item label="Power Multiplier">
                      {data.power_multiplier}x ({data.power_usage}W)&nbsp;
                      <Button icon="minus" onClick={(e, value) => act('set_power', {
                        new_power: (data.power_multiplier - increment > 0.5)
                          ? data.power_multiplier - increment : 0.5,
                      })} />
                      <NumberInput value={data.power_multiplier} minValue={0.5} maxValue={5} onChange={(e, value) => act('set_power', {
                        new_power: value,
                      })} />
                      <Button icon="plus" onClick={(e, value) => act('set_power', {
                        new_power: data.power_multiplier + increment,
                      })} />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Fragment>
            )|| (
              <NoticeBox>Please insert a CPU</NoticeBox>
            )}
          </Section>
        ) || (
          <Section title="Overclocking in progress">
            <NoticeBox>Overclocking...</NoticeBox>
            <ProgressBar value={data.overclock_progress} />
            <Button color="bad" fluid icon="trash" mt={0.5} onClick={(e, value) => act('stop_overclock')}>Cancel</Button>
          </Section>
        )}

      </Window.Content>
    </Window>
  );
};


