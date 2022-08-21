import { useBackend } from '../backend';
import { Box, Button, Section, LabeledList } from '../components';
import { Window } from '../layouts';

export const FishingEncyclopedia = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    all_fish
  } = data;

  const fish_map = all_fish.map(fish => {
    return (
      <Box>{fish}</Box>
    );
  });

  return (
    <Window title="Fishing Encyclopedia" width={450} height={350}>
      <Window.Content>
        {fish_map}
      </Window.Content>
    </Window>
  );
};
