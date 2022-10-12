import { useBackend } from '../backend';
import { Button, LabeledList, Section, Box } from '../components';
import { Window } from '../layouts';

export const HorrorMutate = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={900} height={480} resizable>
      <Window.Content scrollable>
        <Section title="Mutation Menu">
          <LabeledList>
            <LabeledList.Item label="Available points" right>
              {data.available_points}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Abilities">
          <LabeledList>
            {data.abilities.map(ability => (

              <LabeledList.Item label={ability.name} key={ability.name}>
                <Box>{ability.desc}</Box>
                <Box>Cost to unlock: {ability.soul_cost}</Box>
                <Button
                  selected={ability.owned}
                  disabled={!ability.can_purchase}
                  onClick={() => act('unlock', {
                    'typepath': ability.typepath,
                  })}
                  content={ability.owned ? "Unlocked" : "Unlock"}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Upgrades">
          <LabeledList>
            {data.upgrades.map(upgrade => (

              <LabeledList.Item label={upgrade.name} key={upgrade.name}>
                <Box>{upgrade.desc}</Box>
                <Box>Cost to unlock: {upgrade.soul_cost}</Box>
                <Button
                  selected={upgrade.owned}
                  disabled={!upgrade.can_purchase}
                  onClick={() => act('upgrade', {
                    'id': upgrade.id,
                  })}
                  content={upgrade.owned ? "Unlocked" : "Unlock"}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
