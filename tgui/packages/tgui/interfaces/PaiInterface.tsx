import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Flex, Tabs } from '../components';
import { Window } from '../layouts';

type Module = {
  module_name: string;
  title: string;
  text: string;
  module: Module[];
}

type Data = {
  modules_tabs: Module[];
}

type Category = {
  name: string;

}

export const PaiInterface = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [selectedMainTab, setMainTab] = useLocalState<Module | null>(context, "selectedMainTab", null);
  const { modules_tabs = [] } = data;
  return (
    <Window width={450} height={500} theme="">
      <Window.Content>
        <Flex>
          <Flex.Item grow={1}>
            <Section title="Health status">
              Test
            </Section>
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
