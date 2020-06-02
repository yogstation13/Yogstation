import { useBackend } from '../backend';
import { Button, LabeledList, Section, Box } from '../components';
import { Window } from '../layouts';

export const PsiWeb = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content>
      <Section title="Psi Web">
        <LabeledList>
            <LabeledListItem label="Lucidity" right>
                {data.lucidity}
            </LabeledListItem>
        </LabeledList>
      </Section>
      <Section title="Abilities">
        {data.abilities.map(ability => (
          <Fragment>
            <Box>{ability.desc}</Box>
            <Box>Psi use cost: {ability.psi_cost}</Box>
            <Box>Cost to unlock: {ability.lucidity_cost}</Box>
            <Button

            />
          </Fragment>
        ))}
      </Section>
      </Window.Content>
    </Window>
  );
};
