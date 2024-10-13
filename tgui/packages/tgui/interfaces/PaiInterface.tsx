import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Flex, Tabs } from '../components';
import { Window } from '../layouts';

type Module = {
  module_name: string;
  title: string;
  text: string;
}

type Data = {
  modules_tabs: Module[];
  prime: string;
  laws: Data[];
}

export const PaiInterface = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { modules_tabs = [] } = data;
  const [selectedMainTab, setMainTab] = useLocalState<Module | null>(context, "selectedMainTab", null);
  return (
    <Window width={600} height={500} theme="">
      <Window.Content>
        <Flex>
          <Flex.Item grow={1}>
            <PaiBox />
          </Flex.Item>
          <Flex.Item>
            <Section title="Modules">
              <Tabs vertical>
                {modules_tabs.map(module => (
                  <Tabs.Tab
                    key={module}
                    selected={module === selectedMainTab}
                    onClick={() => setMainTab(module)}>
                      {capitalize(module.module_name)}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const PaiBox = (props, context) => {
  const { data } = useBackend<Data>(context);
  const [selectedMainTab, setMainTab] = useLocalState<Module | null>(context, "selectedMainTab", null);
  const { prime } = data;
  const { laws } = data;
  if(selectedMainTab===null) {
    return;
  }
  switch(selectedMainTab.module_name) {
    case "Directives":
      return (
        <Section title={selectedMainTab.module_name}>
          Prime directive:
          {prime}
          Supplemental Directives:
          {laws.map(data => data)}
        </Section>
      );
  }
};
