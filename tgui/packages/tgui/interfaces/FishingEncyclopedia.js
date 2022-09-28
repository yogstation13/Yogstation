import { capitalize, toTitleCase } from "common/string";
import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from "../backend";
import { Flex, Icon, Box, Section, Tabs } from "../components";
import { Window } from "../layouts";

export const FishingEncyclopedia = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    fish_list = [],
  } = data;
  const [selectedFish] = useLocalState(context, "fish", fish_list[0]);

  return (
    <Window
      title="Fishing Encyclopedia"
      theme="fish_book"
      width={600}
      height={450}>
      <Window.Content>
        <Flex class="content">
          <Flex class="book">
            <div class="spine" />
            <Flex class="page">
              <Flex.Item class="TOC">
                Table of Contents
              </Flex.Item>
              <Flex.Item class="fish_tab_list">
                <FishTabs />
              </Flex.Item>
            </Flex>
            <Flex class="page">
              <FishInfo />
            </Flex>
          </Flex>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const FishInfo = (props, context) => {
  const { data } = useBackend(context);

  const { fish_list = [] } = data;
  const [selectedFish] = useLocalState(context, "fish", fish_list[0]);
  return (
    <Flex class="fish-info-container">
      <Flex.Item class="fish-title">
        {toTitleCase(selectedFish.name)}
      </Flex.Item>
      <Flex.Item class="fish-icon-container">
        <Box
          class="fish_icon"
          as="img"
          src={resolveAsset(selectedFish.fish_icon)}
          height="96px"
          style={{
            '-ms-interpolation-mode': 'nearest-neighbor',
            'image-rendering': 'pixelated' }} />
      </Flex.Item>
      <Flex.Item class="fish-metric">
        {"Minimum Recorded Length: " + selectedFish.min_length + "in"}
      </Flex.Item>
      <Flex.Item class="fish-metric">
        {"Maximum Recorded Length: " + selectedFish.max_length + "in"}
      </Flex.Item>
      <Flex.Item class="fish-metric">
        {"Minimum Recorded Weight: " + selectedFish.min_weight + "oz"}
      </Flex.Item>
      <Flex.Item class="fish-metric">
        {"Maximum Recorded Weight: " +selectedFish.max_weight + "oz"}
      </Flex.Item>
    </Flex>
  );
};

const FishTabs = (props, context) => {
  const { data } = useBackend(context);

  const { fish_list = [] } = data;
  const [selectedFish, setSelectedFish] = useLocalState(
    context,
    "fish",
    fish_list[0]
  );
  return (
    <Tabs vertical>
      {fish_list.map(fish => (
        <Tabs.Tab
          key={fish}
          selected={fish === selectedFish}
          onClick={() => setSelectedFish(fish)}>
          {fish.name}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
