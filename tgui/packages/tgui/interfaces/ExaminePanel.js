import { useBackend } from '../backend';
import { Stack, Section, ByondUi } from '../components';
import { Window } from '../layouts';

export const ExaminePanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    character_name,
    assigned_map,
    flavor_text,
    ooc_notes,
    custom_species,
    custom_species_lore,
  } = data;
  return (
    <Window
      title="Examine Panel"
      width={900}
      height={670}
      theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Section fill title="Character Preview">
              <ByondUi
                height="100%"
                width="100%"
                className="ExaminePanel__map"
                params={{
                  id: assigned_map,
                  type: 'map',
                }} />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <Section scrollable fill title={character_name + "'s Flavor Text:"}>
                  {flavor_text}
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  <Stack.Item grow basis={0}>
                    <Section scrollable fill title="OOC Notes">
                      {ooc_notes}
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <Section scrollable fill title={(custom_species ? "Species: " + custom_species : "No Custom Species!")}>
                      {(custom_species ? custom_species_lore : "Just a normal space dweller.")}
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
