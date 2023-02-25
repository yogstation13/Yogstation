import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, Tabs } from '../components';
import { Window } from '../layouts';

const MENU_ALL = "all";
const MENU_WEAPON = "weapons"; // standard weapons
const MENU_ARM = "arms"; // things that replace the arm
const MENU_CLOTHING = "clothing"; // things that can be worn
const MENU_MISC = "misc"; // anything that doesn't quite fit into the other categories

type Data = {
  categories: Category[];
  nullrods: NullRod[];
}

type Category = {
  name: string;
};

type NullRod = {
  name: string;
  description: string;
  menu_tab: string;
  rod_pic: string;
};

export const NullRodMenu = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    categories,
    nullrods,
  } = data;

  const [selectedCategory, setSelectedCategory] = useLocalState<string>(
    context,
    'category',
    data.categories[0]?.name
  );

  const choices = nullrods.find(rod => rod.menu_tab === selectedCategory);
  return (
    <Window width={400} height={500} resizable>
      <Window.Content scrollable>
        <Section title="Nullrod">
          <LabeledList>
            {nullrods.map}
            {/* <LabeledList.Item label="Name">
              {categories?.nullrod_weapons?.[1]?.name}
            </LabeledList.Item>
            <LabeledList.Item label="Desc">
              {categories?.nullrod_weapons?.[1]?.desc}
            </LabeledList.Item>
            <LabeledList.Item label="Button">
              <Button
                content="Dispatch a 'test' action"
                onClick={() => act('test')} />
            </LabeledList.Item> */}
            <Tabs fluid>
              {categories.map((category) => (
                <Tabs.Tab
                  align="center"
                  key={category.name}
                  selected={category.name === selectedCategory}
                  onClick={() => setSelectedCategory(category.name)}>
                  {category.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </LabeledList>
        </Section>

      </Window.Content>
    </Window>
  );
};

const RodTabs = (props, context) => {
  const { data } = useBackend(context);

  const { rod_list = [] } = data;
  const [selectedCategory, setSelectedCategory] = useLocalState<string>(
    context,
    'category',
    data.categories[0]?.name
  );
  return (
    <Tabs vertical>
      {rod_list.map(fish => (
        <Tabs.Tab
          key={fish}
          selected={fish === selectedFish}
          onClick={() => setSelectedFish(fish)}>
          {fish.name}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
