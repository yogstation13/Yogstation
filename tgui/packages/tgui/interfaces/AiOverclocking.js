import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Modal, Section, Flex, NumberInput, NoticeBox, LabeledList, Collapsible, ProgressBar } from '../components';
import { Window } from '../layouts';
import { formatPower, formatSiUnit } from '../format';
import { classes } from 'common/react';

const MATERIAL_KEYS = {
  "iron": "sheet-metal_3",
  "glass": "sheet-glass_3",
  "silver": "sheet-silver_3",
  "gold": "sheet-gold_3",
  "bluespace crystal": "polycrystal",
};

export const AiOverclocking = (props, context) => {
  const { act, data } = useBackend(context);

  const [increment, setIncrement] = useLocalState(context, 'increment', 0.1);

  let upperCaseWords = function (string) {
    if (!string) return;
    let words = string.split(" ");
    for (let i = 0; i < words.length; i++) {
      words[i] = words[i][0].toUpperCase() + words[i].substr(1);
    }
    return words.join(" ");
  };
  data.overclocking = true

  let applyResult = function(index) {
    act('set_speed', {new_speed: data.last_values[index].speed});
    act('set_power', {new_power: data.last_values[index].power});
  }

  return (
    <Window
      width={600}
      height={550}>
      <Window.Content scrollable>
        {!data.overclock_progress && (
          <Section title="Overclocking" buttons={(<Button color="good" icon="check" onClick={(e, value) => act('eject_cpu')}>Eject CPU</Button>)}>
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
                          <NumberInput value={increment} minValue={0.1} maxValue={1} step="0.1" onChange={(e, value) => setIncrement(value)}/>
                        </LabeledList.Item>
                        <LabeledList.Item label="Clock Speed">
                          {data.speed}THz &nbsp;
                          <Button icon="minus" onClick={(e, value) => act('set_speed', {
                            new_speed: data.speed - increment,
                          })}/>
                          <NumberInput value={data.speed} minValue={1} maxValue={10} onChange={(e, value) => act('set_speed', {
                            new_speed: value,
                          })}/>
                          <Button icon="plus" onClick={(e, value) => act('set_speed', {
                            new_speed: data.speed + increment,
                          })}/>
                        </LabeledList.Item>
                        <LabeledList.Item label="Power Multiplier">
                          {data.power_multiplier}x ({data.power_usage}W)&nbsp;
                          <Button icon="minus" onClick={(e, value) => act('set_power', {
                            new_power: (data.power_multiplier - increment > 0.5) ? data.power_multiplier - increment : 0.5,
                          })}/>
                          <NumberInput value={data.power_multiplier} minValue={0.5} maxValue={5} onChange={(e, value) => act('set_power', {
                            new_power: value,
                          })}/>
                          <Button icon="plus" onClick={(e, value) => act('set_power', {
                            new_power: data.power_multiplier + increment,
                          })}/>
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
            <ProgressBar value={data.overclock_progress}></ProgressBar>
            <Button color="bad" fluid icon="trash" mt={0.5} onClick={(e, value) => act('stop_overclock')}>Cancel</Button>
          </Section>
        )}

      </Window.Content>
    </Window>
  );
};


