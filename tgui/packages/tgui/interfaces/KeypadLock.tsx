import { classes } from "common/react";
import { useBackend } from '../backend';
import { Box, Button, Flex, Grid } from '../components';
import { Window } from '../layouts';

type Data = {
  lock_status_display: string;
  keypad_code_display: string;
};

const SecureKeypad = (props, context) => {
  const { act } = useBackend(context);
  const keypadKeys = [
    ['1', '4', '7', 'R'],
    ['2', '5', '8', '0'],
    ['3', '6', '9', 'E'],
  ];
  return (
    <Box width="400px">
      <Grid width="1px">
        {keypadKeys.map(keyColumn => (
          <Grid.Column key={keyColumn[0]}>
            {keyColumn.map(key => (
              <Button
                fluid
                bold
                key={key}
                mb="6px"
                content={key}
                textAlign="center"
                fontSize="40px"
                lineHeight={1.25}
                width="125px"
                className={classes([
                  'KeypadLock__Button',
                  'KeypadLock__Button--keypad',
                  'KeypadLock__Button--' + key,
                ])}
                onClick={() => act('keypad', { digit: key })} />
            ))}
          </Grid.Column>
        ))}
      </Grid>
    </Box>
  );
};

export const KeypadLock = (props, context) => {
  const { data } = useBackend<Data>(context);

  const { lock_status_display } = data;
  const { keypad_code_display } = data;
  return (
    <Window
      width={400}
      height={370}
      theme="ntos_darkmode">
      <Window.Content>
        <Box m="6px">
          <Box
            mb="6px"
            textAlign="center"
            className="KeypadLock__displayBox">
            {lock_status_display}
          </Box>
          <Flex mb={1.5}>
            <Flex.Item grow={1}>
              <Box
                textAlign="center"
                className="KeypadLock__displayBox">
                {keypad_code_display}
              </Box>
            </Flex.Item>
          </Flex>
        </Box>
        <Flex.Item>
          <SecureKeypad />
        </Flex.Item>
      </Window.Content>
    </Window>
  );
};
