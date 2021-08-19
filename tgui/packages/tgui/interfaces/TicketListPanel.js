
import { useBackend } from '../backend';
import { Section, Collapsible, Button } from '../components';
import { Window } from '../layouts';

export const TicketListPanel = (props, context) => {
  const { act, data } = useBackend(context);

  const open_count = data.unresolved_tickets.length;
  const closed_count = data.resolved_tickets.length;
  const total_count = open_count + closed_count;

  return (
    <Window
      title="Admin Ticket Viewer"
      width={700}
      height={700}
      resizable>
      <Window.Content scrollable>
        <Collapsible
          className="Section__titleText"
          color={open_count == 0 ? 'default' : 'red'}
          open
          title={"Unresolved Tickets (" + open_count + "/" + total_count + ")"}>
          {data.unresolved_tickets.map(ticket => (
            <TicketSummary
              key={ticket.id}
              ticket={ticket}/>
          ))}
        </Collapsible>
        <Collapsible
          className="Section__titleText"
          color="green"
          title={"Resolved Tickets (" + closed_count + "/" + total_count + ")"}>
          {data.resolved_tickets.map(ticket => (
            <TicketSummary
            key={ticket.id}
            ticket={ticket}/>
          ))}
        </Collapsible>
      </Window.Content>
    </Window>
  );
};

export const TicketSummary = (props, context) => {
  const { ticket } = props
  const { act } = useBackend(context);

  return (
    <Section
      className = "clown"
      backgroundColor = {ticket.admin_key || !ticket.active ? "" : "bad"}
      title={"#" + ticket.id + ": " + ticket.name}>
      Owner: {ticket.initiator_key_name} <br />
      Admin: {ticket.admin_key ? ticket.admin_key : "UNCLAIMED"}
      <Section
        level = "2">
        <Button
          onClick={() => act('view', {
            'id': ticket.id
          })}>
          View
        </Button>
        <Button
          onClick={() => act('adminmoreinfo', {
            'id': ticket.id
          })}>
          ?
        </Button>
        <Button
          onClick={() => act('VV', {
            'id': ticket.id
          })}>
          VV
        </Button>
        <Button
          onClick={() => act('PP', {
            'id': ticket.id
          })}>
          PP
        </Button>
        <Button
          onClick={() => act('SM', {
            'id': ticket.id
          })}>
          SM
        </Button>
        <Button
          onClick={() => act('FLW', {
            'id': ticket.id
          })}>
          FLW
        </Button>
        <Button
          onClick={() => act('CA', {
            'id': ticket.id
          })}>
          CA
        </Button>
        <Button
          onClick={() => act('Resolve', {
            'id': ticket.id
          })}>
          Resolve
        </Button>
        <Button
          onClick={() => act('Reject', {
            'id': ticket.id
          })}>
          Reject
        </Button><Button
          onClick={() => act('Close', {
            'id': ticket.id
          })}>
          Close
        </Button>
        <Button
          onClick={() => act('IC', {
            'id': ticket.id
          })}>
          IC
        </Button>
      </Section>
    </Section>
  )
}
