import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Tabs, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const AiServerConsole = (props, context) => {
  const { act, data } = useBackend(context);

  const [tab, setTab] = useLocalState(context, 'tab', 1);

  return (
    <Window
      width={500}
      height={450}
      resizable>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tab === 1}
            onClick={(() => setTab(1))}>
            AI Servers
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 2}
            onClick={(() => setTab(2))}>
            AI Data Cores
          </Tabs.Tab>
        </Tabs>
        {tab == 1 && (
          <Section title="Server Overview">
            {data.servers.map((server, index) => {
              return (
                <Section key={index}>
                  <Box textAlign="center">Location: <Box inline bold>{server.area}</Box></Box>
                  <Box textAlign="center" bold>Status: <Box inline color={server.working ? "good" : "bad"}>{server.working ? "ONLINE" : "OFFLINE"}</Box></Box>
                  <ProgressBar
                    ranges={{
                      good: [-Infinity, 250],
                      average: [250, 750],
                      bad: [750, Infinity],
                    }}
                    value={server.temp}

                    maxValue={750}>{server.temp}K
                  </ProgressBar>
                  <Box textAlign="center">Capacity: <Box inline bold>{server.card_capacity} servers</Box></Box>
                  <Box textAlign="center">CPU Power: <Box inline bold>{server.total_cpu} THz</Box></Box>
                  <Box textAlign="center">RAM Capacity: <Box inline bold>{server.ram} TB</Box></Box>
                </Section>
              );
            })}
          </Section>
        )}
        {tab == 2 && (
          <Section title="Core Overview">
            {data.cores.map((server, index) => {
              return (
                <Section key={index}>
                  <Box textAlign="center">Location: <Box inline bold>{server.area} {server.coords}</Box></Box>
                  <Box textAlign="center" bold>Status: <Box inline color={server.working ? "good" : "bad"}>{server.working ? "ONLINE" : "OFFLINE"}</Box></Box>
                  <ProgressBar
                    ranges={{
                      good: [-Infinity, 250],
                      average: [250, 750],
                      bad: [750, Infinity],
                    }}
                    value={server.temp}

                    maxValue={750}>{server.temp}K
                  </ProgressBar>
                </Section>
              );
            })}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
