import { useBackend } from '../backend';
import { Button, Box, Icon, Stack, Section } from '../components';
import { Window } from '../layouts';
import { classes } from '../../common/react';

type ResearchNode = {
  name: string;
  purchasable: boolean;
  price: number;
  designs: string[];
}

type DepartmentRewardData = {
  points: number;
  department: string;
  nodes: ResearchNode[];
};

export const DepartmentReward = (props, context) => {
  const { data } = useBackend<DepartmentRewardData>(context);
  const {
    points,
    department,
    nodes = [],
  } = data;
  const { act } = useBackend(context);
  return (
    <Window width={500} height={485}>
      <Window.Content scrollable>
        <Section title={department+' Research Console | '+points+' points'}>
          <Stack vertical>
            {nodes.map((node, index) =>
              (<Stack.Item
                fontSize={1}
                height={7}
                fill
                backgroundColor='blue'
                key={'node'+index}>
                <Stack fill vertical>
                  <Stack.Item>
                    <Box px={0.4} fill bold>
                      {node.name}
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow align='center'>
                    {node.designs.map((design, mindex) =>
                        (<span
                          key={'design'+mindex}
                          className={classes(['design32x32', design])}
                          style={{
                            'vertical-align': 'middle',
                          }} />)
                      )}
                  </Stack.Item>
                  <Stack.Item align='end'>
                    <Box px={0.6} fill textAlign='right'>
                    <Button
                      content={"Purchase ["+node.price+"]"}
                      disabled={!node.purchasable}
                      onClick={() => act('purchase')} />
                    </Box>
                  </Stack.Item>
                </Stack>
               </Stack.Item>)
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
