import { useBackend, useLocalState } from '../backend';
import { Button, Input, Tabs, TextArea, Section, Stack, Box } from '../components';
import { Window } from '../layouts';


export const NtslEditor = (props, context) => {
  const { act, data } = useBackend(context);

  // Ideally we'd display a large window for it all...
  const idealWidth = 800,
    idealHeight = 600;

  // ...but we should check for small screens, to play nicely with eg laptops.
  const winWidth = window.screen.availWidth;
  const winHeight = window.screen.availHeight;

  // Make sure we don't start larger than 50%/80% of screen width/height.
  const width = Math.min(idealWidth, winWidth * 0.5);
  const height = Math.min(idealHeight, winHeight * 0.8);

  return (
    <Window
      title="Traffic Control Console"
      width={width}
      height={height}
      >
      <Window.Content>
        <Stack fill>
          <Stack.Item width="80%">
            <ScriptEditor />
          </Stack.Item>
          <Stack.Item>
            <MainMenu />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ScriptEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const { stored_code, user_name } = data;
  return (
    <Box width="100%" height="100%">
      {user_name ?
        <TextArea
          value={stored_code}
          width="100%"
          height="100%"
          onChange={(e, value) => act('save_code', {
            saved_code: value,
          })}
        /> :
        <Section width="100%" height="100%">
          {stored_code}
        </Section>
      }
    </Box>
  );
};

const MainMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { emagged, user_name } = data;
  const [tabIndex, setTabIndex] = useLocalState(context, "tab-index", 1);
  return (
    <>
      <Section width="240px">
        {user_name ?
        <Stack>
          <Stack.Item>
            <Button
              icon="power-off"
              color="purple"
              content="Log Out"
              disabled={emagged}
              onClick={() => act('log_out')}
            />
          </Stack.Item>
          <Stack.Item verticalAlign="middle">
            {user_name}
          </Stack.Item>
        </Stack> : <Button
          icon="power-off"
          color="green"
          content="Log In"
          onClick={() => act('log_in')}
        />}
      </Section>
      {user_name &&
        <Section width="240px" height="90%" fill>
          <Tabs>
            <Tabs.Tab
              selected={tabIndex === 1}
              onClick={() => setTabIndex(1)}>
              Compile
            </Tabs.Tab>
            <Tabs.Tab
              selected={tabIndex === 2}
              onClick={() => setTabIndex(2)}>
              Network
            </Tabs.Tab>
            <Tabs.Tab
              selected={tabIndex === 3}
              onClick={() => setTabIndex(3)}>
              Logs
            </Tabs.Tab>
          </Tabs>
          { tabIndex === 1 && <CompilerOutput /> }
          { tabIndex === 2 && <ServerList /> }
          { tabIndex === 3 && <LogViewer /> }
        </Section>
      }
    </>
  );
};

const CompilerOutput = (props, context) => {
  const { act, data } = useBackend(context);
  const { compiler_output } = data;
  return (
    <>
      <Box>
        <Button
          mb={1}
          icon="save"
          content='Compile & Run'
          onClick={() => act('compile_code')}
        />
      </Box>
      <Window.Content fill scrollable mt={10}>
        {compiler_output ? compiler_output.map((error_message, key) => (
          <Box>
            {error_message}
          </Box>
        )) : "No compile errors."}
      </Window.Content>
    </>
  );
};

const ServerList = (props, context) => {
  const { act, data } = useBackend(context);
  const { network, server_data } = data;
  return (
    <>
      <Box>
        <Button
          mb={1}
          icon="sync"
          content='Reconnect to Network'
          onClick={() => act('refresh_servers')}
        />
      </Box>
      <Box>
        <Input
          mb={1}
          value={network}
          onChange={(e, value) => act('set_network', {
            new_network: value,
          })}
        />
      </Box>
        {server_data.map((nt_server, key) => (
          <Box>
              <Button.Checkbox
                mb={0.5}
                checked={nt_server.run_code}
                content={nt_server.server_name}
                onClick={() => act('toggle_code_execution', {
                  selected_server: nt_server.server,
                })}
              />
          </Box>
        ))}
    </>
  );
};

const LogViewer = (props, context) => {
  const { act, data } = useBackend(context);
  const { access_log } = data;
  // This is terrible but nothing else will work
  return (
    <>
      <Box>
        <Button
          mb={1}
          icon='trash'
          content='Clear Logs'
          onClick={() => act('clear_logs')}
        />
      </Box>
      <Window.Content fill scrollable mt={10}>
        {access_log ? access_log.map((access_message, key) => (
          <Box>
            {access_message}
          </Box>
        )) : "Access log could not be found. Please contact an administrator."}
      </Window.Content>
    </>
  );
};
