import { useBackend } from '../backend';
import { Box, Button, Flex, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

export const NtosLogViewer = (props, context) => {
  const { act, data } = useBackend(context);
  const { PC_device_theme } = data;
  return (
    <NtosWindow resizable theme={PC_device_theme}>
      <NtosWindow.Content>
        <NtosLogViewerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosLogViewerContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { files, hasactivefile, Log } = data;
  return (
    <Flex
      direction={"column"}>
      <Flex.Item
        position="relative"
        mb={1}>
        <Section height={20}>
          <NtosWindow.Content scrollable mt={0}>
            <Table>
              <Table.Row header>
                <Table.Cell>
                  File
                </Table.Cell>
                <Table.Cell collapsing>
                  Type
                </Table.Cell>
                <Table.Cell collapsing>
                  Size
                </Table.Cell>
              </Table.Row>
              {files.map(file => (
                <Table.Row key={file.name} className="candystripe">
                  <Table.Cell>
                    {file.name}
                  </Table.Cell>
                  <Table.Cell>
                    {file.type}
                  </Table.Cell>
                  <Table.Cell>
                    {file.size}
                  </Table.Cell>
                  <Table.Cell collapsing>
                    {!!file.openable && (
                      <Button
                        icon="eye"
                        onClick={() => act('PRG_Open', { name: file.name })} />
                    )}
                    {!!file.printable && (
                      <Button
                        icon="print"
                        onClick={() => act('PRG_Print', { name: file.name })} />
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </NtosWindow.Content>
        </Section>
      </Flex.Item>
      <Flex.Item>
        <Section
          backgroundColor="black"
          height={32}>
          <NtosWindow.Content scrollable mt={0}>
            {Log.map(logentry => (
              <Box
                mb={1}
                key={logentry}>
                <font color="green">{logentry}</font>
              </Box>
            ))}
          </NtosWindow.Content>
        </Section>
      </Flex.Item>
    </Flex>
  );
};

