import { useBackend } from '../backend';
import { Section, Stack, Table, Collapsible } from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';

type Data = {
  antag_name: string;
  loud: boolean;
  faculties: Psi_Faculty[];
  use_rating: string;
  rating_descriptor: string;
};

type User = {
  psi_stamina: number;
  supressing: boolean;
  known_powers: Psi_Power;
  psi_faculties: Psi_Faculty[];

};

type Psi_Power = {
  name: string;
  description: string;

};

type Psi_Faculty = {
  name: string;
  rank: number;
  powers: Psi_Power[];

}

export const PsionicComplexus = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { faculties = [], use_rating, rating_descriptor } = data;
  return (
    <Window width={620} height={500}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section>
              <h1>
                {
                  "Psi-Rating: " + use_rating
                }
              </h1>

            </Section>

          </Stack.Item>
          <Stack.Item>
            {faculties.map(faculty => (
              <Section title={faculty.name} key={faculty.name}>
                {faculty.powers.map(power => (
                  <Collapsible
                    key={power.name}
                    title={power.name} bold>
                    <Section>
                      {power.description}
                    </Section>
                  </Collapsible>
                ))}
              </Section>

            ))}
          </Stack.Item>
        </Stack>

      </Window.Content >
    </Window >
  );
};

