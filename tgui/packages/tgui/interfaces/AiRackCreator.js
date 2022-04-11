import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Modal, Section, Flex, Icon, Dimmer } from '../components';
import { Window } from '../layouts';
import { formatPower } from '../format';

export const AiRackCreator = (props, context) => {
  const { act, data } = useBackend(context);

  const [modalStatus, setModalStatus] = useLocalState(context, 'modal', false);
  const [ramIndex, setRamIndex] = useLocalState(context, 'ram', 0);

  return (
    <Window
      width={700}
      height={765}
      >
      <Window.Content scrollable>
        <Section title="Central Processing Units">
          <Box>
            <Flex>
              <Flex.Item width="40%" textAlign="center">
                <Section title="CPU #1">
                  {data.cpus.length <= 0 && (
                    <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("insert_cpu")} />
                  ) || (
                    <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("remove_cpu", {cpu_index: 1})} />
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
                  )}
                  {data.unlocked_cpu < 2 && (
                    <Dimmer><Box color="average">Locked <br/>Requires tech ###</Box></Dimmer>
                  )}
                </Section>
              </Flex.Item>
            </Flex>
            <Flex mt={2}>
              <Flex.Item width="40%" textAlign="center">
                <Section title="CPU #3">
                  {data.cpus.length <= 2 && (
                    <Button color="transparent" icon="microchip" iconSize="5" width="100%" onClick={() => act("insert_cpu")} />
                  )}
                  {data.unlocked_cpu < 3 && (
                    <Dimmer><Box color="average">Locked <br/>Requires tech ###</Box></Dimmer>
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
                  )}
                  {data.unlocked_cpu < 4 && (
                    <Dimmer><Box color="average">Locked <br/>Requires tech ###</Box></Dimmer>
                  )}
                </Section>
              </Flex.Item>
            </Flex>
          </Box>
        </Section>
        <Section title="Random Access Memory">
          <Section title="Stick #1" textAlign="center">
            <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => setModalStatus(true)}></Button>
          </Section>
          <Section title="Stick #2" textAlign="center">
            <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => setModalStatus(true)}></Button>
            {data.unlocked_ram < 2 && (
              <Dimmer><Box color="average">Locked <br/>Requires tech ###</Box></Dimmer>
            )}
          </Section>
          <Section title="Stick #3" textAlign="center">
            <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => setModalStatus(true)}></Button>
            {data.unlocked_ram < 3 && (
              <Dimmer><Box color="average">Locked <br/>Requires tech ###</Box></Dimmer>
            )}
          </Section>
          <Section title="Stick #4" textAlign="center">
            <Button width="100%" icon="memory" iconSize="3" color="transparent" onClick={() => setModalStatus(true)}></Button>
            {data.unlocked_ram < 4 && (
              <Dimmer><Box color="average">Locked <br/>Requires tech ###</Box></Dimmer>
            )}
          </Section>
        </Section>
        <Button.Confirm fontSize="20px" textAlign="center" icon="arrow-right" width="100%" color="good" content="Finalize" onClick={() => act("finalize")}></Button.Confirm>
      </Window.Content>
      {modalStatus && (
        <Modal width="600px">
          <Section title="Select RAM">
            {data.possible_ram.map((entry) => (
              <Section title={entry.name} buttons={(<Button color="green" tooltip={!entry.unlocked ? "Not Unlocked!" : ""} disabled={!entry.unlocked} onClick={() => {act("insert_ram", {ram_type: entry.id}); setModalStatus(false)}}>Select</Button>)}>
                <Box inline bold>Capacity:&nbsp;</Box>
                <Box inline>{entry.capacity}TB</Box>
                <br></br>
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
