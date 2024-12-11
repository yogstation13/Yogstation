import { storage } from 'common/storage';
import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Table, Tabs, Box, TextArea, Stack, Tooltip } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

// Store data for cones and scoops within Data
type Data = {
  tabs: Tab[];
}

type Tab = {
  food: FoodStats[];
  storage: StorageStats[];
}

// Stats for food item
type FoodStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
  selected_item: string;
}

type StorageStats = {
  contents_length: number;
  storage_capacity: number;
}

export const FoodCart = (props, context) => {
  // Get information from backend code
  const { data } = useBackend<Data>(context);
  // Make a variable for storing a number that represents the current selected tab
  const [selectedMainTab, setMainTab] = useLocalState(context, 'selectedMainTab', 0);

  return(
    // Create window for ui
    <Window width={620} height={500} resizable>
      {/* Add constants to window and make it scrollable */}
      <Window.Content
        scrollable>
          {/* Create tabs for better organization */}
          <Tabs fluid>
            <Tabs.Tab
              icon="burger"
              bold
              // Show the food tab when the selectedMainTab is 0
              selected={selectedMainTab === 0}
              // Set selectedMainTab to 0 when the food tab is clicked
              onClick={() => setMainTab(0)}>
              {/* Put 'Food' in the tab to differentiate it from other tabs */}
              Food
            </Tabs.Tab>
          </Tabs>
          {/* If selectedMainTab is 0, show the UI elements in FoodTab */}
          {selectedMainTab === 0 && <FoodTab />}
      </Window.Content>
    </Window>
  );
};

const FoodTab = (props, context) => {

  // For organizing the food tab's information
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
      title="Food Selection"
      textAlign="center">
        <FoodRow />
      </Section>
    </Stack.Item>
  </Stack>
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

const FoodRow = (props, context) => {
  // Get data from ui_data in backend code
  const { act, data } = useBackend<Tab>(context);
  // Get cones information from data
  const { food = [] } = data;

  if(food.length > 0) {
    return (
      // Create Table for horizontal format
      <Table>
        {/* Use map to create dynamic rows based on the contents of food, with item being the individual item and its stats */}
        {food.map(item => (
          // Start row for holding ui elements and given data
          <Table.Row
          key={item.item_name}
          fontSize="14px">
              <Table.Cell>
              {/* Get image and then add it to the ui */}
                <Box
                as="img"
                src={resolveAsset(item.item_image)}
                height="32px"
                style={{
                  '-ms-interpolation-mode': 'nearest-neighbor',
                  'image-rendering': 'pixelated' }} />
              </Table.Cell>
              <Table.Cell
                bold>
                {/* Get name */}
                {capitalize(item.item_name)}
              </Table.Cell>
              <Table.Cell
                textAlign="right">
                {/* Get amount of item in storage */}
                {item.item_quantity} in storage
              </Table.Cell>
              <Table.Cell>
              {/* Make dispense button */}
              <Button
              fluid
              content="Dispense"
              textAlign="center"
              fontSize="16px"
              // Dissable if there is none of the item in storage
              disabled={(
                item.item_quantity === 0
              )}
              onClick={() => act("dispense", {
              itemPath: item.item_type_path,
              })}
              />
              </Table.Cell>
          </Table.Row>
      ))}
      </Table>
    );
  } else {
    return (
      <Table>
        <Table.Row>
          <Table.Cell
          fontSize="14px"
          textAlign="center"
          bold>
            Put something in you daft fool!
          </Table.Cell>
        </Table.Row>
      </Table>
    );
  }
};
