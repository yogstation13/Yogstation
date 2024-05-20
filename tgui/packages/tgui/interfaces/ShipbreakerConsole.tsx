import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const ShipbreakerConsole = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  // const {
  //   health,
  //   color,
  // } = data;
  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Call Ship To Break">
              <Button
                content="Call Ship!"
                onClick={() => act('spawn_ship')} />
        </Section>
        <Section title="Clear Floor Plating">
              <Button
                content="Clear it!"
                onClick={() => act('clear_floor_plating')} />
        </Section>
      </Window.Content>
    </Window>
  );
};
