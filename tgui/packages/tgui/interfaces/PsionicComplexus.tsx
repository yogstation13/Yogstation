import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  antag_name: string;
  loud: boolean;
  faculties: Psi_Faculty[];
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
  const { faculties = [] } = data;
  return (
    <Window width={620} height={500}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              Summary
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                {faculties.map(faculty => (
                  <Stack.Item
                    key={faculty.name}>
                    <Section title={faculty.name}>


                      <Stack vertical>

                        {faculty.powers.map(power => (
                          <Stack.Item
                            key={power.name}>
                            {power.name + ": " + power.description}

                          </Stack.Item>

                        ))}

                      </Stack>
                    </Section>
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content >
    </Window >
  );
};

