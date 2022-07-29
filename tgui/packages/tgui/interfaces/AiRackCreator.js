import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Modal, Section, Flex, Dimmer } from '../components';
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

export const AiRackCreator = (props, context) => {
  const { act, data } = useBackend(context);

  const [modalStatus, setModalStatus] = useLocalState(context, 'modal', false);


  let upperCaseWords = function (string) {
    if (!string) return;
    let words = string.split(" ");
    for (let i = 0; i < words.length; i++) {
      words[i] = words[i][0].toUpperCase() + words[i].substr(1);
    }
    return words.join(" ");
  };

  return (
    <Window
      width={700}
      height={878}>
      <Window.Content scrollable>
        <Flex
          align="center"
          direction="column"
          mb="5px">
          <Flex align="center">
            <Flex.Item
              ml={1}
              mr={1}
              mt={1}
              basis="content"
              grow={1}>
              <Section
                title="Materials">
                <Materials />
              </Section>
            </Flex.Item>
          </Flex>
        </Flex>
        <Section title="Central Processing Units">
          <Box>
            <Flex>
              <Flex.Item width="40%" textAlign="center">
                <Section title="CPU #1">
                  {data.cpus.length <= 0 && (
                    <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("insert_cpu")} />
                  ) || (
                    <Fragment>
                      <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("remove_cpu", { cpu_index: 1 })} />
                      <Box inline bold position="absolute" bottom="50px" left="30px">{ data.cpus[0].speed }Thz</Box>
                      <Box inline bold position="absolute" bottom="50px" right="30px">{ data.cpus[0].power_usage }W</Box>
                      <Box inline bold position="absolute" bottom="35px" right="25px">({ data.cpus[0].efficiency }%)</Box>
                    </Fragment>
                  )}
                </Section>
              </Flex.Item>
              <Flex.Item grow={1} textAlign="center">
                <Box bold>Statistics</Box>
                <Box bold>Processing Power</Box>
                <Box>{data.total_cpu}Thz</Box>
                <Box bold>Power usage</Box>
                <Box>{formatPower(data.power_usage)}</Box>
                <Box bold>Efficiency</Box>
                <Box>{Math.round(data.efficiency * 100) / 100 * 100}%</Box>
              </Flex.Item>
              <Flex.Item width="40%" textAlign="center">
                <Section title="CPU #2">
                  {data.cpus.length <= 1 && (
                    <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("insert_cpu")} />
                  ) || (
                    <Fragment>
                      <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("remove_cpu", { cpu_index: 2 })} />
                      <Box inline bold position="absolute" bottom="50px" right="30px">{data.cpus[1].speed}Thz</Box>
                      <Box inline bold position="absolute" bottom="50px" left="30px">{data.cpus[1].power_usage}W</Box>
                      <Box inline bold position="absolute" bottom="35px" left="30px">({data.cpus[1].efficiency}%)</Box>
                    </Fragment>
                  )}
                  {data.unlocked_cpu < 2 && (
                    <Dimmer><Box color="average">Locked <br />Requires tech Improved CPU Sockets</Box></Dimmer>
                  )}
                </Section>
              </Flex.Item>
            </Flex>
            <Flex mt={2}>
              <Flex.Item width="40%" textAlign="center">
                <Section title="CPU #3">
                  {data.cpus.length <= 2 && (
                    <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("insert_cpu")} />
                  ) || (
                    <Fragment>
                      <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("remove_cpu", { cpu_index: 3 })} />
                      <Box inline bold position="absolute" bottom="50px" left="30px">{ data.cpus[2].speed }Thz</Box>
                      <Box inline bold position="absolute" bottom="50px" right="30px">{ data.cpus[2].power_usage }W</Box>
                      <Box inline bold position="absolute" bottom="35px" right="25px">({ data.cpus[2].efficiency }%)</Box>
                    </Fragment>
                  )}
                  {data.unlocked_cpu < 3 && (
                    <Dimmer><Box color="average">Locked <br />Requires tech Advanced CPU Sockets</Box></Dimmer>
                  )}
                </Section>
              </Flex.Item>
              <Flex.Item grow={1} textAlign="center">
                <Box bold>Memory Capacity</Box>
                <Box>{data.total_ram}Tb</Box>
              </Flex.Item>
              <Flex.Item width="40%" textAlign="center">
                <Section title="CPU #4">
                  {data.cpus.length <= 3 && (
                    <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("insert_cpu")} />
                  ) || (
                    <Fragment>
                      <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("remove_cpu", { cpu_index: 4 })} />
                      <Box inline bold position="absolute" bottom="50px" right="30px">{data.cpus[3].speed}Thz</Box>
                      <Box inline bold position="absolute" bottom="50px" left="30px">{data.cpus[3].power_usage}W</Box>
                      <Box inline bold position="absolute" bottom="35px" left="30px">({data.cpus[3].efficiency}%)</Box>
                    </Fragment>
                  )}
                  {data.unlocked_cpu < 4 && (
                    <Dimmer><Box color="average">Locked <br />Requires tech Bluespace CPU Sockets</Box></Dimmer>
                  )}
                </Section>
              </Flex.Item>
            </Flex>
          </Box>
        </Section>
        <Section title="Random Access Memory">
          <Section title="Stick #1" textAlign="center">
            {data.ram.length <= 0 && (
              <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => setModalStatus(true)} />
            ) || (
              <Fragment>
                <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => act("remove_ram", { ram_index: 1 })} />
                <Box inline bold position="absolute" bottom="25px" left="125px">{upperCaseWords(data.ram[0].name)}</Box>
                <Box inline position="absolute" bottom="25px" right="250px">{data.ram[0].capacity}TB</Box>
                <Box inline position="absolute" bottom="0px" left="0" right="0">{data.ram[0].cost.charAt(0).toUpperCase() + data.ram[0].cost.slice(1)}</Box>
              </Fragment>
            )}
          </Section>
          <Section title="Stick #2" textAlign="center">
            {data.ram.length <= 1 && (
              <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => setModalStatus(true)} />
            ) || (
              <Fragment>
                <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => act("remove_ram", { ram_index: 2 })} />
                <Box inline bold position="absolute" bottom="25px" left="125px">{ upperCaseWords(data.ram[1].name) }</Box>
                <Box inline position="absolute" bottom="25px" right="250px">{ data.ram[1].capacity }TB</Box>
                <Box inline position="absolute" bottom="0px" left="0" right="0">{ data.ram[1].cost.charAt(0).toUpperCase() + data.ram[1].cost.slice(1) }</Box>
              </Fragment>
            )}
            {data.unlocked_ram < 2 && (
              <Dimmer><Box color="average">Locked <br />Requires tech Improved Memory Bus</Box></Dimmer>
            )}
          </Section>
          <Section title="Stick #3" textAlign="center">
            {data.ram.length <= 2 && (
              <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => setModalStatus(true)} />
            ) || (
              <Fragment>
                <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => act("remove_ram", { ram_index: 3 })} />
                <Box inline bold position="absolute" bottom="25px" left="125px">{ upperCaseWords(data.ram[2].name) }</Box>
                <Box inline position="absolute" bottom="25px" right="250px">{ data.ram[2].capacity }TB</Box>
                <Box inline position="absolute" bottom="0px" left="0" right="0">{ data.ram[2].cost.charAt(0).toUpperCase() + data.ram[2].cost.slice(1) }</Box>
              </Fragment>
            )}
            {data.unlocked_ram < 3 && (
              <Dimmer><Box color="average">Locked <br />Requires tech Advanced Memory Bus</Box></Dimmer>
            )}
          </Section>
          <Section title="Stick #4" textAlign="center">
            {data.ram.length <= 3 && (
              <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => setModalStatus(true)} />
            ) || (
              <Fragment>
                <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => act("remove_ram", { ram_index: 4 })} />
                <Box inline bold position="absolute" bottom="25px" left="125px">{ upperCaseWords(data.ram[3].name) }</Box>
                <Box inline position="absolute" bottom="25px" right="250px">{ data.ram[3].capacity }TB</Box>
                <Box inline position="absolute" bottom="0px" left="0" right="0">{ data.ram[3].cost.charAt(0).toUpperCase() + data.ram[3].cost.slice(1) }</Box>
              </Fragment>
            )}
            {data.unlocked_ram < 4 && (
              <Dimmer><Box color="average">Locked <br />Requires tech Bluespace Memory Bus</Box></Dimmer>
            )}
          </Section>
        </Section>
        <Button.Confirm fontSize="20px" textAlign="center" icon="arrow-right" width="100%" color="good" content="Finalize" onClick={() => act("finalize")} />
      </Window.Content>
      {modalStatus && (
        <Modal width="600px">
          <Section title="Select RAM">
            {data.possible_ram.map((entry, index) => (
              <Section key={index} title={entry.name} buttons={(<Button color="green" tooltip={!entry.unlocked ? "Not Unlocked!" : ""} disabled={!entry.unlocked} onClick={() => { act("insert_ram", { ram_type: entry.id }); setModalStatus(false); }}>Select</Button>)}>
                <Box inline bold>Capacity:&nbsp;</Box>
                <Box inline>{entry.capacity}TB</Box>
                <br />
                <Box inline bold>Cost:&nbsp;</Box>
                <Box italic inline>{entry.cost.charAt(0).toUpperCase() + entry.cost.slice(1)}</Box>
              </Section>
            ))}
            <Button fontSize="18px" width="100%" textAlign="center" color="red" onClick={() => setModalStatus(false)}>Cancel</Button>
          </Section>
        </Modal>
      )}
    </Window>
  );
};

const Materials = (props, context) => {
  const { data } = useBackend(context);

  const materials = data.materials || [];

  return (
    <Flex
      wrap="wrap">
      {materials.filter(material => MATERIAL_KEYS[material.name]).map(material => (
        <Flex.Item
          width="80px"
          key={material.name}>
          <MaterialAmount
            name={material.name}
            amount={material.amount}
            formatsi />
          <Box
            mt={1}
            style={{ "text-align": "center" }} />
        </Flex.Item>
      ))}
    </Flex>
  );
};

const MaterialAmount = (props, context) => {
  const {
    name,
    amount,
    formatsi,
    color,
    style,
  } = props;

  if (MATERIAL_KEYS[name]) {
    return (
      <Flex
        direction="column"
        align="center">
        <Flex.Item>
          <Box
            className={classes([
              'sheetmaterials32x32',
              MATERIAL_KEYS[name],
            ])}
            style={style} />
        </Flex.Item>
        <Flex.Item>
          <Box
            textColor={color}
            style={{ "text-align": "center" }}>
            {(formatsi && formatSiUnit(amount, 0))}
          </Box>
        </Flex.Item>
      </Flex>
    );
  }

};
