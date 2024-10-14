import { storage } from 'common/storage';
import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Table, Tabs, Box, TextArea, Stack } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

// Store data for cones and scoops within Data
type Data = {
  tabs: Tab[];
}

type Tab = {
  cones: ConeStats[];
  ice_cream: IceCreamStats[];
  storage: StorageStats[];
  info_tab: InformationStats[];
}

// Stats specific for scoops
type IceCreamStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
  selected_item: string;
}

// Stats specific for cones
type ConeStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
  selected_item: string;
}

// Stats for info tab
type InformationStats = {
  section_title: string;
  section_text: string;
}

type StorageStats = {
  contents_length: number;
  storage_capacity: number;
}

export const IceCreamVat = (props, context) => {
  // Get information from backend code
  const { data } = useBackend<Data>(context);
  // Make a variable for storing a number that represents the current selected tab
  const [selectedMainTab, setMainTab] = useLocalState(context, 'selectedMainTab', 0);

  return(
    // Create window for ui
    <Window width={620} height={600} resizable>
      {/* Add constants to window and make it scrollable */}
      <Window.Content
        scrollable>
          {/* Create tabs for the vat and information tabs */}
          <Tabs fluid>
            <Tabs.Tab
              icon="ice-cream"
              bold
              // Show the vat tab when the selectedMainTab is 0
              selected={selectedMainTab === 0}
              // Set selectedMainTab to 0 when the vat tab is clicked
              onClick={() => setMainTab(0)}>
              {/* Put 'Vat' in the tab to differentiate it from other tabs */}
              Vat
            </Tabs.Tab>
            <Tabs.Tab
              icon="info"
              bold
              // Show the information tab when the selectedMainTab is 1
              selected={selectedMainTab === 1}
              // Set selectedMainTab to 1 when the information tab is clicked
              onClick={() => setMainTab(1)}>
              {/* Put 'Information' in the tab to differentiate it from other tabs */}
              Information
            </Tabs.Tab>
          </Tabs>
          {/* If selectedMainTab is 0, show the UI elements in VatTab */}
          {selectedMainTab === 0 && <VatTab />}
          {/* If selectedMainTab is 1, show the UI elements in InfoTab */}
          {selectedMainTab === 1 && <InfoTab />}
      </Window.Content>
    </Window>
  );
};

const ConeRow = (props, context) => {
  // Get data from ui_data in backend code
  const { act, data } = useBackend<Tab>(context);
  // Get cones information from data
  const { cones = [] } = data;

  return (
    // Create Table for horizontal format
    <Table>
      {/* Use map to create dynamic rows based on the contents of cones, with flavor being the individual item and its stats */}
      {cones.map(flavor => (
        // Start row for holding ui elements and given data
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
            // Make the button green if the row's item's type path matches the selected item's type path
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
            // Dissable if there is none of the item in storage
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
  // Get data from ui_data in backend code
  const { act, data } = useBackend<Tab>(context);
  // Get ice_cream information from data
  const { ice_cream = [] } = data;

  return (
    // Create Table for horizontal format
    <Table>
      {/* Use map to create dynamic rows based on the contents of ice_cream, with flavor being the individual item and its stats */}
      {ice_cream.map(flavor => (
        // Start row for holding ui elements and given data
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
            // Make the button green if the row's item's type path matches the selected item's type path
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
            // Dissable if there is none of the item in storage
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

const InfoContentRow = (props, context) => {
  // Get data from ui_data in backend code
  const { data } = useBackend<Tab>(context);
  // Get info_tab information from data
  const { info_tab = [] } = data;
  // Make constant that starts with the section_text of the first element of info_tab and which will recieve new data from InfoTab
  const[infoContent] = useLocalState(context, 'selectedInfoTab', info_tab[0].section_text);

  // Return a section with the vat's contents and capacity
  return (
      <Section
      fontSize="16px">
        {infoContent}
      </Section>
    );
};

const CapacityRow = (props, context) => {
  // Get data from ui_data in backend code
  const { data } = useBackend<StorageStats>(context);
  // Get needed variables from StorageStats
  const { contents_length } = data;
  const { storage_capacity } = data;

  // Return a section with the tab's section_text
  return(
  <Table>
    <Table.Row>
      <Table.Cell
      fontSize="14px"
      textAlign="center"
      bold>
        {/* Show the vat's current contents and its max contents */}
        {contents_length}/{storage_capacity}
      </Table.Cell>
    </Table.Row>
  </Table>
  );
};

const VatTab = (props, context) => {

  // For organizing the vat tab's information
  return (
  <Stack vertical>
    <Stack.Item>
      <Section
      title="Storage Capacity"
      textAlign="center">
        <CapacityRow />
      </Section>
    </Stack.Item>
    <Stack.Item>
      <Section
      title="Cones"
      textAlign="center">
        <ConeRow />
      </Section>
    </Stack.Item>
    <Stack.Item>
      <Section
      title="Scoops"
      textAlign="center">
        <IceCreamRow />
      </Section>
    </Stack.Item>
  </Stack>
  );
};

const InfoTab = (props, context) => {
  // Get data from ui_data in backend code
  const { data } = useBackend<Tab>(context);
  // Get info_tab information from data
  const { info_tab = [] } = data;
  // Make constant that starts with the section_text of the first element of info_tab and which can send new data to InfoContentRow
  const [selectedInfoTab, setInfoTab] = useLocalState(context, 'selectedInfoTab', info_tab[0].section_text);

  // Return organized elements for the main UI
  return (
    // Stack them for appealing layout
    <Stack>
        <Stack.Item>
          {/* Start tabs and make them vertical */}
          <Tabs vertical>
            {/* Use map to allow for dynamic tabs */}
            {info_tab.map(information => (
            // Create new tab based on current info_tab element
            <Tabs.Tab
            bold
            key={information.section_title}
            // A tab is selected when the current element's section_text equals the value of selectedInfoTab
            selected={information.section_text === selectedInfoTab}
            // When clicked, selectedInfoTab will be set to the clicked tab's section_text
            onClick={() => setInfoTab(information.section_text)}>
              {/* Put the section_title in the tab to differentiate it from other tabs */}
              {information.section_title}
            </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        {/* Show the section_text stored in selectedInfotab */}
        <Stack.Item>
          <InfoContentRow />
        </Stack.Item>
    </Stack>
  );
};
