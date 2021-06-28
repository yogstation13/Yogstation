/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */


import { Button, Stack, Section } from 'tgui/components';
import { Pane } from 'tgui/layouts';
import { NowPlayingWidget, useAudio } from './audio';
import { ChatPanel, ChatTabs } from './chat';
import { gameReducer, useGame } from './game';
import { Notifications } from './Notifications';
import { PingIndicator } from './ping';
import { SettingsPanel, useSettings } from './settings';

export const Panel = (props, context) => {
  // IE8-10: Needs special treatment due to missing Flex support
  if (Byond.IS_LTE_IE10) {
    return (
      <HoboPanel />
    );
  }
  const audio = useAudio(context);
  const settings = useSettings(context);
  const game = useGame(context);
  if (process.env.NODE_ENV !== 'production') {
    const { useDebug, KitchenSink } = require('tgui/debug');
    const debug = useDebug(context);
    if (debug.kitchenSink) {
      return (
        <KitchenSink panel />
      );
    }
  }
  return (
    <Pane theme={settings.theme}>
      <Stack
        height={(98-number) + '%'}
        vertical
        grow={0}
        shrink={0}>
        <StatTabs
          direction="column" />
      </Stack>
      <DraggableControl
        value={number}
        height="1%"
        minValue={0}
        maxValue={100}
        dragMatrix={[0, -1]}
        step={1}
        stepPixelSize={9}
        onDrag={(e, value) => resizeFunction(value)}
        updateRate={5}>
        {control => (
          <Box
            onMouseDown={control.handleDragStart}
            height="10px">
            <Box
              position="relative"
              height="4px"
              backgroundColor="grey"
              top="3px">
              <Divider />
              {control.inputElement}
            </Box>
          </Box>
        )}
      </DraggableControl>
      <Stack
        fill
        vertical
        height={(number-1) + '%'}>
        <Stack.Item>
          <Section fitted>
            <Stack mx={1} align="center">
              <Stack.Item grow overflowX="auto">
                <ChatTabs />
              </Stack.Item>
              <Stack.Item>
                <PingIndicator />
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="grey"
                  selected={audio.visible}
                  icon="music"
                  tooltip="Music player"
                  tooltipPosition="bottom-left"
                  onClick={() => audio.toggle()} />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={settings.visible ? 'times' : 'cog'}
                  selected={settings.visible}
                  tooltip={settings.visible
                    ? 'Close settings'
                    : 'Open settings'}
                  tooltipPosition="bottom-left"
                  onClick={() => settings.toggle()} />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        {audio.visible && (
          <Stack.Item>
            <Section>
              <NowPlayingWidget />
            </Section>
          </Stack.Item>
        )}
        {settings.visible && (
          <Stack.Item>
            <SettingsPanel />
          </Stack.Item>
        )}
        <Stack.Item grow>
          <Section fill fitted position="relative">
            <Pane.Content scrollable>
              <ChatPanel lineHeight={settings.lineHeight} />
            </Pane.Content>
            <Notifications>
              {game.connectionLostAt && (
                <Notifications.Item
                  rightSlot={(
                    <Button
                      color="white"
                      onClick={() => Byond.command('.reconnect')}>
                      Reconnect
                    </Button>
                  )}>
                  You are either AFK, experiencing lag or the connection
                  has closed. If the server has been nuked, you
                  are just lagging, you should be fine in a moment.
                </Notifications.Item>
              )}
              {game.reconnectTimer > 0 && (
                <Notifications.Item>
                  The connection has been closed because the server is
                  restarting. Please wait while you are automatically reconnected
                  in {game.reconnectTimer} Seconds.
                </Notifications.Item>
              )}
            </Notifications>
          </Section>
        </Stack.Item>
      </Stack>
    </Pane>
  );
};

const HoboPanel = (props, context) => {
  const settings = useSettings(context);
  return (
    <Pane theme={settings.theme}>
      <Pane.Content scrollable>
        <Button
          style={{
            position: 'fixed',
            top: '1em',
            right: '2em',
            'z-index': 1000,
          }}
          selected={settings.visible}
          onClick={() => settings.toggle()}>
          Settings
        </Button>
        {settings.visible && (
          <Flex.Item mt={1}>
            <SettingsPanel />
          </Flex.Item>
        ) || (
          <ChatPanel lineHeight={settings.lineHeight} />
        )}
      </DraggableControl>
      <Section height={(number-1) + '%'}>
        <Pane.Content scrollable>
          <Button
            style={{
              position: 'fixed',
              bottom: '3em',
              right: '2em',
              'z-index': 1000,
            }}
            selected={settings.visible}
            onClick={() => settings.toggle()}>
            Settings
          </Button>
          {settings.visible && (
            <Stack.Item>
              <SettingsPanel />
            </Stack.Item>
          ) || (
            <ChatPanel lineHeight={settings.lineHeight} />
          )}
        </Pane.Content>
      </Section>
    </Pane>
  );
};
