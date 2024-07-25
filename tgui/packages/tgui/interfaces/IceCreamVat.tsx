import { capitalize } from 'common/string';
import { useBackend } from '../backend';
import { Button, Section, Table, Tabs, Box, TextArea } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

type Data = {
  cones: ConeStats[];
  ice_cream: IceCreamStats[];
}

type IceCreamStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
}

type ConeStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
}

export const IceCreamVat = (props, context) => {

  return(
    <Window width={620} height={600} resizable>
      <Window.Content
        scrollable>
        <Section title="Cones">
          <ConeRow/>
        </Section>
        <Section title="Scoops">
          <IceCreamRow/>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ConeRow = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { cones = [] } = data;

  return (
    <Table>
      {cones.map(flavor => (
        <Table.Row
         key={flavor.item_name}
         fontSize="14px">
            <Table.Cell>
            <Box
            as="img"
            src={resolveAsset(flavor.item_image)}
            height="32px"
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
              'image-rendering': 'pixelated' }} />
            </Table.Cell>
            <Table.Cell
              bold>
            {capitalize(flavor.item_name)}
            </Table.Cell>
            <Table.Cell
              textAlign="right">
            {flavor.item_quantity} in storage
            </Table.Cell>
            <Table.Cell>
            <Button
            fluid
            content="Select"
            textAlign="center"
            fontSize="16px"
            disabled={(
              flavor.item_quantity === 0
            )}
            onClick={() => act("select", {
            itemPath: flavor.item_type_path,
            })}
            />
            <Button
            fluid
            content="Dispense"
            textAlign="center"
            fontSize="16px"
            disabled={(
              flavor.item_quantity === 0
            )}
            onClick={() => act("dispense", {
            itemPath: flavor.item_type_path,
            })}
            />
            </Table.Cell>
        </Table.Row>
     ))}
    </Table>
  );
};

const IceCreamRow = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { ice_cream = [] } = data;

  return (
    <Table>
      {ice_cream.map(flavor => (
        <Table.Row
         key={flavor.item_name}
         fontSize="14px">
            <Table.Cell>
            <Box
            as="img"
            src={resolveAsset(flavor.item_image)}
            height="32px"
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
              'image-rendering': 'pixelated' }} />
            </Table.Cell>
            <Table.Cell
              bold>
            {capitalize(flavor.item_name)}
            </Table.Cell>
            <Table.Cell
              textAlign="right">
            {flavor.item_quantity} in storage
            </Table.Cell>
            <Table.Cell>
            <Button
            fluid
            content="Select"
            textAlign="center"
            fontSize="16px"
            disabled={(
              flavor.item_quantity === 0
            )}
            onClick={() => act("select", {
            itemPath: flavor.item_type_path,
            })}
            />
            <Button
            fluid
            content="Dispense"
            textAlign="center"
            fontSize="16px"
            disabled={(
              flavor.item_quantity === 0
            )}
            onClick={() => act("dispense", {
            itemPath: flavor.item_type_path,
            })}
            />
            </Table.Cell>
        </Table.Row>
     ))}
    </Table>
  );
};
