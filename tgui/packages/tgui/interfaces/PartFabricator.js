import { useBackend } from '../backend';
import { Tabs, Stack, Button, Section } from '../components';
import { Window } from '../layouts';

export const PartFabricator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    capacitor_energy,
    matterbin_moles,
    scanner_chemicals = [],
    laser_money,
    manipulator_temp,
    tab,
  } = data;
  return (
    <Window width={325} height={300}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tab === "capacitor"}
                onClick={() => act('goCapacitor')}>
                Capacitor
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === "matterbin"}
                onClick={() => act('goMatterBin')}>
                Matter Bin
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section>
              Required power for cubic capacitor: {capacitor_energy}<br />
              Required freon for matter bin of holding: {matterbin_moles}<br />
              Required chemicals for hexaphasic scanning module: {scanner_chemicals}<br />
              Required credits for quint-hyper micro-laser: {laser_money}<br />
              Required temperature for Planck-manipulator: {'>'}{manipulator_temp}<br />
              <Button color="bad" icon="eject" onClick={(e, value) => act('ejectESM')}>Eject</Button>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              content="PRINT"
              onClick={() => act('tryPrint')} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
