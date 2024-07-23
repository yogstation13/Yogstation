import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Stack, Section, Tabs, Table, Box, TextArea } from '../components';
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
    <Window width={650} height={500} resizable>
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
        <Stack.Item
         key={flavor.item_name}>
            <Stack.Item>
              <Box
              as="img"
              src={resolveAsset(flavor.item_image)}
              height="36px"
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
                'image-rendering': 'pixelated' }} />
            </Stack.Item>
            {capitalize(flavor.item_name)}
        </Stack.Item>
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
