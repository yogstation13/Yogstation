import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Table, Tabs, Box, TextArea, Stack } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

//Store data for cones and scoops within Data
type Data = {
  tabs: Tab[];
}

type Tab = {
  cones: ConeStats[];
  ice_cream: IceCreamStats[];
  info_tab: InformationStats[];
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

//Stats for info tab
type InformationStats = {
  section_title: string;
  section_content: string;
}

export const IceCreamVat = (props, context) => {
  const { data } = useBackend<Data>(context)

  const [ selectedMainTab, setMainTab ] = useLocalState(context, 'selectedMainTab', 0);

  return(
    //Create window for ui
    <Window width={620} height={600} resizable>
      {/* Add constants to window and make it scrollable */}
      <Window.Content
        scrollable>
          <Tabs fluid>
            <Tabs.Tab
              icon="ice-cream"
              selected={selectedMainTab === 0}
              onClick={() => setMainTab(0)}>
              Vat
            </Tabs.Tab>
            <Tabs.Tab
              icon="info"
              selected={selectedMainTab === 1}
              onClick={() => setMainTab(1)}>
              Information
            </Tabs.Tab>
          </Tabs>
          {selectedMainTab == 0 && <VatTab/>}
          {selectedMainTab == 1 && <InfoTab/>}
      </Window.Content>
    </Window>
  );
};

const ConeRow = (props, context) => {
  //Get data from ui_data in backend code
  const { act, data } = useBackend<Tab>(context);
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
  const { act, data } = useBackend<Tab>(context);
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

const InfoRow = (props, context) => {
  //Get data from ui_data in backend code
  const { data } = useBackend<Tab>(context);

  //Get data from tab
  const[infoContent] = useLocalState<InformationStats | null>(context, "info", null);

  if(infoContent!==null) {
    return (
      <Section>
        infoContent.section_content
      </Section>
    );
  }
};

const VatTab = (props, context) => {

  //For organizing the vat tab's information
  return (
  <Stack vertical>
    <Stack.Item>
      <Section title="Cones">
        <ConeRow/>
      </Section>
    </Stack.Item>
    <Stack.Item>
      <Section title="Scoops">
        <IceCreamRow/>
      </Section>
    </Stack.Item>
  </Stack>
  );
};

const InfoTab = (props, context) => {
  //Get data from ui_data in backend code
  const { data } = useBackend<Tab>(context);

  //Get info_tab information from data
  const { info_tab = [] } = data;
  const [ selectedInfoTab, setInfoTab ] = useLocalState(context, 'selectedInfoTab', "Vat Instructions");

  //Make a constant for storing the seleted tab's information
  const[infoContent] = useLocalState<InformationStats | null>(context, "info", null);

  return (
      <Tabs vertical>
        {info_tab.map(information => (
        <Tabs.Tab
        key={information.section_title}
        selected={information.section_title === selectedInfoTab}
        onClick={() => setInfoTab(information.section_title)}>
          {information.section_title}
        </Tabs.Tab>
         ))}
      </Tabs>
  );
};
