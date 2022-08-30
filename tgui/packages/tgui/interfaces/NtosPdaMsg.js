/* eslint operator-linebreak: 0 */
// https://github.com/jsx-eslint/eslint-plugin-react/issues/454
/* eslint react/jsx-indent: 0 */
// Abiding by 'react/jsx-indent' on lines 43-50 makes 'indent' unhappy and vice versa.
// This one has only one error while indent has 7 so I'm opting to listen to that one

import { useBackend } from '../backend';
import { Box, Button, Section, Grid } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPdaMsg = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    can_message,
    can_keytry,
    username,
    receiving,
    silent,
    authed,
    message_history = [],
    pdas = [],
    all_messages = [],
    ringtone,
    showing_messages,
  } = data;
  return (
    <NtosWindow
      width={400}
      height={480}>
      <NtosWindow.Content scrollable>
        {showing_messages ?
          <Box>
            <Section
              title="Message History"
              buttons={(
                <Box>
                  <Button.Confirm
                    content="Clear"
                    onClick={() => act('PRG_clearhistory')} />
                  {authed ? <Button
                    content="Logout"
                    onClick={() => act('PRG_logout')} /> :
                    <Button.Input
                      content="Admin Login"
                      disabled={!can_keytry}
                      color={can_keytry ? 'blue' : 'grey'}
                      currentValue="Monitor Key"
                      onCommit={(e, value) => act('PRG_keytry', {
                        message: value,
                      })} />}
                  <Button
                    content="Back"
                    onClick={() => act('PRG_closehistory')} />
                </Box>
              )}>
              {authed ? all_messages.map((msgdata, index) => // sender.username, username, message
                (
                  <Section title={'"'+msgdata[0]+'" => "'+msgdata[1]+'"'} key={'admin'+index}>
                    {msgdata[2]}
                  </Section>
                )
              ) : message_history.map((msgdata, index) => // sender.username, message, REF(sender)
                (
                  <Box key={'nonadmin'+index}>
                    <Button.Input
                      content={'From '+msgdata[0]}
                      onCommit={(e, value) => act('PRG_sendmsg', {
                        recipient: msgdata[2],
                        message: value,
                      })} />
                    {', "'+msgdata[1]+'"'}
                  </Box>
                )
              )}
            </Section>
          </Box> :
          <Box>
            <Section
              title="SpaceMessenger V4.0.0"
              buttons={(
                <Button
                  content="Messages"
                  onClick={() => act('PRG_showhistory')} />
              )}>
              <Grid>
                <Grid.Column>
                  <Button
                    fluid
                    content={silent ? 'Ringer: Off' : 'Ringer: On'}
                    selected={!silent}
                    color="bad"
                    onClick={() => act(silent ? 'PRG_audible' : 'PRG_silence')} />
                </Grid.Column>
                <Grid.Column>
                  <Button
                    fluid
                    content={receiving ? 'Send / Receive: On' : 'Send / Receive: Off'}
                    selected={receiving}
                    color="bad"
                    onClick={() => act(receiving ? 'PRG_norecieve' : 'PRG_yesrecieve')} />
                </Grid.Column>
              </Grid>
              <Grid>
                <Grid.Column>
                  <Button.Input
                    fluid
                    content="Set Ringtone"
                    currentValue={ringtone}
                    onCommit={(e, value) => act('PRG_ringtone', {
                      name: value,
                    })} />
                </Grid.Column>
                <Grid.Column>
                  <Button.Input
                    fluid
                    content={username}
                    currentValue={username}
                    onCommit={(e, value) => act('PRG_namechange', {
                      name: value,
                    })} />
                </Grid.Column>
              </Grid>
            </Section>
            <Section title="Detected PDAs">
              {pdas.map((pdadata, index) => // P.username, REF(P), blocked_users.Find(P)
                (
                  <Grid key={'pda'+index}>
                    <Grid.Column size={4}>
                      <Button.Input
                        fluid
                        content={pdadata[0].substring(0, 35)}
                        disabled={!can_message || !receiving}
                        color={can_message && receiving ? 'blue' : 'primary'}
                        onCommit={(e, value) => act('PRG_sendmsg', {
                          recipient: pdadata[1],
                          message: value,
                        })} />
                    </Grid.Column>
                    <Grid.Column>
                      <Button
                        fluid
                        content={pdadata[2] ? 'Unblock' : 'Block'}
                        color={pdadata[2] ? 'blue' : 'bad'}
                        onClick={() => act(pdadata[2] ? 'PRG_unblock' : 'PRG_block', {
                          recipient: pdadata[1],
                        })} />
                    </Grid.Column>
                  </Grid>
                )
              )}
            </Section>
          </Box>}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
