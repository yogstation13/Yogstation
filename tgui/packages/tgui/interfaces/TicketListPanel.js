
import { useBackend, useLocalState } from '../backend';
import { Section, Collapsible, Button, Tabs } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';

export const TicketListPanel = (props, context) => {
  const { act, data } = useBackend(context);

  const FILTERS = [
    "ALL",
    "MY TICKETS",
    "UNCLAIMED",
  ];

  const [filterType, setFilterType] = useLocalState(context, 'filterType', FILTERS[0]);

  return (
    <Window
      title="Admin Ticket Viewer"
      width={700}
      height={700}
      resizable>
      <Window.Content scrollable>
        <Tabs>
          {FILTERS.map(filter => (
            <Tabs.Tab
              key={filter}
              selected={filter === filterType}
              onClick={() => setFilterType(filter)}>
              {filter}
            </Tabs.Tab>
          ))}
        </Tabs>
        <TicketListView
          data={data}
          filter_type={filterType} />
      </Window.Content>
    </Window>
  );
};

export const TicketListView = (props, context) => {
  const { data, filter_type } = props;
  const { act } = useBackend(context);

  const open_count = data.unresolved_tickets.length;
  const closed_count = data.resolved_tickets.length;
  const total_count = open_count + closed_count;

  const filterTicket = function (ticket) {
    if (filter_type === "ALL") return true;
    if (filter_type === "MY TICKETS" && ticket.admin_key === data.user_key) return true;
    if (filter_type === "UNCLAIMED" && !ticket.admin_key) return true;
    return false;
  };

  return (
    <Fragment>
      <Collapsible
        className="Section__titleText"
        color={open_count === 0 ? 'default' : 'red'}
        open
        title={"Unresolved Tickets (" + open_count + "/" + total_count + ")"}>
        {data.unresolved_tickets.filter(filterTicket).map(ticket => (
          <TicketSummary
            key={ticket.id}
            ticket={ticket} />
        ))}
      </Collapsible>
      <Collapsible
        className="Section__titleText"
        color="green"
        title={"Resolved Tickets (" + closed_count + "/" + total_count + ")"}>
        {data.resolved_tickets.filter(filterTicket).map(ticket => (
          <TicketSummary
            key={ticket.id}
            ticket={ticket} />
        ))}
      </Collapsible>
    </Fragment>
  );
};

export const TicketSummary = (props, context) => {
  const { ticket } = props;
  const { act } = useBackend(context);

  return (
    <Section
      backgroundColor={ticket.admin_key || !ticket.active ? "" : "bad"}
      title={"#" + ticket.id + ": " + ticket.name}>
      Owner:
      <Button
        icon="reply"
        onClick={() => act('reply', {
          'id': ticket.id,
        })}>
        {ticket.initiator_key_name}
      </Button><br />
      Admin: {ticket.admin_key ? ticket.admin_key : "UNCLAIMED"}<br />
      <span class="color-bad">{!ticket.has_client ? "DISCONNECTED" : ""}</span>
      <Section
        level="2">
        <Button
          icon="eye"
          onClick={() => act('view', {
            'id': ticket.id,
          })}>
          View
        </Button>
        <Button
          icon="question"
          disabled={!ticket.has_mob}
          onClick={() => act('adminmoreinfo', {
            'id': ticket.id,
          })} />
        <Button
          icon="user"
          disabled={!ticket.has_mob}
          onClick={() => act('PP', {
            'id': ticket.id,
          })}>
          PP
        </Button>
        <Button
          icon="cog"
          disabled={!ticket.has_mob}
          onClick={() => act('VV', {
            'id': ticket.id,
          })}>
          VV
        </Button>
        <Button
          icon="envelope"
          disabled={!ticket.has_mob}
          onClick={() => act('SM', {
            'id': ticket.id,
          })}>
          SM
        </Button>
        <Button
          icon="arrow-up"
          disabled={!ticket.has_mob}
          onClick={() => act('FLW', {
            'id': ticket.id,
          })}>
          FLW
        </Button>
        <Button
          icon="book-dead"
          disabled={!ticket.has_mob}
          onClick={() => act('TP', {
            'id': ticket.id,
          })}>
          TP
        </Button>
        <Button
          icon="file"
          disabled={!ticket.has_mob}
          onClick={() => act('Logs', {
            'id': ticket.id,
          })}>
          Logs
        </Button>
        <Button
          icon="users"
          onClick={() => act('CA', {
            'id': ticket.id,
          })}>
          CA
        </Button>
        <Button
          icon="folder-open"
          onClick={() => act('Administer', {
            'id': ticket.id,
          })}>
          Administer
        </Button>
        <Button
          icon="check"
          onClick={() => act('Resolve', {
            'id': ticket.id,
          })}>
          {ticket.is_resolved ? "Unresolve" : "Resolve"}
        </Button>
        <Button
          icon="ban"
          disabled={!ticket.has_client}
          onClick={() => act('Reject', {
            'id': ticket.id,
          })}>
          Reject
        </Button>
        <Button
          icon="male"
          disabled={!ticket.has_client}
          onClick={() => act('IC', {
            'id': ticket.id,
          })}>
          IC
        </Button>
        <Button
          icon="info"
          disabled={!ticket.has_client}
          onClick={() => act('MHelp', {
            'id': ticket.id,
          })}>
          MHelp
        </Button>
      </Section>
    </Section>
  );
};
