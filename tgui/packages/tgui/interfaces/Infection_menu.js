import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const infection_menu = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    evolution_points,
  } = data;

  const upgrade_list = data.upgrades;
  return (
    <Window
      width={500}
      height={900}
      resizable>
      <Window.Content scrollable>
        <Section title="Evolution Menu">
          Evolution Points : {evolution_points}
          {upgrade_list!==null ? (
            upgrade_list.map(upgrade => (
              <Section
                key={upgrade.name}
                title={upgrade.name}
                level={2}>
                <Box my={1}>
                  <Button
                    disabled={!upgrade.can_purchase}
                    content={upgrade.owned ? "Evolved" : "Evolve"}
                    color={upgrade.owned ? 'green' : null}
                    onClick={() => act('evolve', {
                      name: upgrade.name,
                    })} />
                  {' '}
                  Cost : {upgrade.upgrade_cost} Remaining Upgrades : {upgrade.times}
                </Box >
                <Box my={1}>
                  {upgrade.desc}
                </Box>
              </Section>
            ))
          ) : (
            <Box>
              No evolutions available
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};