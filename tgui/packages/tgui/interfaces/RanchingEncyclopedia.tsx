import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Flex, Tabs, Stack, DmIcon, Icon } from '../components';
import { Direction } from '../components/DmIcon';
import { Window } from '../layouts';

type Chicken = {
  name: string;
  desc: string;
  max_age?: number;
  happiness?: number;
  temperature?: number;
  temperature_variance?: number;
  needed_pressure?: number;
  pressure_variance?: number;
  food_requirements?: string;
  reagent_requirements?: string;
  player_job?: string;
  player_health?: number;
  needed_species?: string;
  required_atmos?: string;
  required_rooster?: string;
  liquid_depth?: number;
  needed_turfs?: string;
  nearby_items?: string;
  comes_from?: string;
  icon: string;
  icon_suffix: string;
};

type Data = {
  chickens: Chicken[];
};

export const RanchingEncyclopedia = () => {
  return (
    <Window
      title="Ranching Encyclopedia"
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
              <Stack.Item>
                <ChickenTabs />
              </Stack.Item>
            </Stack>
            <Stack class="page">
              <ChickenInfo />
            </Stack>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type ChickenIconProps = {
  icon: string;
  suffix: string;
};

const ChickenIcons = (props: ChickenIconProps) => {
  const { icon, suffix } = props;
  return (
    <Stack>
      {['chicken', 'rooster'].map((prefix) => (
        <Stack.Item key={prefix}>
          <DmIcon
            icon={icon}
            icon_state={`${prefix}_${suffix}`}
            direction={Direction.EAST}
            fallback={<Icon mr={1} name="spinner" spin />}
            height={'96px'}
            width={'96px'}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const ChickenInfo = () => {
  const {
    data: { chickens = [] },
  } = useBackend<Data>();
  const [selectedChicken] = useLocalState('selectedChicken', chickens[0]);
  return (
    <Flex class="chicken-info-container">
      <Flex.Item class="chicken-title">
        {toTitleCase(selectedChicken.name)}
      </Flex.Item>
      <Flex.Item class="chicken-icon-container">
        <ChickenIcons
          icon={selectedChicken.icon}
          suffix={selectedChicken.icon_suffix}
        />
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.comes_from &&
          'Mutates from: ' + selectedChicken.comes_from}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.max_age &&
          'Maximum Living Age: ' + selectedChicken.max_age}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.desc && 'Description: ' + selectedChicken.desc}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.happiness &&
          'Required Happiness: ' + selectedChicken.happiness}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.temperature &&
          'Requires temperatures within ' +
            selectedChicken.temperature_variance +
            'K of ' +
            selectedChicken.temperature +
            'K'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.needed_pressure &&
          'Requires pressure within ' +
            selectedChicken.pressure_variance +
            ' of ' +
            selectedChicken.needed_pressure}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.food_requirements &&
          'Chicken needs to have eaten ' + selectedChicken.food_requirements}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.reagent_requirements &&
          'Chicken needs to have consumed ' +
            selectedChicken.reagent_requirements}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.player_job &&
          'A ' +
            selectedChicken.player_job +
            " needs to be present for this chicken's birth."}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.needed_species &&
          'A ' +
            selectedChicken.needed_species +
            " needs to be present for this chicken's birth."}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.player_health &&
          'A crew member that has been injured by atleast ' +
            selectedChicken.player_health +
            ' points.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.required_atmos &&
          'Chicken needs to be an environment with ' +
            selectedChicken.required_atmos +
            ' present.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.required_rooster &&
          'A ' +
            selectedChicken.required_rooster +
            ' needs to be around for the egg to hatch.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.liquid_depth &&
          'Their needs to be a pool of liquid atleast' +
            selectedChicken.liquid_depth +
            ' deep for the egg to hatch.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.needed_turfs &&
          'Their needs to be ' +
            selectedChicken.needed_turfs +
            ' around for the egg to hatch.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.nearby_items &&
          'The Chicken needs to be given ' +
            selectedChicken.nearby_items +
            ' to mutate.'}
      </Flex.Item>
    </Flex>
  );
};

const ChickenTabs = () => {
  const {
    data: { chickens = [] },
  } = useBackend<Data>();
  const [selectedChicken, setSelectedChicken] = useLocalState(
    'selectedChicken',
    chickens[0],
  );
  return (
    <Tabs vertical overflowY="auto">
      {chickens.map((chicken) => (
        <Tabs.Tab
          key={chicken.name}
          selected={chicken === selectedChicken}
          onClick={() => setSelectedChicken(chicken)}
        >
          {chicken.name}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
