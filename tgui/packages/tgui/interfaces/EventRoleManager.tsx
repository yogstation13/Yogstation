import { KEY_ENTER } from '../../common/keycodes';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, NoticeBox, Section, ProgressBar, Table, Box, Input, Dropdown } from '../components';
import { Window } from '../layouts';

type RoleManagerContext = {
  assignments: Assignment[];
  jobs: string[];
};

type Assignment = {
  ckey: string;
  title: string;
  role_alt_title: string
}

export const EventRoleManager = (props, context) => {
  const { data, act } = useBackend<RoleManagerContext>(context);
  const { assignments, jobs } = data;

  const [
    message,
    setMessage,
  ] = useLocalState(context, 'text', '');

  return (
    <Window width={700}
      height={700}
      title="Event Role Manager"
      resizable>
      <Window.Content>
        <Section fill title="Role Assignments" buttons={(
          <Box>
            <Input value={message} onChange={(e, value) => {
              if (e.keyCode === KEY_ENTER) {
                act('addCkey', { 'ckey': value });
                e.target.value = '';
                setMessage('');
              } else {
                setMessage(value);
              }
            }} />
            <Button icon="plus" color="good" onClick={(e, value) => {
              act('addCkey', { 'ckey': message });
              setMessage('');
            }} />
          </Box>
        )}>
          <Table>
            <Table.Row>
              <Table.Cell>
                Ckey
              </Table.Cell>
              <Table.Cell>
                Job
              </Table.Cell>
              <Table.Cell pl="10px">
                Title
              </Table.Cell>
            </Table.Row>
            {assignments.map(assignment => (
              <Table.Row key={assignment.ckey}>
                <Table.Cell width="150px">
                  {assignment.ckey}
                </Table.Cell>
                <Table.Cell collapsing py="3px">
                  <Dropdown width="200px" selected={assignment.title} options={jobs} onSelected={value => act("setTitle", { ckey: assignment.ckey, title: value })} />
                </Table.Cell>
                <Table.Cell px="10px">
                  <Input value={assignment.role_alt_title} width="100%" onChange={(e, value) => {
                    act("setAltTitle", { ckey: assignment.ckey, alt_title: value });
                  }} />
                </Table.Cell>
                <Table.Cell collapsing>
                  <Button icon="trash" color="bad" onClick={() => act('removeCkey', { ckey: assignment.ckey })} />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
