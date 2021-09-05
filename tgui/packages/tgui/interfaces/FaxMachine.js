import { useBackend } from "../backend";
import { Button, Dropdown, Section } from "../components";
import { Window } from "../layouts";


export const FaxMachine = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    authenticated,
    auth_name,
    has_copy,
    copy_name,
    cooldown,
    depts,
    destination,
  } = data
  return (
    <Window
      width={700}
      height={700}
      resizable>
      <Window.Content scrollable>
        {!authenticated && (
          <Section>
            <Button
              onClick={() => act('auth')}>
              Log in
            </Button>
          </Section>
        )}
        {!!authenticated && (
          <Section
            title="Fax Machine"
            buttons={(
              <Button
                onClick={() => act('logout')}>
                Log Out
              </Button>
            )}>
            {!has_copy && (
              "Insert paper to fax"
            )}
            {!!has_copy && (
              <Section
                level={2}>
                <Button icon="eject" onClick={() => act('remove')}>Eject '{copy_name}'</Button><br />
                Department: 
                <Dropdown 
                  options={depts}
                  selected={destination}
                  width="250px"
                  onSelected={value => act('set_dept', {
                    dept: value,
                  })}/><br />
                <Button onClick={() => act('send')}>Send!</Button>
              </Section>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
