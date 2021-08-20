
import { useBackend, useLocalState } from '../backend';
import { Section, Button, Table, Input } from '../components';
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
        resizable>
        <Window.Content scrollable>
          <Section
            title={data.initiator_key_name + ": " + data.name}>
            Primary Admin: {data.admin || "Unassigned"}<br />
            <span class={data.is_resolved ? "color-good" : "color-bad"}>
              Is{data.is_resolved ? "" : " not"} resolved
            </span>
            <Section
              level="2">
              Job: {data.role} <br />
              Antag: {data.antag || "No"}<br />
              Location: {data.location}
            </Section>
            <Section
              level="2">
              <Button
                enabled={data.has_mob}
                onClick={() => act('adminmoreinfo')}>
                ?
              </Button>
              <Button
                enabled={data.has_mob}
                onClick={() => act('PP')}>
                PP
              </Button>
              <Button
                enabled={data.has_mob}
                onClick={() => act('VV')}>
                VV
              </Button>
              <Button
                enabled={data.has_mob}
                onClick={() => act('SM')}>
                SM
              </Button>
              <Button
                enabled={data.has_mob}
                onClick={() => act('FLW')}>
                FLW
              </Button>
              <Button
                onClick={() => act('CA')}>
                CA
              </Button>
              <Button
                onClick={() => act('Administer')}>
                Administer
              </Button>
              <Button
                onClick={() => act('Resolve')}>
                {data.is_resolved ? "Unresolve" : "Resolve"}
              </Button>
              <Button
                enabled={data.has_client}
                onClick={() => act('Reject')}>
                Reject
              </Button>
              <Button
                onClick={() => act('Close')}>
                Close
              </Button>
              <Button
                enabled={data.has_client}
                onClick={() => act('IC')}>
                IC
              </Button>
              <Button
                enabled={data.has_client}
                onClick={() => act('MHelp')}>
                MHelp
              </Button>
              <Button
                onClick={() => act('togglePopups')}>
                Activate Popups
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
  const { ticket, title } = props
  const { act } = useBackend(context);

  const [
    message,
    setMessage,
  ] = useLocalState(context, 'text', "");

  return (
    <Section
      title={title}>
      <Table>
        {ticket.log.map(entry => (!entry.for_admins || ticket.is_admin) && (
          <Table.Row key={entry.text}>
            <Table.Cell>
              {entry.text}
            </Table.Cell>
          </Table.Row>
        ) || "")}
      </Table>
      <Input
        width="80%"
        placeholder="Message to send"
        selfclear
        value={message}
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
        onClick={() => {
          act('send_message', { 'message': message });
          setMessage('');
        }}>
        Send Message
      </Button>
    </Section>
  )

};
