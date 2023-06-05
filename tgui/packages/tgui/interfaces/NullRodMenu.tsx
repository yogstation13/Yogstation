import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, Tabs, Stack, Box, TextArea } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

type Data = {
  categories: Category[];
};

type Category = {
  name: string;
  nullrods: NullRod[];
};

type NullRod = {
  name: string;
  description: string;
  additional_description: string;
  menu_tab: string;
  rod_pic: string;
  type_path: string;
};

export const NullRodMenu = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [selectedRod] = useLocalState<NullRod | null>(context, "rod", null);

  return (
    <Window width={650} height={500} resizable>
      <Window.Content>
        <Stack
          m={1}
          fill>

          <Stack.Item grow={1} overflowY="auto">
            <RodTabs />
          </Stack.Item>

          <Stack.Item grow={1}>
            <Stack fill fluid direction="column">
              <Stack.Item >
                <RodPreview />
              </Stack.Item>
              <Stack.Item>
              {selectedRod && (
                <Button
                icon="hands-praying"
                content="Confirm your choice"
                textAlign="center"
                fontSize="16px"
                fluid
                color="green"
                onClick={() => act("confirm", {
                rodPath: selectedRod.type_path,
                })}
              />
              )}

              </Stack.Item>
            </Stack>

          </Stack.Item>
        </Stack>

      </Window.Content>
    </Window>
  );
};

const RodTabs = (props, context) => {
  const { data } = useBackend<Data>(context);

  const { categories = [] } = data;
  const [selectedCategory, setSelectedCategory] = useLocalState<Category>(
    context,
    'category',
    categories[0]
  );

  const [selectedRod, setSelectedRod] = useLocalState<NullRod | null>(context, "rod", null);

  return (
    <Section>

      <Tabs >
        {categories.map(category => (
          <Tabs.Tab
            key={category}
            selected={category === selectedCategory}
            onClick={() => setSelectedCategory(category)}>
            {capitalize(category.name)}
          </Tabs.Tab>
        ))}
      </Tabs>
      <Tabs vertical >
        {Object.entries(selectedCategory.nullrods).map(([rod, rodObject]) => (
          <Tabs.Tab
            key={rod}
            Autofocus
            selected={rodObject === selectedRod}
            onClick={() => setSelectedRod(rodObject)}>
            {capitalize(rodObject.name)}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

const RodPreview = (props, context) => {

  const [selectedRod] = useLocalState<NullRod | null>(context, "rod", null);

  if(selectedRod!==null) {
    return (
      <Section overflow-wrap="break-word" fill title={capitalize(selectedRod?.name)}>
        <Stack fill fluid vertical justify="flex-start" fontSize="16px" textAlign="center">

          <Stack.Item color="gold">{selectedRod?.description}</Stack.Item>

          <Stack.Item>
            <Box
            as="img"
            src={resolveAsset(selectedRod.rod_pic)}
            height="96px"
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
              'image-rendering': 'pixelated' }} />
          </Stack.Item>

          <Stack.Item fontSize="12px" color="lightblue">{selectedRod?.additional_description}</Stack.Item>

        </Stack>
      </Section>
      );
  }else{
    return(
      <Section overflow-wrap="break-word" fill fluid>
        <Stack vertical fontSize="16px" align="center" height="50px" textAlign="center">

          <Stack.Item width="100%" color="gold">Choose your implement of righteousness</Stack.Item>

        </Stack>
      </Section>
    );
  }
};
