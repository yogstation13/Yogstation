import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Stack, Section, Tabs, Table, Box, TextArea } from '../components';
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
  item_max_quantity: number;
  item_type_path: string;
}

type ConeStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_max_quantity: number;
  item_type_path: string;
}

export const IceCreamVat = (props, context) => {

  return(
    <Window width={650} height={500} resizable>
      <Window.Content>
        <Section title="Cones">
          <Stack.Item>
            <ConesRow/>
          </Stack.Item>
        </Section>
        <Section title="Scoops">
          <Stack.Item>
            <IceCreamRow/>
          </Stack.Item>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ConesRow = (props, context) => {
  const { act, data } = useBackend<ConeStats>(context);

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <Box
        as="img"
        src={resolveAsset(data.item_image)}
        height="96px"
        style={{
          '-ms-interpolation-mode': 'nearest-neighbor',
          'image-rendering': 'pixelated' }} />
      </Table.Cell>
      <Table.Cell bold>
        {data.item_name}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Box>
          {data.item_quantity}/{data.item_max_quantity}
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
      <Button
          fluid
          disabled={(
            data.item_quantity === 0
          )}
          content={'Dispense'}
          onClick={() => act('dispense', {
            itemPath: data.item_type_path,
          })} />
      </Table.Cell>
    </Table.Row>
  );
};

const IceCreamRow = (props, context) => {
  const { act, data } = useBackend<IceCreamStats>(context);

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <Box
        as="img"
        src={resolveAsset(data.item_image)}
        height="96px"
        style={{
          '-ms-interpolation-mode': 'nearest-neighbor',
          'image-rendering': 'pixelated' }} />
      </Table.Cell>
      <Table.Cell bold>
        {data.item_name}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Box>
          {data.item_quantity}/{data.item_max_quantity}
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Button
          fluid
          disabled={(
            data.item_quantity === 0
          )}
          content={'Select'}
          onClick={() => act('select', {
            itemPath: data.item_type_path,
          })} />
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
      <Button
          fluid
          disabled={(
            data.item_quantity === 0
          )}
          content={'Dispense'}
          onClick={() => act('dispense', {
            itemPath: data.item_type_path,
          })} />
      </Table.Cell>
    </Table.Row>
  );
};
