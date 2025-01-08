import { useBackend } from '../backend';
import { Button, Box, Table, Section } from '../components';
import { Window } from '../layouts';

type HealthcareData = {
  payee: string;
  current_price: number;
  selected_care: string[] | null;
  available_care: any;
};
// https://i.imgur.com/AQlT2gV.png
export const Healthcare = (props, context) => {
  const { act, data } = useBackend<HealthcareData>(context);
  return (
    <Window
      width={400}
      height={500}>
      <Window.Content>
        <Section title="Order" height={28}>
          <Table>
            {data.selected_care?.map((val, idx) => (
              <Table.Row key={idx} style={{
                  'border': '2px solid',
                  'border-color': '#4d4d4d',
                  'background-color': '#007cb2',
                }}>
                <Table.Cell px={1} py={1}>
                  {val}
                </Table.Cell>
                <Table.Cell bold collapsing minWidth={5}>
                  {data.available_care[val]+'cr'}
                </Table.Cell>
              </Table.Row>
            ))}
            <Table.Row style={{
                  'border': '2px solid',
                  'border-color': '#4d4d4d',
                  'background-color': '#39888a',
                }}>
              <Table.Cell bold px={2} py={2}>
                Total
              </Table.Cell>
              <Table.Cell bold collapsing minWidth={5}>
                {
                  (data.selected_care === null || data.selected_care.length === 0) ? '0' :
                  (
                    data.selected_care.length === 1 ? data.available_care[data.selected_care[0]] :
                    (
                      data.selected_care?.reduce(
                        (acc, curr) =>
                        (
                          ((acc in data.available_care) ? data.available_care[acc] : acc) + data.available_care[curr]
                        )
                      )
                    )
                  )
                }cr
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Button.Confirm
                mx={1}
                my={1}
                px={1}
                py={1}
                disabled={data.selected_care === null || data.selected_care.length === 0}
                content='Checkout'
                onClick={() => act('pay_for_care')} />
            </Table.Row>
          </Table>
        </Section>
        <Section title="Select Care">
          {Object.entries(data.available_care).map((key, idx) => (
            <Button
              key={idx}
              content={key[0]}
              color={(data.selected_care || []).includes(key[0]) ? 'good' : 'bad'}
              onClick={() => act('toggle_care', {
                care: key[0],
              })} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
