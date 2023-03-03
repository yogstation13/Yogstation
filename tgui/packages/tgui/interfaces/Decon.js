import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Box, Button, Icon, Table, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const Decon = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    locked,
    open,
    safeties,
    uv_active,
    occupied,
    contents,
    name,
  } = data;
  return (
    <Window
      width={400}
      height={305}>
      <Window.Content>
        {!!(occupied && safeties) && (
          <NoticeBox>
            Biological entity detected in suit chamber. Please remove
            before continuing with operation.
          </NoticeBox>
        )}
        {uv_active && (
          <NoticeBox>
            Contents are currently being decontaminated. Please wait.
          </NoticeBox>
        ) || (
          <Section
            title="Storage"
            minHeight="260px"
            buttons={(
              <Fragment>
                {!open && (
                  <Button
                    icon={locked ? 'unlock' : 'lock'}
                    content={locked ? 'Unlock' : 'Lock'}
                    onClick={() => act('lock')} />
                )}
                {!locked && (
                  <Button
                    icon={open ? 'sign-out-alt' : 'sign-in-alt'}
                    content={open ? 'Close' : 'Open'}
                    onClick={() => act('door')} />
                )}
              </Fragment>
            )}>
            {locked && (
              <Box
                mt={6}
                bold
                textAlign="center"
                fontSize="40px">
                <Box>Unit Locked</Box>
                <Icon name="lock" />
              </Box>
            ) || open && (
              contents.length === 0 && (
                <NoticeBox>
                  Unfortunately, this {name} is empty.
                </NoticeBox>
              ) || (
                <Table>
                  <Table.Row header>
                    <Table.Cell>
                      Item
                    </Table.Cell>
                    <Table.Cell collapsing />
                    <Table.Cell collapsing textAlign="center">
                      Dispense
                    </Table.Cell>
                  </Table.Row>
                  {map((value, key) => (
                    <Table.Row key={key}>
                      <Table.Cell>
                        {value.name}
                      </Table.Cell>
                      <Table.Cell collapsing textAlign="right">
                        {value.amount}
                      </Table.Cell>
                      <Table.Cell collapsing>
                        <Button
                          content="One"
                          disabled={value.amount < 1}
                          onClick={() => act('Release', {
                            name: value.name,
                            amount: 1,
                          })} />
                        <Button
                          content="Many"
                          disabled={value.amount <= 1}
                          onClick={() => act('Release', {
                            name: value.name,
                          })} />
                      </Table.Cell>
                    </Table.Row>
                  ))(contents)}
                </Table>
              )
            ) || (
              <Button
                fluid
                icon="recycle"
                content="Decontaminate"
                disabled={occupied && safeties}
                textAlign="center"
                onClick={() => act('uv')} />
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
