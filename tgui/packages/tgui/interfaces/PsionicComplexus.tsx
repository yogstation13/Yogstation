import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  antag_name: string;
  loud: boolean;
};

type User = {
  psi_stamina : number;
  supressing : boolean;
  known_powers : Psi_Power;
  psi_faculties : Psi_Faculty[];

};

type Psi_Power = {
  name : string;
  description : string;

};

type Psi_Faculty = {
  rank : number;

}

export const PsionicComplexus = (props, context) => {
  const { data } = useBackend<Data>(context);
  return (
    <Window width={620} height={250}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              Summary
            </Stack.Item>
            <Stack.Item>
              Power Usage
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

