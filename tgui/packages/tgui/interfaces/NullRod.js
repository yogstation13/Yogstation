import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const NullRod = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    categories = [],
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Nullrod">
          <LabeledList>
            <LabeledList.Item label="Name">
              {categories?.nullrod_weapons?.[1]?.name}
            </LabeledList.Item>
            <LabeledList.Item label="Desc">
              {categories?.nullrod_weapons?.[1]?.desc}
            </LabeledList.Item>
            <LabeledList.Item label="Button">
              <Button
                content="Dispatch a 'test' action"
                onClick={() => act('test')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
