
import { useBackend } from '../backend';
import { Section, Collapsible, Button } from '../components';
import { Window } from '../layouts';

export const DisconnectPanel = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
      title="Disconnect Panel"
      width={700}
      height={700}
      resizable>
      <Window.Content scrollable>
        <Section>
          Hello
        </Section>
      </Window.Content>
    </Window>
  );
};
