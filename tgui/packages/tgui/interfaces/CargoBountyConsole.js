import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, NoticeBox, Section, Table, Flex } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const CargoBountyConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    bountydata = [],
    is_packager,
    has_id,
    name,
    job,
    orig_job,
  } = data;
  return (
    <Window
      width={750}
      height={375}
      resizable>
      <Window.Content scrollable>
        <NoticeBox success={has_id && is_packager} danger={!is_packager}>
          {has_id && (
            <Flex align="center">
              <Flex.Item>
                Welcome {name} ({job})
              </Flex.Item>
              <Flex.Item grow={1} textAlign="center" >
                {!is_packager && " ERROR: NO LINK TO PACKAGER" || ""}
              </Flex.Item>
              <Flex.Item>
                <Button onClick={() => act("Eject")}>
                  Eject ID
                </Button>
              </Flex.Item>
            </Flex>
          ) || ""}
          {!has_id && is_packager && (
            "No ID Detected"
          ) || ""}
          {!has_id && !is_packager && (
            "ERROR: NO LINK TO PACKAGER"
          ) || ""}
        </NoticeBox>
        {has_id && (
          <Section
            buttons={(
              <Button
                onClick={() => act("ReloadBounties")}>
                Refresh Bounties
              </Button>
            )}
            title={`${orig_job} bounties`}>
            <Table border>
              <Table.Row
                bold
                italic
                color="label"
                fontSize={1.25}>
                <Table.Cell p={1} textAlign="center">
                  Bounty Object
                </Table.Cell>
                <Table.Cell p={1} textAlign="center">
                  Description
                </Table.Cell>
                <Table.Cell p={1} textAlign="center">
                  Progress
                </Table.Cell>
                <Table.Cell p={1} textAlign="center">
                  Value
                </Table.Cell>
                <Table.Cell p={1} textAlign="center">
                  Claim
                </Table.Cell>
              </Table.Row>
              {bountydata.map(bounty => (
                <Table.Row
                  key={bounty.name}
                  backgroundColor={bounty.priority === 1
                    ? 'rgba(252, 152, 3, 0.25)'
                    : ''}>
                  <Table.Cell bold p={1}>
                    {bounty.name}
                  </Table.Cell>
                  <Table.Cell
                    italic
                    textAlign="center"
                    p={1}>
                    {bounty.description}
                  </Table.Cell>
                  <Table.Cell
                    bold
                    p={1}
                    textAlign="center">
                    {bounty.priority === 1
                      ? <Box>High Priority</Box>
                      : ""}
                    {bounty.completion_string}
                  </Table.Cell>
                  <Table.Cell
                    bold
                    p={1}
                    textAlign="center">
                    {bounty.reward_string}
                  </Table.Cell>
                  <Table.Cell
                    bold
                    p={1}>
                    <Button
                      fluid
                      textAlign="center"
                      icon={bounty.claimed === 1
                        ? "check"
                        : ""}
                      content={bounty.claimed === 1
                        ? "Claimed"
                        : (bounty.selected === 1 ? "Selected" : "Select")}
                      disabled={bounty.claimed === 1 || bounty.selected || !is_packager}
                      color={bounty.selected === 1
                        ? 'green'
                        : 'red'}
                      onClick={() => act('SelectBounty', {
                        bounty: bounty.bounty_ref,
                      })} />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        ) || ""}
      </Window.Content>
    </Window>
  );
};
