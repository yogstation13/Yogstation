import { storage } from 'common/storage';
import { capitalize } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Table, Tabs, Box, TextArea, Stack, Tooltip, Flex, ProgressBar } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

// Store data for UI elements within Data
type Data = {
  food: FoodStats[];
  mainDrinks: MainDrinkStats[];
  mixerDrinks: MixerDrinkStats[];
  storage: StorageStats;
}

// Stats for food item
type FoodStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
}

// Stats for reagents in cart's reagent holder
type MainDrinkStats = {
  drink_name: string;
  drink_quantity: number;
  drink_type_path: string;
}

// Stats for reagents in mixer's reagent holder
type MixerDrinkStats = {
  drink_name: string;
  drink_quantity: number;
  drink_type_path: string;
}

// Stats for all storage information
type StorageStats = {
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
  const { act, data } = useBackend<Data>(context);
  // Get food information from data
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
            Food Storage Empty
          </Table.Cell>
        </Table.Row>
      </Table>
    );
  }
};

const DrinkTab = (props, context) => {
  // For organizing the food tab's information
  return (
    <Stack vertical>
      <Stack.Item>
        <Flex
        justify="center">
          <Flex.Item
          grow={1}
          mr={1}>
            <Section
            title="Glass Storage"
            textAlign="center">
              <GlassRow />
            </Section>
          </Flex.Item>
          <Flex.Item
          grow={1}
          mr={1}>
            <Section
            title="Drink Capacity"
            textAlign="center">
              <DrinkCapacityRow />
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
          icon="info"/>}
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
          tooltip="Main reagent storage for the cart"
          icon="info"/>}>
          <MainDrinkRow />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
        title="Cart Mixer Storage"
        textAlign="center"
        buttons={<Button
          circular
          tooltip="Reagents to be poured into drinking glasses"
          icon="info"/>}>
          <MixerDrinkRow />
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const GlassRow = (props, context) => {
  // Get data from ui_data in backend code
  const { data } = useBackend<StorageStats>(context);
  // Get needed variables from StorageStats
  const { glass_quantity } = data;
  const { glass_capacity } = data;

  return (
    <Table>
      <Table.Row>
        <Table.Cell
        fontSize="14px"
        textAlign="center"
        bold>
          {glass_quantity}/{glass_capacity}
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};

const DrinkCapacityRow = (props, context) => {
  // Get data from ui_data in backend code
  const { data } = useBackend<StorageStats>(context);
  // Get needed variables from StorageStats
  const { drink_quantity } = data;
  const { drink_capacity } = data;

  return (
    <Table>
    <Table.Row>
      <Table.Cell
      fontSize="14px"
      textAlign="center"
      bold>
        {drink_quantity}/{drink_capacity}
      </Table.Cell>
    </Table.Row>
  </Table>
  );
}

const DrinkTransferRow = (props, context) => {
  // Get data from ui_data in backend code
  const { act, data } = useBackend<StorageStats>(context);
  // Get data for buttons
  const { dispence_options = [] } = data;
  const { dispence_selected } = data;

  return(
    <Flex
    justify="center">
      {dispence_options.map(amount => (
        <Flex.Item
        grow={1}
        mr={0.5}>
          <Button
            key={amount}
            fluid
            content={amount}
            textAlign="center"
            selected={amount === dispence_selected}
            onClick={() => act("transferNum", {
              dispenceAmount: amount,
            })}/>
        </Flex.Item>
      ))}
    </Flex>
  );

}

const MainDrinkRow = (props, context) => {
  // Get data from ui_data in backend code
  const { act, data } = useBackend<Data>(context);
  // Get drink information for cart's container from data
  const { mainDrinks = [] } = data;

  if(mainDrinks.length > 0) {
    return (
      // Create Table for horizontal format
      <Table>
        {/* Use map to create dynamic rows based on the contents of drinks, with drink being the individual item and its stats */}
        {mainDrinks.map(reagent => (
          // Start row for holding ui elements and given data
          <Table.Row
          key={reagent.drink_name}
          fontSize="14px"
          height="30px">
              <Table.Cell
              width="150px"
              bold>
                {/* Get name */}
                {capitalize(reagent.drink_name)}
              </Table.Cell>
              <Table.Cell>
                <ProgressBar
                value={reagent.drink_quantity/200}>
                  {reagent.drink_quantity}u
                </ProgressBar>
              </Table.Cell>
              <Table.Cell
              // Limit width for
              width="75px">
                {/* Remove from cart storage */}
                <Button
                fluid
                color="red"
                content="Purge"
                textAlign="center"
                fontSize="16px"
                // Disable if there is none of the reagent in storage
                disabled={(
                  reagent.drink_quantity === 0
                )}
                onClick={() => act("purge", {
                  itemPath: reagent.drink_type_path,
                })}
                />
              </Table.Cell>
              <Table.Cell
              width="125px">
                {/* Move to mixer */}
                <Button
                fluid
                content="Add to Mixer"
                textAlign="center"
                fontSize="16px"
                // Dissable if there is none of the reagent in storage
                disabled={(
                  reagent.drink_quantity === 0
                )}
                onClick={() => act("addMixer", {
                  itemPath: reagent.drink_type_path,
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
      // Create Table for horizontal format
      <Table>
        {/* Use map to create dynamic rows based on the contents of drinks, with drink being the individual item and its stats */}
        {mixerDrinks.map(reagent => (
          // Start row for holding ui elements and given data
          <Table.Row
          key={reagent.drink_name}
          fontSize="14px"
          height="30px">
            <Table.Cell
            bold
            width="150px">
              {/* Get name */}
               {capitalize(reagent.drink_name)}
            </Table.Cell>
            <Table.Cell>
                <ProgressBar
                value={reagent.drink_quantity/50}>
                  {reagent.drink_quantity}u
                </ProgressBar>
              </Table.Cell>
            <Table.Cell>
              {/* Transfer reagents back to cart */}
              <Button
              content="Transfer Back"
              textAlign="center"
              fontSize="16px"
              width="150px"
              // Disable if there is none of the reagent in storage
              disabled={(
                reagent.drink_quantity === 0
              )}
              onClick={() => act("transferBack", {
                itemPath: reagent.drink_type_path,
              })}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      <Table.Row>
         <Table.Cell
         justify="center">
          {/* Dispence reagents into glass */}
           <Button
            content="Pour glass"
            textAlign="center"
            fontSize="16px"
            width="100%"
            onClick={() => act("pour")}
            />
          </Table.Cell>
        </Table.Row>
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
            Mixer Storage Empty
          </Table.Cell>
        </Table.Row>
      </Table>
    );
  }
};

const MixerDrinkRow1 = (props, context) => {
  // Get data from ui_data in backend code
  const { act, data } = useBackend<Data>(context);
  // Get drink information for cart's container from data
  const { mixerDrinks = [] } = data;

  if(mixerDrinks.length > 0) {
    return (
      // Create Table for horizontal format
      <Stack
      direction="column"
      justify="space-around"
      fontSize="14px">
      {/* Use map to create dynamic rows based on the contents of drinks, with drink being the individual item and its stats */}
        {mixerDrinks.map(reagent => (
          // Start row for holding ui elements and given data
          <Stack
            key={reagent.drink_name}
            direction="row"
            justify="space-around"
            fill>
            <Stack.Item
            bold
            align="right">
              {/* Get name */}
              {capitalize(reagent.drink_name)}
            </Stack.Item>
            <Stack.Item>
              {/* Get amount of reagent in storage */}
              {reagent.drink_quantity}u
            </Stack.Item>
            <Stack.Item
            justify="left">
              {/* Make dispense button */}
              <Button
              fluid
              content="Transfer Back"
              fontSize="16px"
              // Disable if there is none of the reagent in storage
              disabled={(
                reagent.drink_quantity === 0
              )}
              onClick={() => act("transferBack", {
                itemPath: reagent.drink_type_path,
              })}
              />
            </Stack.Item>
          </Stack>
        ))}
        <Stack.Item>
          <Button
          fluid
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
}
