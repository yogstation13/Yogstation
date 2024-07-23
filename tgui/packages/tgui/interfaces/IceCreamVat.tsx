import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Stack, Section, Tabs, Box, TextArea } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from './../assets';

type Data = {
  cones: ConeStats[];
  ice_cream: IceCreamStats[];
}

type IceCreamStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
}

type ConeStats = {
  item_image: string;
  item_name: string;
  item_quantity: number;
  item_type_path: string;
}

export const IceCreamVat = (props, context) => {

  return(
    <Window width={550} height={500} resizable>
      <Window.Content>
        <Section title="Cones">
          <ConeRow/>
        </Section>
        <Section title="Scoops">
          <IceCreamRow/>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ConeRow = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { cones = [] } = data;

  return (
    <Stack vertical>
      {cones.map(flavor => (
        <Stack.Divider
         key={flavor.item_name}
         fontSize="16px"
         collapsing>
            <Box
            as="img"
            src={resolveAsset(flavor.item_image)}
            height="38px"
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
              'image-rendering': 'pixelated' }} />
            {capitalize(flavor.item_name)}
            <Stack.Item
              collapsing
              textAlign="right">
            {flavor.item_quantity} in storage
            <Button
            content="Select"
            textAlign="center"
            fontSize="16px"
            disabled={(
              flavor.item_quantity === 0
            )}
            onClick={() => act("select", {
            itemPath: flavor.item_type_path,
            })}
            />
            <Button
            content="Dispence"
            textAlign="center"
            fontSize="16px"
            disabled={(
              flavor.item_quantity === 0
            )}
            onClick={() => act("dispence", {
            itemPath: flavor.item_type_path,
            })}
            />
            </Stack.Item>
        </Stack.Divider>
     ))}
    </Stack>
  );
};

const IceCreamRow = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { ice_cream = [] } = data;

  return (
    <Stack vertical>
      {ice_cream.map(flavor => (
        <Stack.Item
         key={flavor.item_name}>
           {capitalize(flavor.item_name)}
        </Stack.Item>
     ))}
    </Stack>
  );
};
