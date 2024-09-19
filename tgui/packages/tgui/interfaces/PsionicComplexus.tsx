import { useBackend } from '../backend';
import { Section, Stack, Table, Collapsible } from '../components';
import { TableCell, TableRow } from '../components/Table';
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
      <Window.Content scrollable>
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
      </Window.Content >
    </Window >
  );
};

