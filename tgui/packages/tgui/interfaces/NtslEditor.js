import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, Input, Tabs, TextArea, Section, Stack } from '../components';
import { Window } from '../layouts';

// NTSLTextArea component start
// This is literally just TextArea but without ENTER updating anything, for NTSL
import { toInputValue } from '../components/Input';
import { KEY_ESCAPE, KEY_TAB } from 'common/keycodes';

class NTSLTextArea extends TextArea {
  constructor(props) {
    super(props);
    const { dontUseTabForIndent = false } = props;
    this.handleKeyDown = (e) => {
      const { editing } = this.state;
      const { onChange, onInput, onEnter, onKey } = this.props;
      if (e.keyCode === KEY_ESCAPE) {
        if (this.props.onEscape) {
          this.props.onEscape(e);
        }
        this.setEditing(false);
        if (this.props.selfClear) {
          e.target.value = '';
        } else {
          e.target.value = toInputValue(this.props.value);
          e.target.blur();
        }
        return;
      }
      if (!editing) {
        this.setEditing(true);
      }
      // Custom key handler
      if (onKey) {
        onKey(e, e.target.value);
      }
      if (!dontUseTabForIndent) {
        const keyCode = e.keyCode || e.which;
        if (keyCode === KEY_TAB) {
          e.preventDefault();
          const { value, selectionStart, selectionEnd } = e.target;
          e.target.value =
            value.substring(0, selectionStart) +
            '\t' +
            value.substring(selectionEnd);
          e.target.selectionEnd = selectionStart + 1;
          if (onInput) {
            onInput(e, e.target.value);
          }
        }
      }
    };
  }
}
// NTSLTextArea component end

export const NtslEditor = (props, context) => {
  // Make sure we don't start larger than 50%/80% of screen width/height.
  const winWidth = Math.min(900, window.screen.availWidth * 0.5);
  const winHeight = Math.min(600, window.screen.availHeight * 0.8);

  return (
    <Window
      title="Traffic Control Console"
      width={winWidth}
      height={winHeight}
      >
      <Window.Content>
        <Stack fill>
          <Stack.Item width={winWidth-240}>
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
        <NTSLTextArea
          noborder
          scrollbar
          value={stored_code}
          width="100%"
          height="100%"
          onChange={(e, value) => act('save_code', {
            saved_code: value,
          })}
          onEnter={(e, value) => act('save_code', {
            saved_code: value+"\n",
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
      <Divider />
      <Section fill scrollable height="87.2%">
        {compiler_output ? compiler_output.map((error_message, index) => (
          <Box key={index}>
            {error_message}
          </Box>
        )) : "No compile errors."}
      </Section>
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
      <Divider />
      <Section fill scrollable height="82%">
        {server_data.map((nt_server, index) => (
          <Box key={index}>
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
      </Section>
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
      <Divider />
      <Section fill scrollable height="87.2%">
        {access_log ? access_log.map((access_message, index) => (
          <Box key={index}>
            {access_message}
          </Box>
        )) : "Access log could not be found. Please contact an administrator."}
      </Section>
    </>
  );
};
