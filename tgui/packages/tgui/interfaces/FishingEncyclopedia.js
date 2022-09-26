import { useBackend } from '../backend';
import { Box, Button, Section, LabeledList } from '../components';
import { Window } from '../layouts';

export const FishingEncyclopedia = (props, context) => {
  const { act, data } = useBackend(context);
  const { f_list } = data
  /*
  const fish_map = data.f_list
  const fish_map2 = fish_map.map(fish => {
    return (
      <Box>{fish.name}{fish.min_weight}</Box>

    );
  });
  */

  return (
    <Window title="Fishing Encyclopedia" width={450} height={350}>
      <Window.Content>
        {"Hello" + f_list.name}
      </Window.Content>
    </Window>
  );
};
