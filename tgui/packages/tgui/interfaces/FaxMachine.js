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
  } = data;
  return (
    <Window
      width={420}
      height={215}
      resizable>
      <Window.Content scrollable>
        {!authenticated && (
          <Section>
            <Button
              icon="sign-in-alt"
              onClick={() => act('auth')}>
              Log in
            </Button>
          </Section>
        )}
        {!!authenticated && (
          <Section
            title="Fax Machine"
            fill
            buttons={(
              <Button
                icon="sign-out-alt"
                color="bad"
                onClick={() => act('logout')}>
                Log Out ({auth_name})
              </Button>
            )}>
            {!has_copy && (
              "Insert paper to fax"
            )}
            {!!has_copy && (
              <Section
                level={2}>
                <Button icon="eject" onClick={() => act('remove')}>Eject &apos;{copy_name}&apos;</Button><br /><br />
                <Dropdown
                  options={depts}
                  selected={destination}
                  width="250px"
                  onSelected={value => act('set_dept', {
                    dept: value,
                  })} /><br />
                <Button
                  disabled={cooldown > 0}
                  onClick={() => act('send')}>
                  Send!
                </Button><br />
                {cooldown > 0 && (
                  <div>
                    Transmitter Recharged In: {Math.floor(cooldown / 10)}s
                  </div>
                )}
              </Section>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
