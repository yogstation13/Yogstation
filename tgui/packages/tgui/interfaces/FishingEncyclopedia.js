import { useBackend } from '../backend';
import { Box, Button, Section, LabeledList } from '../components';
import { Window } from '../layouts';

export const FishingEncyclopedia = (props, context) => {
  const { act, data } = useBackend(context);

  const fish_map = data.f_list.map(fish => {
    return (
      <Box>{fish.name}{fish.min_weight}</Box>

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
