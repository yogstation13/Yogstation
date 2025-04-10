import { BooleanLike, classes } from 'common/react';
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Divider, Button, Section, Tabs, Stack, Box, Input, Icon, Tooltip, NoticeBox } from '../components';
import { Window } from '../layouts';
import { Food } from './PreferencesMenu/data';

const TYPE_ICONS = {
  'Can Make': 'utensils',
  [Food.Alcohol]: 'wine-glass',
  [Food.Breakfast]: 'sun',
  [Food.Cloth]: 'tshirt',
  [Food.Dairy]: 'cheese',
  [Food.Fried]: 'fire',
  [Food.Fruit]: 'apple-alt',
  [Food.Grain]: 'wheat-awn',
  [Food.Gross]: 'trash',
  [Food.Junkfood]: 'pizza-slice',
  [Food.Meat]: 'bacon',
  [Food.Nuts]: 'seedling',
  [Food.Pineapple]: 'apple-alt',
  [Food.Raw]: 'drumstick-bite',
  [Food.Seafood]: 'fish',
  [Food.Sugar]: 'candy-cane',
  [Food.Toxic]: 'biohazard',
  [Food.Vegetables]: 'carrot',
} as const;

const CATEGORY_ICONS_CRAFTING = {
  'Can Make': 'hammer',
  'Weapons: Melee': 'hand-fist',
  'Weapons: Ranged': 'gun',
  'Weapon Ammo': 'box',
  'Tools': 'screwdriver-wrench',
  'Robotics': 'robot',
  'Clothing': 'shirt',
  'Armor': 'universal-access',
  'Equipment': 'calculator',
  'Structures': 'cube',
  'Tribal': 'campground',
  'Fishing Bait': 'tint',
  'Medical': 'first-aid',
  'Misc': 'shapes',
} as const;

const CATEGORY_ICONS_COOKING = {
  'Can Make': 'utensils',
  'Breads': 'bread-slice',
  'Burgers': 'burger',
  'Cakes': 'cake-candles',
  'Egg-Based Food': 'egg',
  'Frozen': 'ice-cream',
  'Lizard Food': 'dragon',
  'Meats': 'bacon',
  'Misc. Food': 'shapes',
  'Pastries': 'cookie',
  'Pies': 'chart-pie',
  'Drinks': 'glass-martini',
  'Pizzas': 'pizza-slice',
  'Salads': 'leaf',
  'Sandwiches': 'hotdog',
  'Seafood': 'fish',
  'Soups': 'mug-hot',
  'Spaghettis': 'wheat-awn',
} as const;

enum MODE {
  crafting,
  cooking,
}

enum TABS {
  category,
  material,
  foodtype,
}

type AtomData = {
  name: string;
  is_reagent: BooleanLike;
};

type Atoms = {
  [key: number]: number;
};

type Material = {
  atom_id: string;
  occurences: number;
};

type Recipe = {
  ref: string;
  icon: string;
  name: string;
  desc: string;
  category: string;
  reqs: Atoms;
  tool_behaviors: string[];
  tool_paths: string[];
  skill_requirements: string[];
  foodtypes: string[];
};

type Skill = {
  skill: string;
  level: number;
};

type Diet = {
  liked_food: string[];
  disliked_food: string[];
  toxic_food: string[];
};

type Data = {
  // Dynamic
  busy: BooleanLike;
  mode: BooleanLike;
  forced_mode: BooleanLike;
  display_compact: BooleanLike;
  display_craftable_only: BooleanLike;
  craftability: Record<string, BooleanLike>;
  // Static
  diet: Diet;
  atom_data: AtomData[];
  recipes: Recipe[];
  categories: string[];
  material_occurences: Material[];
  foodtypes: string[];
  nutriments: number;
};

export const PersonalCrafting = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    mode,
    busy,
    forced_mode,
    display_compact,
    display_craftable_only,
    craftability,
    diet,
  } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [pages, setPages] = useLocalState(context, 'pages', 1);
  const DEFAULT_CAT_CRAFTING = Object.keys(CATEGORY_ICONS_CRAFTING)[1];
  const DEFAULT_CAT_COOKING = Object.keys(CATEGORY_ICONS_COOKING)[1];
  const [activeCategory, setCategory] = useLocalState<string>(
    context,
    'category',
    Object.keys(craftability).length
      ? 'Can Make'
      : mode === MODE.cooking
        ? DEFAULT_CAT_COOKING
        : DEFAULT_CAT_CRAFTING
  );
  const [activeType, setFoodType] = useLocalState(
    context,
    'foodtype',
    Object.keys(craftability).length ? 'Can Make' : data.foodtypes[0]
  );
  const material_occurences = flow([
    sortBy<Material>((material) => -material.occurences),
  ])(data.material_occurences);
  const [activeMaterial, setMaterial] = useLocalState(
    context,
    'material',
    material_occurences[0].atom_id
  );
  const [tabMode, setTabMode] = useLocalState(context, 'tabMode', 0);
  const searchName = createSearch(searchText, (item: Recipe) => item.name);
  let recipes = flow([
    filter<Recipe>(
      (recipe) =>
        // If craftable only is selected, then filter by craftability
        (!display_craftable_only || Boolean(craftability[recipe.ref])) &&
        // Ignore categories and types when searching
        (searchText.length > 0 ||
          // Is foodtype mode and the active type matches
          (tabMode === TABS.foodtype &&
            mode === MODE.cooking &&
            ((activeType === 'Can Make' && Boolean(craftability[recipe.ref])) ||
              recipe.foodtypes?.includes(activeType))) ||
          // Is material mode and the active material or catalysts match
          (tabMode === TABS.material &&
            Object.keys(recipe.reqs).includes(activeMaterial)) ||
          // Is category mode and the active categroy matches
          (tabMode === TABS.category &&
            ((activeCategory === 'Can Make' &&
              Boolean(craftability[recipe.ref])) ||
              recipe.category === activeCategory)))
    ),
    sortBy<Recipe>((recipe) => [
      -Number(craftability[recipe.ref]),
      recipe.name.toLowerCase(),
    ]),
  ])(data.recipes);
  if (searchText.length > 0) {
    recipes = recipes.filter(searchName);
  }
  const canMake = ['Can Make'];
  const categories = canMake
    .concat(data.categories.sort())
    .filter((i) => (i === 'Weaponry' ? true : i));
  const foodtypes = canMake.concat(data.foodtypes.sort());
  const pageSize =
    searchText.length > 0
      ? display_compact
        ? 20
        : 10
      : display_compact
        ? 60
        : 30;
  const displayLimit = pageSize * pages;
  const content = document.getElementById('content');
  const CATEGORY_ICONS =
    mode === MODE.cooking ? CATEGORY_ICONS_COOKING : CATEGORY_ICONS_CRAFTING;
  return (
    <Window width={700} height={720}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width={'200px'}>
            <Section fill>
              <Stack fill vertical justify={'space-between'}>
                <Stack.Item>
                  <Input
                    autoFocus
                    expensive
                    placeholder={
                      'Search in ' +
                      data.recipes.length +
                      (mode === MODE.cooking ? ' recipes...' : ' designs...')
                    }
                    value={searchText}
                    onInput={(e, value) => {
                      setPages(1);
                      setSearchText(value);
                    }}
                    fluid
                  />
                </Stack.Item>
                <Stack.Item>
                  <Tabs fluid textAlign="center">
                    <Tabs.Tab
                      selected={tabMode === TABS.category}
                      onClick={() => {
                        if (tabMode === TABS.category) {
                          return;
                        }
                        setTabMode(TABS.category);
                        setPages(1);
                        setCategory(
                          Object.keys(craftability).length
                            ? 'Can Make'
                            : data.categories[0]
                        );
                      }}>
                      Category
                    </Tabs.Tab>
                    {mode === MODE.cooking && (
                      <Tabs.Tab
                        selected={tabMode === TABS.foodtype}
                        onClick={() => {
                          if (tabMode === TABS.foodtype) {
                            return;
                          }
                          setTabMode(TABS.foodtype);
                          setPages(1);
                          setFoodType(
                            Object.keys(craftability).length
                              ? 'Can Make'
                              : data.foodtypes[0]
                          );
                        }}>
                        Type
                      </Tabs.Tab>
                    )}
                    <Tabs.Tab
                      selected={tabMode === TABS.material}
                      onClick={() => {
                        if (tabMode === TABS.material) {
                          return;
                        }
                        setTabMode(TABS.material);
                        setPages(1);
                        setMaterial(material_occurences[0].atom_id);
                      }}>
                      {mode === MODE.cooking ? 'Ingredient' : 'Material'}
                    </Tabs.Tab>
                  </Tabs>
                </Stack.Item>
                <Stack.Item grow m={-1} style={{ overflowY: 'auto' }}>
                  <Box height={'100%'} p={1} style={{ 'overflow-y': 'auto' }}>
                    <Tabs vertical>
                      {tabMode === TABS.foodtype &&
                        mode === MODE.cooking &&
                        foodtypes.map((foodtype) => (
                          <Tabs.Tab
                            key={foodtype}
                            selected={
                              activeType === foodtype && searchText.length === 0
                            }
                            onClick={(e) => {
                              setFoodType(foodtype);
                              setPages(1);
                              if (content) {
                                content.scrollTop = 0;
                              }
                              if (searchText.length > 0) {
                                setSearchText('');
                              }
                            }}>
                            <FoodtypeContent
                              type={foodtype}
                              diet={diet}
                              craftableCount={Object.keys(craftability).length}
                            />
                          </Tabs.Tab>
                        ))}
                      {tabMode === TABS.material &&
                        material_occurences.map((material) => (
                          <Tabs.Tab
                            key={material.atom_id}
                            selected={
                              activeMaterial === material.atom_id &&
                              searchText.length === 0
                            }
                            onClick={(e) => {
                              setMaterial(material.atom_id);
                              setPages(1);
                              if (content) {
                                content.scrollTop = 0;
                              }
                              if (searchText.length > 0) {
                                setSearchText('');
                              }
                            }}>
                            <MaterialContent
                              atom_id={material.atom_id}
                              occurences={material.occurences}
                            />
                          </Tabs.Tab>
                        ))}
                      {tabMode === TABS.category &&
                        categories.map((category) => (
                          <Tabs.Tab
                            key={category}
                            selected={
                              activeCategory === category &&
                              searchText.length === 0
                            }
                            onClick={(e) => {
                              setCategory(category);
                              setPages(1);
                              if (content) {
                                content.scrollTop = 0;
                              }
                              if (searchText.length > 0) {
                                setSearchText('');
                              }
                            }}>
                            <Stack>
                              <Stack.Item width="14px" textAlign="center">
                                <Icon
                                  color={
                                    category === 'Blood Cult'
                                      ? 'red'
                                      : 'default'
                                  }
                                  name={CATEGORY_ICONS[category] || 'circle'}
                                />
                              </Stack.Item>
                              <Stack.Item
                                grow
                                color={
                                  category === 'Blood Cult' ? 'red' : 'default'
                                }>
                                {category}
                              </Stack.Item>
                              {category === 'Can Make' && (
                                <Stack.Item>
                                  {Object.keys(craftability).length}
                                </Stack.Item>
                              )}
                            </Stack>
                          </Tabs.Tab>
                        ))}
                    </Tabs>
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Divider />
                  <Button.Checkbox
                    fluid
                    content="Can make only"
                    checked={display_craftable_only}
                    onClick={() => {
                      act('toggle_recipes');
                    }}
                  />
                  <Button.Checkbox
                    fluid
                    content="Compact list"
                    checked={display_compact}
                    onClick={() => act('toggle_compact')}
                  />
                </Stack.Item>
                {!forced_mode && (
                  <Stack.Item>
                    <Stack textAlign="center">
                      <Stack.Item grow>
                        <Button.Checkbox
                          fluid
                          lineHeight={2}
                          content="Craft"
                          checked={mode === MODE.crafting}
                          icon="hammer"
                          style={{
                            'border':
                              '2px solid ' +
                              (mode === MODE.crafting ? '#20b142' : '#333'),
                          }}
                          onClick={() => {
                            if (mode === MODE.crafting) {
                              return;
                            }
                            setTabMode(TABS.category);
                            setCategory(DEFAULT_CAT_CRAFTING);
                            act('toggle_mode');
                          }}
                        />
                      </Stack.Item>
                      <Stack.Item grow>
                        <Button.Checkbox
                          fluid
                          lineHeight={2}
                          content="Cook"
                          checked={mode === MODE.cooking}
                          icon="utensils"
                          style={{
                            'border':
                              '2px solid ' +
                              (mode === MODE.cooking ? '#20b142' : '#333'),
                          }}
                          onClick={() => {
                            if (mode === MODE.cooking) {
                              return;
                            }
                            setTabMode(TABS.category);
                            setCategory(DEFAULT_CAT_COOKING);
                            act('toggle_mode');
                          }}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow my={-1}>
            <Box
              id="content"
              height={'100%'}
              pr={1}
              pt={1}
              mr={-1}
              style={{ 'overflow-y': 'auto' }}>
              {recipes.length > 0 ? (
                recipes
                  .slice(0, displayLimit)
                  .map((item) =>
                    display_compact ? (
                      <RecipeContentCompact
                        key={item.ref}
                        item={item}
                        craftable={Boolean(craftability[item.ref])}
                        busy={busy}
                        mode={mode}
                      />
                    ) : (
                      <RecipeContent
                        key={item.ref}
                        item={item}
                        craftable={Boolean(craftability[item.ref])}
                        busy={busy}
                        mode={mode}
                        diet={diet}
                      />
                    )
                  )
              ) : (
                <NoticeBox m={1} p={1}>
                  No recipes found.
                </NoticeBox>
              )}
              {recipes.length > displayLimit && (
                <Section
                  mb={2}
                  textAlign="center"
                  style={{ 'cursor': 'pointer' }}
                  onClick={() => setPages(pages + 1)}>
                  Load {Math.min(pageSize, recipes.length - displayLimit)}{' '}
                  more...
                </Section>
              )}
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MaterialContent = (props, context) => {
  const { atom_id, occurences } = props;
  const { data } = useBackend<Data>(context);
  const name = data.atom_data[atom_id - 1].name;
  const mode = data.mode;
  return (
    <Stack>
      <Stack.Item>
        <Box
          verticalAlign="middle"
          inline
          ml={-1.5}
          mr={-0.5}
          className={classes([
            mode ? 'cooking32x32' : 'crafting32x32',
            'a' + atom_id,
          ])}
        />
      </Stack.Item>
      <Stack.Item
        height="32px"
        lineHeight="32px"
        grow
        style={{
          'text-transform': 'capitalize',
          'overflow': 'hidden',
          'text-overflow': 'ellipsis',
          'white-space': 'nowrap',
        }}>
        {name}
      </Stack.Item>
      <Stack.Item height="32px" lineHeight="32px">
        {occurences}
      </Stack.Item>
    </Stack>
  ) as any;
};

const FoodtypeContent = (props) => {
  const { type, diet, craftableCount } = props;
  let iconName = '',
    iconColor = '';

  // We use iconName in the return to see if this went through.
  if (type !== 'Can Make' && diet) {
    if (diet.liked_food.includes(type)) {
      iconName = 'face-laugh-beam';
      iconColor = 'good';
    } else if (diet.disliked_food.includes(type)) {
      iconName = 'face-tired';
      iconColor = 'average';
    } else if (diet.toxic_food.includes(type)) {
      iconName = 'skull-crossbones';
      iconColor = 'bad';
    }
  }

  return (
    <Stack>
      <Stack.Item width="14px" textAlign="center">
        <Icon name={TYPE_ICONS[type] || 'circle'} />
      </Stack.Item>
      <Stack.Item grow style={{ 'text-transform': 'capitalize' }}>
        {type.toLowerCase()}
      </Stack.Item>
      <Stack.Item>
        {type === 'Can Make'
          ? craftableCount
          : iconName && <Icon name={iconName} color={iconColor} />}
      </Stack.Item>
    </Stack>
  );
};

const RecipeContentCompact = ({ item, craftable, busy, mode }, context) => {
  const { act, data } = useBackend<Data>(context);
  return (
    <Section>
      <Stack my={-0.75}>
        <Stack.Item>
          <Box className={item.icon} />
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box mb={0.5} bold style={{ 'text-transform': 'capitalize' }}>
                {item.name}
              </Box>
              <Box style={{ 'text-transform': 'capitalize' }} color={'gray'}>
                {Array.from(
                  Object.keys(item.reqs).map((atom_id) => {
                    const name = data.atom_data[(atom_id as any) - 1]?.name;
                    const is_reagent =
                      data.atom_data[(atom_id as any) - 1]?.is_reagent;
                    const amount = item.reqs[atom_id];
                    return is_reagent
                      ? `${name}\xa0${amount}u`
                      : amount > 1
                        ? `${name}\xa0${amount}x`
                        : name;
                  })
                ).join(', ')}
                {item.tool_paths &&
                  ', ' +
                    item.tool_paths
                      .map((item) => data.atom_data[(item as any) - 1]?.name)
                      .join(', ')}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box>
                {!!item.tool_behaviors && (
                  <Tooltip
                    content={'Tools: ' + item.tool_behaviors.join(', ')}>
                    <Icon p={1} name="screwdriver-wrench" />
                  </Tooltip>
                )}
                <Button
                  my={0.3}
                  lineHeight={2.5}
                  align="center"
                  content="Make"
                  disabled={!craftable || busy}
                  icon={
                    busy
                      ? 'circle-notch'
                      : mode === MODE.cooking
                        ? 'utensils'
                        : 'hammer'
                  }
                  iconSpin={busy ? 1 : 0}
                  onClick={() =>
                    act('make', {
                      recipe: item.ref,
                    })
                  }
                />
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RecipeContent = ({ item, craftable, busy, mode, diet }, context) => {
  const { act } = useBackend<Data>(context);
  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Box width={'64px'} height={'64px'} mr={1}>
            <Box
              style={{
                'transform': 'scale(1.5)',
              }}
              m={'16px'}
              className={item.icon}
            />
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box mb={0.5} bold style={{ 'text-transform': 'capitalize' }}>
                {item.name}
              </Box>
              {item.desc && <Box color={'gray'}>{item.desc}</Box>}
              <Box style={{ 'text-transform': 'capitalize' }}>
                {item.reqs && (
                  <Box>
                    <GroupTitle
                      title={
                        mode === MODE.cooking ? 'Ingredients' : 'Materials'
                      }
                    />
                    {Object.keys(item.reqs).map((atom_id) => (
                      <AtomContent
                        key={atom_id}
                        atom_id={atom_id}
                        amount={item.reqs[atom_id]}
                      />
                    ))}
                  </Box>
                )}
                {(item.tool_paths || item.tool_behaviors) && (
                  <Box>
                    <GroupTitle title="Tools" />
                    {item.tool_paths &&
                      item.tool_paths.map((tool) => (
                        <AtomContent key={tool} atom_id={tool} amount={1} />
                      ))}
                    {item.tool_behaviors &&
                      item.tool_behaviors.map((tool) => (
                        <ToolContent key={tool} tool={tool} />
                      ))}
                  </Box>
                )}
                {(item.skill_requirements) && (
                  <Box>
                    <GroupTitle title="Skills" />
                    {item.skill_requirements.map((skill_req, index) => (
                      <SkillContent key={index} skill={skill_req.skill} level={skill_req.level} />
                    ))}
                  </Box>
                )}
              </Box>
            </Stack.Item>
            <Stack.Item pl={1}>
              <Button
                width="104px"
                lineHeight={2.5}
                align="center"
                content="Make"
                disabled={!craftable || busy}
                icon={
                  busy
                    ? 'circle-notch'
                    : mode === MODE.cooking
                      ? 'utensils'
                      : 'hammer'
                }
                iconSpin={busy ? 1 : 0}
                onClick={() =>
                  act('make', {
                    recipe: item.ref,
                  })
                }
              />
              {item.nutriments > 0 && (
                <Box color={'gray'} width={'104px'} lineHeight={1.5} mt={1}>
                  Nutrition: {item.nutriments}
                  <Divider />
                </Box>
              )}
              {item.foodtypes?.length > 0 && (
                <Box color={'gray'} width={'104px'} lineHeight={1.5} mt={1}>
                  {item.foodtypes.map((foodtype) => (
                    <FoodtypeContent
                      key={item.ref}
                      type={foodtype}
                      diet={diet}
                    />
                  ))}
                </Box>
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AtomContent = ({ atom_id, amount }, context) => {
  const { data } = useBackend<Data>(context);
  const name = data.atom_data[atom_id - 1]?.name;
  const is_reagent = data.atom_data[atom_id - 1]?.is_reagent;
  const mode = data.mode;
  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={classes([
          mode ? 'cooking32x32' : 'crafting32x32',
          'a' + atom_id,
        ])}
      />
      <Box inline verticalAlign="middle">
        {name}
        {is_reagent ? `\xa0${amount}u` : amount > 1 && `\xa0${amount}x`}
      </Box>
    </Box>
  ) as any;
};

const ToolContent = ({ tool }) => {
  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={classes(['crafting32x32', tool.replace(/ /g, '')])}
      />
      <Box inline verticalAlign="middle">
        {tool}
      </Box>
    </Box>
  ) as any;
};

const SkillContent = ({ skill, level }) => {
  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={classes(['crafting32x32', skill.replace(/ /g, '')])}
      />
      <Box inline verticalAlign="middle">
        {skill} {level}
      </Box>
    </Box>
  ) as any;
};

const GroupTitle = ({ title }) => {
  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item color={'gray'}>{title}</Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  ) as any;
};
