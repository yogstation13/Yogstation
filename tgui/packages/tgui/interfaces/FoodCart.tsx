import { capitalize } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Table, Tabs, Box, TextArea, Stack, Tooltip, Flex, ProgressBar } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

// Store data for UI elements within Data
type Data = {
  food: FoodData[];
  mainDrinks: DrinkData[];
  mixerDrinks: MixerDrinkData[];
  storage: StorageData;
}

// Data for food item
type FoodData = {
  image: string;
  name: string;
  quantity: number;
  type_path: string;
}

// Data for reagents in cart's reagent holder
type DrinkData = {
  name: string;
  quantity: number;
  type_path: string;
}

// Data for reagents in mixer's reagent holder
type MixerDrinkData = {
  name: string;
  quantity: number;
  type_path: string;
}

// Data for all storage information
// Thanks bug eating lizard and Obelisk for helping me figure out how to reference this correctly
type StorageData = {
  contents_length: number;
  storage_capacity: number;
  glass_quantity: number;
  glass_capacity: number;
  drink_quantity: number;
  drink_capacity: number;
  dispence_options: number[];
  dispence_selected: number;
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
              Food
            </Tabs.Tab>
            <Tabs.Tab
            icon="glass-martini"
            bold
            // Show the drink tab when the selectedMainTab is 1
            selected={selectedMainTab === 1}
            // Set selectedMainTab to 0 when the food tab is clicked
            onClick={() => setMainTab(1)}>
              Drinks
            </Tabs.Tab>
          </Tabs>
          {/* If selectedMainTab is 0, show the UI elements in FoodTab */}
          {selectedMainTab === 0 && <FoodTab />}
          {selectedMainTab === 1 && <DrinkTab />}
      </Window.Content>
    </Window>
  );
};

const FoodTab = (props, context) => {
    // Get data from ui_data in backend code
    const { data } = useBackend<Data>(context);
    // Get needed variable for StorageRow
    const { storage } = data;

  // For organizing the food tab's information
  return (
  <Stack vertical>
    <Stack.Item>
      <Section
      title="Food Capacity"
      textAlign="center">
        <StorageRow
        quantity={storage.contents_length}
        capacity={storage.storage_capacity} />
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

const StorageRow = (props, context) => {
  // Make constants for input
  const { quantity } = props;
  const { capacity } = props;

   return(
    <Table>
      <Table.Row>
        <Table.Cell
        fontSize="14px"
        textAlign="center"
        bold>
          {/* Show numbers based on recieved arguments */}
          {quantity}/{capacity}
        </Table.Cell>
      </Table.Row>
    </Table>
    );
};

const FoodRow = (props, context) => {
  // Get data from ui_data in backend code
  const { act, data } = useBackend<Data>(context);
  // Get food information from data
  const { food = [] } = data;

  if(food.length > 0) {
    return (
      // Create Table for horizontal format
      <Table>
        {/* Use map to create dynamic rows based on the contents of food, with item being the individual item and its data */}
        {food.map(item => (
          // Start row for holding ui elements and given data
          <Table.Row
          key={item.name}
          fontSize="14px">
              <Table.Cell>
              {/* Get image and then add it to the ui */}
                <Box
                as="img"
                src={`data:image/jpeg;base64,${item.image}`}
                height="32px"
                style={{
                  '-ms-interpolation-mode': 'nearest-neighbor',
                  'image-rendering': 'pixelated' }} />
              </Table.Cell>
              <Table.Cell
                bold>
                {/* Get name */}
                {capitalize(item.name)}
              </Table.Cell>
              <Table.Cell
                textAlign="right">
                {/* Get amount of item in storage */}
                {item.quantity} in storage
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
                item.quantity === 0
              )}
              onClick={() => act("dispense", {
                itemPath: item.type_path,
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
            Food Storage Empty
          </Table.Cell>
        </Table.Row>
      </Table>
    );
  }
};

const DrinkTab = (props, context) => {
  // Get data from ui_data in backend code
  const { data } = useBackend<Data>(context);
  // Get needed variable for StorageRow
  const { storage } = data;

  // For organizing the Drink tab's information
  return (
    <Stack vertical>
      <Stack.Item>
        <Flex>
          <Flex.Item
          grow
          mr={1}>
            <Section
            title="Glass Storage"
            textAlign="center">
              <StorageRow
              quantity={storage.glass_quantity}
              capacity={storage.glass_capacity} />
            </Section>
          </Flex.Item>
          <Flex.Item
          grow>
            <Section
            title="Drink Capacity"
            textAlign="center">
              <StorageRow
              quantity={storage.drink_quantity}
              capacity={storage.drink_capacity} />
            </Section>
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item>
        <Section
        title="Transfer Amount"
        textAlign="center"
        buttons={<Button
          circular
          tooltip="Amount of reagents to be transfered or purged"
          icon="info" />}
        >
          <DrinkTransferRow />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
        title="Cart Drink Storage"
        textAlign="center"
        buttons={<Button
          circular
          tooltip="Main reagent storage for the cart. Reagents do not react while in it"
          icon="info" />}>
          <MainDrinkRow />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
        title="Cart Mixer Storage"
        textAlign="center"
        buttons={<Button
          circular
          tooltip="Reagents to be poured into drinking glasses. Reagents do not react while in it and will instead react when poured"
          icon="info" />}>
          <MixerDrinkRow />
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DrinkTransferRow = (props, context) => {
  // Get data from ui_data in backend code
  const { act, data } = useBackend<Data>(context);
  // Get data for buttons
  const { storage } = data;
  const { dispence_options = [] } = storage;
  const { dispence_selected } = storage;

  return(
    <Flex
    justify="center">
      {dispence_options.map(amount => (
        <Flex.Item
        key={amount}
        grow
        mr={0.5}>
          <Button
            fluid
            content={amount}
            textAlign="center"
            selected={amount === dispence_selected}
            onClick={() => act("transferNum", {
              dispenceAmount: amount,
            })} />
        </Flex.Item>
      ))}
    </Flex>
  );

};

const MainDrinkRow = (props, context) => {
  // Get data from ui_data in backend code
  const { act, data } = useBackend<Data>(context);
  // Get drink information for cart's container from data
  const { mainDrinks = [] } = data;
  const { drink_capacity } = data.storage;

  if(mainDrinks.length > 0) {
    return (
      // Create Stack and use vertical property for horizontal format
      <Stack
      fontSize="14px"
      vertical>
        {/* Use map to create dynamic rows based on the given array, with reagent being an individual index and its data */}
        {mainDrinks.map(reagent => (
          // Start a new stack for holding ui elements and given data
          <Stack
          key={reagent.name}
          direction="row"
          justify="space-between"
          height="40px">
              <Stack.Item
              bold
              textAlign="left"
              width="25%">
                {/* Get reagent's name */}
                {capitalize(reagent.name)}
                {props.bold}
              </Stack.Item>
              <Stack.Item
              grow>
                <ProgressBar
                value={reagent.quantity/drink_capacity}>
                  {/* Get amount of reagent in storage */}
                  {reagent.quantity}u
                </ProgressBar>
              </Stack.Item>
              <Stack.Item
              width="75px">
                {/* Purge from cart's storage */}
                <Button
                fluid
                color="red"
                content="Purge"
                textAlign="center"
                fontSize="16px"
                // Disable if there is none of the reagent in storage
                disabled={(
                  reagent.quantity === 0
                )}
                onClick={() => act("purge", {
                  itemPath: reagent.type_path,
                })}
                />
              </Stack.Item>
              <Stack.Item
              width="125px">
                {/* Move to mixer's storage */}
                <Button
                fluid
                content="Add to Mixer"
                textAlign="center"
                fontSize="16px"
                // Dissable if there is none of the reagent in storage
                disabled={(
                  reagent.quantity === 0
                )}
                onClick={() => act("addMixer", {
                  itemPath: reagent.type_path,
                })}
                />
              </Stack.Item>
          </Stack>
      ))}
      </Stack>
    );
  } else {
    return (
      <Table>
        <Table.Row>
          <Table.Cell
          fontSize="14px"
          textAlign="center"
          bold>
            Drink Storage Empty
          </Table.Cell>
        </Table.Row>
      </Table>
    );
  }
};

const MixerDrinkRow = (props, context) => {
  // Get data from ui_data in backend code
  const { act, data } = useBackend<Data>(context);
  // Get drink information for cart's container from data
  const { mixerDrinks = [] } = data;

  if(mixerDrinks.length > 0) {
    return (
      // Create Stack and use vertical property for horizontal format
      <Stack
      fontSize="14px"
      vertical>
      {/* Use map to create dynamic rows based on the given array, with reagent being an individual index and its data */}
        {mixerDrinks.map(reagent => (
          // Start a new stack for holding ui elements and given data
          <Stack
            key={reagent.name}
            direction="row"
            justify="space-between"
            height="40px">
            <Stack.Item
            bold
            textAlign="left"
            width="25%">
              {/* Get reagent's name */}
              {capitalize(reagent.name)}
            </Stack.Item>
            <Stack.Item
            grow>
              <ProgressBar
              value={reagent.quantity/50}>
                {/* Get amount of reagent in storage */}
                {reagent.quantity}u
              </ProgressBar>
            </Stack.Item>
            <Stack.Item
            justify="left">
              {/* Transfer back to main storage */}
              <Button
              width="205px"
              content="Transfer Back"
              fontSize="16px"
              // Disable if there is none of the reagent in storage
              disabled={(
                reagent.quantity === 0
              )}
              onClick={() => act("transferBack", {
                itemPath: reagent.type_path,
              })}
              />
            </Stack.Item>
          </Stack>
        ))}
        {/* Pour a glass with all of mixer's reagents */}
        <Stack.Item>
          <Button
          fluid
          color="green"
          content="Pour glass"
          textAlign="center"
          fontSize="16px"
          onClick={() => act("pour")}
          />
        </Stack.Item>
      </Stack>
    );
  } else {
    return (
      <Table>
        <Table.Row>
          <Table.Cell
          fontSize="14px"
          textAlign="center"
          bold>
            Mixer Storage Empty
          </Table.Cell>
        </Table.Row>
      </Table>
    );
  }
};
