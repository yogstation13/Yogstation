import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const DonorGear = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="ntos">
      <Window.Content scrollable>
        <Section title="Available items:">
          {Object.keys(data.items_info.items).map(key => {
            let value = data.items_info.items[key];
            return (
              <Section title={`${value.name}`} key={key}>
                <Button
                  content={`Select ${value.name}`}
                  icon="check-square"
                  color={value.selected && "good"}
                  onClick={() => act('target', { target: value.id })} />
              </Section>);
          })}
        </Section>
        <Section title="Available hats:">
          {Object.keys(data.items_info.hats).map(key => {
            let value = data.items_info.hats[key];
            return (
              <Section title={`${value.name}`} key={key}>
                <Button
                  content={`Select ${value.name}`}
                  icon="check-square"
                  color={value.selected && "good"}
                  onClick={() => act('target', { target: value.id })} />
              </Section>);
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
