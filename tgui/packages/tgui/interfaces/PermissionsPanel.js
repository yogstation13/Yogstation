import { useBackend, useLocalState } from "../backend";
import { Box, Button, Collapsible, Flex, Section, Tabs } from "../components";
import { Layout, Window } from "../layouts";
import { createLogger } from "../logging";

const logger = createLogger('PermissionsPanel')

export const PermissionsPanel = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Permissions Panel"
      width={600}
      height={500}
      resizable >
      <Window.Content scrollable>
        <Button
          icon="plus"
          color="green"
          mb={1}
          onClick={() => act('addNewAdmin')}>
            Add New
          </Button>
      {data.admins.map((admin, i) => (
        <AdminDisplay
          key = {i}
          data = {admin}
          act = {act} />
      ))}
      </Window.Content>
    </Window>
  );
};

export const AdminDisplay = props => {
  const { data, act } = props
  const {
    ckey,
    rank,
    protected_admin,
    protected_rank,
    rights,
    deadminned
  } = data;
  return (
    <Section
      title={`${ckey} - ${rank}`}
      buttons={(
        <Button
          icon='trash'
          color="bad"
          onClick={() => act('removeAdmin', {
            ckey: ckey
          })} />
      )} >
        <Button onClick={() => act('forceSwapAdmin', {
          ckey: ckey
        })}>
          Force { deadminned ? "Re" : "De" }admin
        </Button>
        <Button onClick={() => act('resetMFA', {
          ckey: ckey
        })}>
          Reset MFA
        </Button>
        <Button
          disabled={protected_admin}
          onClick={() => act('editRank', {
            ckey: ckey
          })}>
          Change Rank
        </Button>
        <Collapsible
          title="Permissions"
          buttons={(
            <Button
              icon="edit"
              content="Edit"
              disabled={protected_rank}
              onClick={() => act('editPerms', {
                ckey: ckey
              })}/>
          )}>
          { rights }
        </Collapsible>
    </Section>
  );
}
