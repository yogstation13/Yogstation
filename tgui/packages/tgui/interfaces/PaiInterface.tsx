import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Flex, Tabs } from '../components';
import { Window } from '../layouts';

type Module = {
  module_name: string;
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
  const winWidth = Math.min(450, window.screen.availWidth * 0.5);
  const winHeight = Math.min(500, window.screen.availHeight * 0.8);
  return (
    <Window width={winWidth} height={winHeight} theme="">
      <Window.Content>
        <Flex>
          <Flex.Item grow={1}>
            <Section title="Health status" fill={1}>
              Test
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section title="Modules" fill={1}>
              <Tabs vertical>
                <Tabs.Tab>
                  Directives
                </Tabs.Tab>
                <Tabs.Tab>
                  Download software
                </Tabs.Tab>
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
