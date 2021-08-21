
import { useBackend, useLocalState } from '../backend';
import { Section, Button, Table, Input, TextArea, Box } from '../components';
import { Window } from '../layouts';
import { KEY_ENTER } from 'common/keycodes';

export const TicketPanel = (props, context) => {
  const { act, data } = useBackend(context);

  if (data.is_admin) {
    return (
      <Window
        title="Ticket Viewer"
        width={700}
        height={700}
        resizable
        backgroundColor='pink'>
        <Window.Content scrollable>
          <Section
            title={data.initiator_key_name + ": " + data.name}>
            <span class='Section__titleText' style="font-weight:normal">
            Assigned Admin: <b>{data.admin || "Unassigned"}</b><br />
            <span class={data.is_resolved ? "color-good" : "color-bad"}>
              Is{data.is_resolved ? "" : " not"} resolved
            </span>
            </span>
            <Section
              level="2"
              m="-5px">
              Job: <b>{data.role}</b> <br />
              Antag: <b>{data.antag || "No"}</b><br />
              Location: <b>{data.location}</b>
            </Section>
            <Section
              m="-5px"
              level="2">
              <Button
                icon="question"
                enabled={data.has_mob}
                onClick={() => act('adminmoreinfo')} />
              <Button
                icon="user"
                enabled={data.has_mob}
                onClick={() => act('PP')}>
                PP
              </Button>
              <Button
                icon="cog"
                enabled={data.has_mob}
                onClick={() => act('VV')}>
                VV
              </Button>
              <Button
                icon="envelope"
                enabled={data.has_mob}
                onClick={() => act('SM')}>
                SM
              </Button>
              <Button
                icon="arrow-up"
                enabled={data.has_mob}
                onClick={() => act('FLW')}>
                FLW
              </Button>
              <Button
                icon="fire"
                enabled={data.has_mob}
                onClick={() => act('TP')}>
                TP
              </Button>
              <Button
                icon="file"
                enabled={data.has_mob}
                onClick={() => act('Logs')}>
                Logs
              </Button>
              <Button
                icon="bolt"
                enabled={data.has_mob}
                onClick={() => act('Smite')}>
                Smite
              </Button>
              <Button
                icon="users"
                onClick={() => act('CA')}>
                CA
              </Button>
              <Button
                icon="folder-open"
                onClick={() => act('Administer')}>
                Administer
              </Button>
              <Button
                icon="check"
                onClick={() => act('Resolve')}>
                {data.is_resolved ? "Unresolve" : "Resolve"}
              </Button>
              <Button
                icon="ban"
                enabled={data.has_client}
                onClick={() => act('Reject')}>
                Reject
              </Button>
              <Button
                icon="times"
                onClick={() => act('Close')}>
                Close
              </Button>
              <Button
                icon="male"
                enabled={data.has_client}
                onClick={() => act('IC')}>
                IC
              </Button>
              <Button
                icon="film"
                enabled={data.has_mob}
                onClick={() => act('Wiki')}>
                Wiki
              </Button>
              <Button
                icon="bug"
                enabled={data.has_mob}
                onClick={() => act('Bug')}>
                Bug
              </Button>
              <Button
                icon="info"
                enabled={data.has_client}
                onClick={() => act('MHelp')}>
                MHelp
              </Button>
              <Button
                selected={data.popups}
                icon="window-restore"
                onClick={() => act('togglePopups')}>
                {data.popups ? "Deactivate Popups" : "Activate Popups"}
              </Button>
            </Section>
          </Section>
          <TicketMessages
            ticket={data}
            title="Messages" />
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window
      title="Ticket Viewer"
      width={700}
      height={700}
      resizable>
      <Window.Content scrollable>
        <TicketMessages
          title={data.name}
          ticket={data} />
      </Window.Content>
    </Window>
  );

};

export const TicketMessages = (props, context) => {
  const { ticket, title } = props;
  const { act } = useBackend(context);

  const [
    message,
    setMessage,
  ] = useLocalState(context, 'text', "");

  return (
    <Section
      title={title}>
      {ticket.log.map(entry => (!entry.for_admins || ticket.is_admin) && (
        <Box key={entry.time} m="2px">
          {entry.time} - <b>{entry.user}</b> - {entry.text}
        </Box>
      ) || "")}
      <Input
        mt="10px"
        fluid
        placeholder="Message to send"
        selfclear
        value={message}
        lineHeight={1.75}
        onChange={(e, value) => {
          if (e.keyCode === KEY_ENTER) {
            setMessage('');
            e.target.value = message;
            act('send_message', { 'message': value });
          } else {
            setMessage(value);
          }
        }} />
      <Button
        mt="5px"
        onClick={() => {
          act('send_message', { 'message': message });
          setMessage('');
        }}>
        Send Message
      </Button>
    </Section>
  );

};
