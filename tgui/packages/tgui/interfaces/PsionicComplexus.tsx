import { useBackend } from '../backend';
import { Section, Stack, Box, Button, Table, Collapsible } from '../components';
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
  path: string;
};

type Psi_Faculty = {
  name: string;
  rank: number;
  powers: Psi_Power[];
}

export const PsionicComplexus = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { faculties = [], use_rating, rating_descriptor } = data;
  return (
    <Window width={650} height={700}>
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
            <Section>
              <Button
                key={"deselect"}
                content={"Deselect"}
                tooltip={"You can also deselect by right-clicking the ability button."}
                onClick={() => act('deselect', {
                })}
                />
            </Section>

          </Stack.Item>
          <Stack.Item>
            {faculties.map(faculty => (
              <Section title={faculty.name} key={faculty.name}>
                {faculty.powers.map(power => (
                  <Section
                    key={power.name} >
                    <Stack horizontal>

                      <Stack.Item
                        width='20%'>
                        {"Icon goes here"}
                      </Stack.Item>

                      <Stack vertical
                        width='65%'>
                        <Stack.Item
                          fontSize='16px'>
                          {power.name}
                        </Stack.Item>
                        <Stack.Item>
                          {power.description}
                        </Stack.Item>
                      </Stack>

                      <Stack.Item
                        style={{
                          'float': 'right' }}
                        fontSize='16px'
                        width='15%'>
                        <Button
                          key={power.name}
                          content={"Activate"}
                          onClick={() => act('select', {
                            ability: power.path,
                          })}
                          />
                      </Stack.Item>
                    </Stack>
                  </Section>
                ))}
              </Section>

            ))}
          </Stack.Item>
        </Stack>

      </Window.Content >
    </Window >
  );
};

