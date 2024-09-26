import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const BombActualizer = (props) => {
  const { act } = useBackend();
  return (
    <Window width={280} height={100}>
      <Window.Content>
        <BombActualizerContent />
      </Window.Content>
    </Window>
  );
};

export const BombActualizerContent = (props) => {
  const { act } = useBackend();
  const color = 'rgba(13, 13, 213, 0.7)';
  const backColor = 'rgba(0, 0, 69, 0.5)';
  return (
    <Section>
      <Button
        mb={-0.1}
        color="danger"
        fluid
        icon="bomb"
        content="Start Countdown"
        textAlign="center"
        onClick={() => act('start_timer')}
      />
    </Section>
  );
};
