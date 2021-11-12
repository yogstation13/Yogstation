
import { useBackend, useLocalState } from '../backend';
import { Section, Collapsible, Button, Tabs, Flex } from '../components';
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
      theme="admintickets"
      title="Admin Ticket Viewer"
      width={520}
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
        className="ticket_section"
        color={open_count === 0 ? 'default' : 'red'}
        open
        title={"Unresolved Tickets (" + open_count + "/" + total_count + ")"}>
        {data.unresolved_tickets.filter(filterTicket).reverse().map(ticket => (
          <TicketSummary
            key={ticket.id}
            ticket={ticket}
            user={data.user_key} />
        ))}
      </Collapsible>
      <Collapsible
        className="ticket_section"
        color="green"
        title={"Resolved Tickets (" + closed_count + "/" + total_count + ")"}>
        {data.resolved_tickets.filter(filterTicket).reverse().map(ticket => (
          <TicketSummary
            key={ticket.id}
            ticket={ticket}
            user={data.user_key} />
        ))}
      </Collapsible>
    </Fragment>
  );
};

export const TicketSummary = (props, context) => {
  const { ticket, user } = props;
  const { act } = useBackend(context);

  const buttons = [
    [
      {
        name: 'View',
        act: 'view',
        icon: 'eye',
      },
      {
        name: '',
        act: 'adminmoreinfo',
        icon: 'question',
        disabled: !ticket.has_mob,
      },
      {
        name: 'PP',
        act: 'PP',
        icon: 'user',
        disabled: !ticket.has_mob,
      },
      {
        name: 'VV',
        act: 'VV',
        icon: 'cog',
        disabled: !ticket.has_mob,
      },
      {
        name: 'FLW',
        act: 'FLW',
        icon: 'arrow-up',
        disabled: !ticket.has_mob,
      },
      {
        name: 'TP',
        act: 'TP',
        icon: 'book-dead',
        disabled: !ticket.has_mob,
      },
      {
        name: 'Logs',
        act: 'Logs',
        icon: 'file',
        disabled: !ticket.has_mob,
      },
    ],
    [
      {
        name: 'Administer',
        act: 'Administer',
        icon: 'folder-open',
      },
      {
        name: 'Reject',
        act: 'Reject',
        icon: 'ban',
      },
      {
        name: ticket.is_resolved ? 'Unresolve' : 'Resolve',
        act: 'Resolve',
        icon: 'check',
      },
      {
        name: 'IC',
        act: 'IC',
        icon: 'male',
        disabled: !ticket.has_client,
      },
      {
        name: 'MHelp',
        act: 'MHelp',
        icon: 'info',
        disabled: !ticket.has_client,
      },
    ],
  ];

  return (
    <Section
      className={user === ticket.admin_key ? "myticket" : ""}
      backgroundColor={ticket.admin_key || !ticket.active ? "" : "bad"}
      title={"#" + ticket.id + ": " + ticket.name}>
      Owner:
      <Button
        icon="reply"
        onClick={() => act('reply', {
          'index': ticket.index,
        })}>
        {ticket.initiator_key_name}
      </Button><br />
      Admin: {ticket.admin_key ? ticket.admin_key : "UNCLAIMED"}<br />
      <span class="color-bad">{!ticket.has_client ? "DISCONNECTED" : ""}</span>
      <Section
        level="2">
        {buttons.map((button_row, i) => (
          <Flex direction="row" key={i}>
            {button_row.map(button => (
              <Flex.Item key={button.act} grow={1}>
                <Button key={button.act} fluid m="2.5px"
                  icon={button.icon}
                  disabled={button.disabled}
                  selected={button.selected}
                  onClick={(val => () => act(val, {
                    'index': ticket.index,
                  }))(button.act)}>
                  {button.name}
                </Button>
              </Flex.Item>
            ))}
          </Flex>
        ))}
      </Section>
    </Section>
  );
};
