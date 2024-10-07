import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Flex, Tabs } from '../components';
import { Window } from '../layouts';

type Modules = {

}

type Data = {

}

type Category = {
  name: string;

}

export const PaiInterface = (props, context) => {
  const { act, data } = useBackend(context);
  const [selectedMainTab, setMainTab] = useLocalState(context, "selectedMainTab", 0);
  const winWidth = Math.min(450, window.screen.availWidth * 0.5);
  const winHeight = Math.min(500, window.screen.availHeight * 0.8);
  return (
    <Window width={450} height={500} theme="">
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

              </Tabs>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
