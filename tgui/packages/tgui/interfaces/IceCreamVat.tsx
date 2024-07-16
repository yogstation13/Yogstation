import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, Tabs, Table, Box, TextArea } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

type VatData = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_max_quantity: number;
  item_type_path: string;
};

const VatRow = (props, context) => {
  const { act, data } = useBackend<VatData>(context);

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
          content={'Dispence'}
          onClick={() => act('dispence', {
            itemPath: data.item_type_path,
          })} />
      </Table.Cell>
    </Table.Row>
  )
};
