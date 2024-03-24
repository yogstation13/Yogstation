import { useBackend } from '../backend';
import { Box, Button, Grid, Flex } from '../components';
import { NtosWindow } from '../layouts';

export const NtosSynthManager = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    PC_device_theme,
    PC_emagged,
    granted_access,
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
            {!!data.hos && (
              <Flex.Item
              width="100%"
              grow={1}>
              <Button.Checkbox
                checked={granted_access[0].sec}
                width="75%"
                lineHeight="50px"
                content={"Security"}
                onClick={() => act('grant_security')} />
              </Flex.Item>
            )}
            {!!data.rd && (
            <Flex.Item
              width="100%"
              grow={1}>
              <Button.Checkbox
                checked={granted_access[0].sci}
                width="75%"
                lineHeight="50px"
                content={"Science"}
                onClick={() => act('grant_science')} />
            </Flex.Item>
            )}
            {!!data.cmo && (
            <Flex.Item
              width="100%"
              grow={1}>
              <Button.Checkbox
                checked={granted_access[0].med}
                width="75%"
                lineHeight="50px"
                content={"Medical"}
                onClick={() => act('grant_medical')} />
            </Flex.Item>
            )}
            {!!data.hop && (
            <Flex.Item
              width="100%"
              grow={1}>
              <Button.Checkbox
                checked={granted_access[0].sup}
                width="75%"
                lineHeight="50px"
                content={"Supply"}
                onClick={() => act('grant_supply')} />
            </Flex.Item>
            )}
            {!!data.ce && (
            <Flex.Item
              width="100%"
              grow={1}>
              <Button.Checkbox
                checked={granted_access[0].eng}
                width="75%"
                lineHeight="50px"
                content={"Engineering"}
                onClick={() => act('grant_engi')} />
            </Flex.Item>
            )}
        </Flex>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

