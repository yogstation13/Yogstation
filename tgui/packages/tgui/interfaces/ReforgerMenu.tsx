import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Tabs,
  Stack,
  Box,
  TextArea,
} from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import { capitalize } from 'common/string';

type Data = {
  reforge_target: Item | null;
  fantasyComp: FantasyComp;
  rarities: Rarity[];
  rarity_total_weight: number;
  use_super_credits: boolean;
  super_credits_available: number;
};

type FantasyComp = {
  name: string;
  rarity: string;
};

type Item = {
  name: string;
  description: string;
  rarity: Rarity;
  item_pic: string;
};

type Rarity = {
  name: string;
  weight: number;
  color: string;
};

export const ReforgerMenu = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { reforge_target, rarities, use_super_credits } = data;
  const modified_rarities = [30, 35, 20, 10, 5];

  return (
    <Window title="Enchanting Anvil" width={800} height={500} resizable>
      <Window.Content>
        <Stack m={1} fill textAlign="center">
          <Stack.Item grow={2}>
            <Stack fill vertical>
              <ItemPreview />
            </Stack>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Stack fill fluid vertical>
              <Stack.Item>
                <Section title="Rarity Rates">
                  <LabeledList>
                    {rarities.map((rarity) => (
                      <LabeledList.Item key={rarity.name} color={rarity.color}>
                        {capitalize(rarity.name)}:{' '}
                        {use_super_credits
                          ? modified_rarities[
                              rarities.findIndex(
                                (raritykey) => raritykey === rarity
                              )
                            ]
                          : rarity.weight}
                        %
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemPreview = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    reforge_target = null,
    rarities,
    use_super_credits,
    super_credits_available,
  } = data;
  const item_rarity = reforge_target?.rarity || rarities[0];
  const item_color = item_rarity?.color || 'white';
  const font_size = Math.max(
    24,
    16 * (rarities.findIndex((rarity) => rarity.name === item_rarity.name) + 1)
  );
  const [readTerms, setReadTermsChecked] = useLocalState<boolean>(
    context,
    'readTerms',
    false
  );

  if (reforge_target !== null) {
    return (
      <Section fill>
        <Stack fill justify="space-between" vertical textAlign="center">
          <Stack.Item fontSize={font_size + 'px'} color={item_color}>
            {capitalize(reforge_target.name)}
          </Stack.Item>
          <Stack.Item fontSize="16px">{reforge_target.description}</Stack.Item>

          <Stack.Item>
            <Box
              as="img"
              src={`data:image/jpeg;base64,${reforge_target.item_pic}`}
              height="128px"
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
                'image-rendering': 'pixelated',
              }}
            />
          </Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Button.Checkbox
                content="Use Super Credits(TM) to improve roll chances."
                checked={use_super_credits}
                disabled={super_credits_available<1}
                color="transparent"
                onClick={() => act('toggle_super_credits')}
              />
              <Stack.Item>
                {super_credits_available} Super Credits(TM) available to you.
              </Stack.Item>
              <Button.Checkbox
                content="I have read and agree to the terms and conditions"
                checked={readTerms}
                color="transparent"
                onClick={() => {
                  setReadTermsChecked(!readTerms);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="hammer"
                iconPosition="right"
                content="Reroll"
                textAlign="center"
                fontSize="32px"
                color="green"
                disabled={!readTerms}
                tooltip={
                  !readTerms
                    ? 'You gotta accept the Terms and Conditions first!!!!'
                    : ''
                }
                onClick={() => act('reroll')}
              />
            </Stack.Item>
          </Stack>
        </Stack>
      </Section>
    );
  } else {
    return (
      <Section fill>
        <Stack fill align="center">
          <Stack.Item fontSize="24px">
            Place an item on the anvil to get started and let fate take the
            wheel.
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
};
