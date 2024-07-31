import { capitalize } from 'common/string';
import { useBackend } from '../backend';
import { Button, Section, Table, Tabs, Box, TextArea,  } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

//Store data for cones and scoops within Data
type Data = {
  cones: ConeStats[];
  ice_cream: IceCreamStats[];
}

//Stats specific for scoops
type IceCreamStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
  selected_item: string;
}

//Stats specific for cones
type ConeStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
  selected_item: string;
}

export const IceCreamVat = (props, context) => {

  return(
    //Create window for ui
    <Window width={620} height={600} resizable>
      {/* Add constants to window and make it scrollable */}
      <Window.Content
        scrollable>
        {/* Add in rows for cones */}
        <Section title="Cones">
          <ConeRow/>
        </Section>
        {/* Add in rows for scoops */}
        <Section title="Scoops">
          <IceCreamRow/>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ConeRow = (props, context) => {
  //Get data from ui_data in backend code
  const { act, data } = useBackend<Data>(context);
  //Get cones information from data
  const { cones = [] } = data;

  return (
    //Create Table for horizontal format
    <Table>
      {/* Use map to create dynamic rows based on the contents of cones, with flavor being the individual item and its stats */}
      {cones.map(flavor => (
        //Start row for holding ui elements and given data
        <Table.Row
         key={flavor.item_name}
         fontSize="14px">
            <Table.Cell>
            {/* Get image and then add it to the ui */}
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
              {/* Get name */}
              {capitalize(flavor.item_name)}
            </Table.Cell>
            <Table.Cell
              textAlign="right">
              {/* Get amount of item in storage */}
              {flavor.item_quantity} in storage
            </Table.Cell>
            <Table.Cell>
            {/* Make select button */}
            <Button
            fluid
            content="Select"
            textAlign="center"
            fontSize="16px"
            //Make the button green if the row's item's type path matches the selected item's type path
            selected={flavor.selected_item === flavor.item_type_path}
            onClick={() => act("select", {
            itemPath: flavor.item_type_path,
            })}
            />
            {/* Make dispense button */}
            <Button
            fluid
            content="Dispense"
            textAlign="center"
            fontSize="16px"
            //Dissable if there is none of the item in storage
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
  //Get data from ui_data in backend code
  const { act, data } = useBackend<Data>(context);
  //Get ice_cream information from data
  const { ice_cream = [] } = data;

  return (
    //Create Table for horizontal format
    <Table>
      {/* Use map to create dynamic rows based on the contents of ice_cream, with flavor being the individual item and its stats */}
      {ice_cream.map(flavor => (
        //Start row for holding ui elements and given data
        <Table.Row
         key={flavor.item_name}
         fontSize="14px">
            <Table.Cell>
              {/* Get image and then add it to the ui */}
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
              {/* Get name */}
              {capitalize(flavor.item_name)}
            </Table.Cell>
            <Table.Cell
              textAlign="right">
              {/* Get amount of item in storage */}
              {flavor.item_quantity} in storage
            </Table.Cell>
            {/* Make select button */}
            <Table.Cell>
            <Button
            fluid
            content="Select"
            textAlign="center"
            fontSize="16px"
            //Make the button green if the row's item's type path matches the selected item's type path
            selected={flavor.selected_item === flavor.item_type_path}
            onClick={() => act("select", {
            itemPath: flavor.item_type_path,
            })}
            />
            {/* Make dispense button */}
            <Button
            fluid
            content="Dispense"
            textAlign="center"
            fontSize="16px"
            //Dissable if there is none of the item in storage
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
