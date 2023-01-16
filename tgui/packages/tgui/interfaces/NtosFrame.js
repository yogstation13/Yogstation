import { useBackend } from '../backend';
import { Box, Button, Section, Grid } from '../components';
import { NtosWindow } from '../layouts';

export const NtosFrame = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    bombcode,
    pdas = [],
  } = data;
  return (
    <NtosWindow
      width={400}
      height={480}
      theme="syndicate">
      <NtosWindow.Content scrollable>
        <Box>
          <Section
            title="SyndieMessenger V4.0.0"
            buttons={(
              <Button
                content="Messages" />
            )}>
            <Grid>
              <Grid.Column>
                <Button
                  fluid
                  content="Ringer: STEALTHY :)"
                  color="bad" />
              </Grid.Column>
              <Grid.Column>
                <Button
                  fluid
                  content="Send / Receive: YES"
                  selected />
              </Grid.Column>
            </Grid>
            <Grid>
              <Grid.Column>
                <Button
                  fluid
                  content="CODE GOES THERE ---->" />
              </Grid.Column>
              <Grid.Column>
                <Button.Input
                  fluid
                  content={bombcode}
                  currentValue={bombcode}
                  onCommit={(e, value) => act('PRG_codechange', {
                    newcode: value,
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
                      disabled
                      color="primary" />
                  </Grid.Column>
                  <Grid.Column>
                    <Button
                      fluid
                      content="FRAME"
                      color="bad"
                      onClick={() => act('PRG_sendframe', {
                        recipient: pdadata[1],
                      })} />
                  </Grid.Column>
                </Grid>
              )
            )}
          </Section>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
