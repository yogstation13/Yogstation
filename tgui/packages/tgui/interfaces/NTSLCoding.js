import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Input,
  Tabs,
  TextArea,
  Section,
  Stack,
} from '../components';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

export const NTSLCoding = (props) => {
  // Make sure we don't start larger than 50%/80% of screen width/height.
  const winWidth = Math.min(900, window.screen.availWidth * 0.5);
  const winHeight = Math.min(600, window.screen.availHeight * 0.8);

  return (
    <Window title="Traffic Control Console" width={winWidth} height={winHeight}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width={winWidth - 240}>
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

const ScriptEditor = (props) => {
  const { act, data } = useBackend();
  const { stored_code, user_name } = data;
  return (
    <Box width="100%" height="100%">
      {user_name ? (
        <TextArea
          noborder
          scrollbar
          value={stored_code}
          width="100%"
          height="100%"
          onChange={(_, value) =>
            act('save_code', {
              saved_code: value,
            })
          }
        />
      ) : (
        <Section width="100%" height="100%">
          {stored_code}
        </Section>
      )}
    </Box>
  );
};

const MainMenu = (props) => {
  const { act, data } = useBackend();
  const { emagged, user_name, admin_view } = data;
  const [tabIndex, setTabIndex] = useLocalState('tab-index', 1);
  return (
    <>
      {admin_view === 1 ? (
        <Button
          icon="power-off"
          color="red"
          content="!!!(ADMIN) reset code and compile!!!"
          onClick={() => act('admin_reset')}
        />
      ) : (
        ''
      )}
      <Section width="240px">
        {user_name ? (
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
            <Stack.Item verticalAlign="middle">{user_name}</Stack.Item>
          </Stack>
        ) : (
          <Button
            icon="power-off"
            color="green"
            content="Log In"
            onClick={() => act('log_in')}
          />
        )}
      </Section>
      {user_name && (
        <Section width="240px" height="90%" fill>
          <Tabs>
            <Tabs.Tab selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
              Compile
            </Tabs.Tab>
            <Tabs.Tab selected={tabIndex === 2} onClick={() => setTabIndex(2)}>
              Network
            </Tabs.Tab>
            <Tabs.Tab selected={tabIndex === 3} onClick={() => setTabIndex(3)}>
              Logs
            </Tabs.Tab>
            <Tabs.Tab selected={tabIndex === 4} onClick={() => setTabIndex(4)}>
              Reference
            </Tabs.Tab>
          </Tabs>
          {tabIndex === 1 && <CompilerOutput />}
          {tabIndex === 2 && <ServerList />}
          {tabIndex === 3 && <LogViewer />}
          {tabIndex === 4 && <Guide />}
        </Section>
      )}
    </>
  );
};

const CompilerOutput = (props) => {
  const { act, data } = useBackend();
  const { compiler_output } = data;
  return (
    <>
      <Box>
        <Button
          mb={1}
          icon="save"
          content="Compile & Run"
          onClick={() => act('compile_code')}
        />
      </Box>
      <Divider />
      <Section fill scrollable height="87.2%">
        {compiler_output
          ? compiler_output.map((error_message, index) => (
              <Box key={index}>{error_message}</Box>
            ))
          : 'No compile errors.'}
      </Section>
    </>
  );
};

const ServerList = (props) => {
  const { act, data } = useBackend();
  const { network, server_data } = data;
  return (
    <>
      <Box>
        <Button
          mb={1}
          icon="sync"
          content="Reconnect to Network"
          onClick={() => act('refresh_servers')}
        />
      </Box>
      <Box>
        <Input
          mb={1}
          value={network}
          onChange={(_, value) =>
            act('set_network', {
              new_network: value,
            })
          }
        />
      </Box>
      <Divider />
      <Section fill scrollable height="82%">
        {server_data.map((nt_server, index) => (
          <Box key={index}>
            <Button.Checkbox
              mb={0.5}
              checked={nt_server.run_code}
              content={nt_server.server_name}
              onClick={() =>
                act('toggle_code_execution', {
                  selected_server: nt_server.server,
                })
              }
            />
          </Box>
        ))}
      </Section>
    </>
  );
};

const LogViewer = (props) => {
  const { act, data } = useBackend();
  const { access_log } = data;
  // This is terrible but nothing else will work
  return (
    <>
      <Box>
        <Button
          mb={1}
          icon="trash"
          content="Clear Logs"
          onClick={() => act('clear_logs')}
        />
      </Box>
      <Divider />
      <Section fill scrollable height="87.2%">
        {access_log
          ? access_log.map((access_message, index) => (
              <Box key={index}>{access_message}</Box>
            ))
          : 'Access log could not be found. Please contact an administrator.'}
      </Section>
    </>
  );
};

// These frequencies wont show up the list of the frequencies in the guide,
// Because you cant use them.
const blacklistedChannels = [
  'Syndicate',
  'Red Team',
  'Blue Team',
  'Green Team',
  'Yellow Team',
];

const Guide = (props) => {
  return (
    <Section fill scrollable height="95.5%">
      NT Recognized Frequencies: <br />
      (var = channels.channel_name) <br />
      {RADIO_CHANNELS.filter(
        (channel) => !blacklistedChannels.includes(channel.name),
      ).map((channel, index) => (
        <div key={index} style={{ color: channel.color }}>
          {channel.name}: {channel.freq}
        </div>
      ))}
      <br />
      <br />
      NT radio filters: <br />
      (var = filter_types.filter_name) <br />
      # fonts <br />
      &quot;robot&quot; (robot) <br />
      &quot;sans&quot; (wacky) <br />
      # manipulation <br />
      <i>&quot;italics&quot; (emphasis)</i> <br />
      <b>&quot;yell&quot; (loud)</b> <br />
      &quot;command_headset&quot; (commanding) <br />
      <br /> {/* Btw, clown is also allowed. But we don't tell them that */}
      <br />
      NT Readable languages: <br />
      (var = languages.language_name) <br />
      1 (human) <br />
      2 (monkey) <br />
      4 (robot) <br />
      8 (draconic) <br />
      16 (beachtounge) <br />
      32 (sylvan) <br />
      64 (etherean) <br />
      128 (bonespeak) <br />
      256 (mothian) <br />
      512 (cat) <br />
      1024 (english) <br />
    </Section>
  );
};
