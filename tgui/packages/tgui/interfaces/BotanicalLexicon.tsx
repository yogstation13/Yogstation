import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Flex, Tabs, Stack, DmIcon, Icon } from '../components';
import { Window } from '../layouts';

type Requirement = {
  stat: string;
  low: number;
  high: number;
};

type ResultIcon = {
  path: string;
  icon: string;
  icon_state: string;
};

type Plant = {
  name: string;
  desc: string;
  requirements: Requirement[];
  mutates_from?: string;
  required_reagents?: string;
  results: ResultIcon[];
};

type Data = {
  plants: Plant[];
};

export const BotanicalLexicon = () => {
  return (
    <Window
      title="Botanical Encyclopedia"
      theme="chicken_book"
      width={600}
      height={450}
    >
      <Window.Content>
        <Stack class="content">
          <Stack class="book">
            <div class="spine" />
            <Stack class="page">
              <Stack.Item class="TOC">Table of Contents</Stack.Item>
              <Stack.Item class="chicken_tab_list">
                <PlantTabs />
              </Stack.Item>
            </Stack>
            <Stack class="page">
              <PlantInfo />
            </Stack>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PlantInfo = () => {
  const {
    data: { plants = [] },
  } = useBackend<Data>();
  const [selectedPlant] = useLocalState('plant', plants[0]);
  return (
    <Flex class="chicken-info-container">
      <Flex.Item class="chicken-title">
        {toTitleCase(selectedPlant.name)}
      </Flex.Item>

      <Flex.Item class="chicken-icon-container">
        <Stack>
          {selectedPlant.results.map((result) => (
            <Stack.Item key={result.path}>
              <DmIcon
                icon={result.icon}
                icon_state={result.icon_state}
                fallback={<Icon mr={1} name="spinner" spin />}
                height={'96px'}
                width={'96px'}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Flex.Item>

      <Flex.Item class="chicken-metric">
        {selectedPlant.mutates_from &&
          'Mutates From:' + selectedPlant.mutates_from}
      </Flex.Item>

      <Flex.Item class="chicken-metric">
        {selectedPlant.desc && 'Description:' + selectedPlant.desc}
      </Flex.Item>

      {selectedPlant.requirements.map((stat) => (
        <Flex.Item class="chicken-metric" key={stat.stat}>
          {stat.stat} Range: {stat.low} to {stat.high}
        </Flex.Item>
      ))}

      <Flex.Item class="chicken-metric">
        {selectedPlant.required_reagents &&
          'Required Infusions: ' + selectedPlant.required_reagents}
      </Flex.Item>
    </Flex>
  );
};

const PlantTabs = (props) => {
  const {
    data: { plants = [] },
  } = useBackend<Data>();
  const [selectedPlant, setSelectedPlant] = useLocalState('plant', plants[0]);
  return (
    <Tabs vertical overflowY="auto">
      {plants.map((plant) => (
        <Tabs.Tab
          key={plant}
          selected={plant === selectedPlant}
          onClick={() => setSelectedPlant(plant)}
        >
          {plant.name}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
