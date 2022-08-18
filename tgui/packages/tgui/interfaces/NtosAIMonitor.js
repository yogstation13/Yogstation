import { NtosWindow } from '../layouts';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Box, Section } from '../components';

export const NtosAIMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <NtosWindow
      width={370}
      height={400}
      resizable>
      <NtosWindow.Content scrollable>
        <Section title="cool">
          <Box>{data.has_ai_net}</Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
