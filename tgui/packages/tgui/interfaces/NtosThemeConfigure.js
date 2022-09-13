import { useBackend } from '../backend';
import { Box, Button, Section, Grid, Flex } from '../components';
import { NtosWindow } from '../layouts';

export const NtosThemeConfigure = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    PC_device_theme,
    themes = [],
  } = data;
  return (
    <NtosWindow
      theme={PC_device_theme}
      width={420}
      height={630}
      resizable>
      <NtosWindow.Content scrollable>
        <Flex
          width="100%"
          height="100%"
          direction="column"
          textAlign="center"
          align-items="center">
          {themes.map(theme => (
            <Flex.Item
              key={theme}
              width="100%"
              grow={1}>
              <Button.Checkbox
                checked={theme===PC_device_theme}
                width="75%"
                lineHeight="50px"
                content={theme}
                onClick={() => act('change_theme', {
                  theme: theme,
                })} />
            </Flex.Item>
          ))}
        </Flex>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

