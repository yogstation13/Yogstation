import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  health: BooleanLike;
};

export const ShipbreakerConsole = (props) => {
  const { act, data } = useBackend<Data>();
  // Extract `health` and `color` variables from the `data` object.
  const { health } = data;
  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Ship Health">
          <ProgressBar
            title="Health"
            value={health}
            maxValue={100}
            ranges={{
              good: [100 * 0.75, 100],
              average: [100 * 0.25, 100 * 0.75],
              bad: [0, 100 * 0.25],
            }}
          />
        </Section>
        <Section title="Call Ship To Break">
          <Button content="Call Ship!" onClick={() => act('spawn_ship')} />
        </Section>
        <Section title="Clear Floor Plating">
          <Button
            content="Clear it!"
            onClick={() => act('clear_floor_plating')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
