import { useBackend } from '../backend';
import { Box, Button, Section, Grid, Flex } from '../components';
import { NtosWindow } from '../layouts';

export const NtosThemeConfigure = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    PC_device_theme,
    theme_collection = [],
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
          {theme_collection.map(theme => (
            <Flex.Item
              key={theme}
              width="100%"
              grow={1}>
              <Button.Checkbox
                checked={theme.theme_file===PC_device_theme}
                width="75%"
                lineHeight="50px"
                content={theme.theme_name}
                onClick={() => act('PRG_change_theme', {
                  theme_title: theme.theme_name,
                })} />
            </Flex.Item>
          ))}
        </Flex>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

