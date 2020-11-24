import { Box, Button, Section, Table, Input, NoticeBox, Icon, Fragment, NumberInput, LabeledList, Flex } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { FlexItem } from '../components/Flex';
import { TableRow, TableCell } from '../components/Table';

export const SecurityConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    logged_in,
    username,
    has_access,
    active_general_record,
    min_age,
    max_age,
    screen } = data;
  const { theme = 'ntos' } = props;

  const [searchText, setSearchText] = useLocalState(context, "searchText", "");

  if (data.z > 6) {
    return (
      <Window width={775} height={500} resizable theme={theme}>
        <Window.Content scrollable>
          <NoticeBox>
            Unable to establish connection. You are too far away from the station!
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  if (!logged_in) {
    return (
      <Window width={775} height={500} resizable theme={theme}>
        <Window.Content scrollable>
          <Section title="Welcome">
            <Flex align="center" justify="center" mt="0.5rem">
              <Flex.Item>
                <Fragment>
                  {data.user_image && (
                    <Fragment style={`position:relative`}>
                      <img src={data.user_image}
                        width="125px" height="125px"
                        style={`-ms-interpolation-mode: nearest-neighbor;
                        border-radius: 50%; border: 3px solid white;
                        margin-right:-125px`} />
                      <img src="scanlines.png"
                        width="125px" height="125px"
                        style={`-ms-interpolation-mode: nearest-neighbor;
                        border-radius: 50%; border: 3px solid white;opacity: 0.3;`} />
                    </Fragment>
                  ) || (
                    <Icon name="user-circle"
                      verticalAlign="middle" size="4.5" mr="1rem" />
                  )}
                  <Box inline fontSize="18px" bold>{username ? username : "Unknown"}</Box>
                  <NoticeBox success={has_access} danger={!has_access}
                    textAlign="center" mt="1.5rem">
                    {has_access ? "Access Granted" : "Access Denied"}
                  </NoticeBox>
                  <Box textAlign="center">
                    <Button icon="sign-in-alt" color={has_access ? "good" : "bad"} fluid
                      onClick={() => {
                        act("log_in");
                      }} >
                      Log In
                    </Button>
                  </Box>
                </Fragment>
              </Flex.Item>
            </Flex>
          </Section>

        </Window.Content>
      </Window>
    );
  }

  if (screen === "maint") {
    return (
      <Window resizable width={775} height={500} theme={theme}>
        <Window.Content scrollable>
          <Section title="Records Maintenance" buttons={(
            <Button icon="backward" onClick={() => act("back")}>
              Back
            </Button>
          )}>
            <Button icon="trash" color="bad" onClick={() => act("delete_records")}>
              Delete All Records
            </Button>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  if (screen === "record_view") {
    return (
      <Window resizable width={775} height={500} theme={theme}>
        <Window.Content scrollable>
          {data.special_message && (
            <NoticeBox>
              {data.special_message}
            </NoticeBox>
          )}
          <Section title="General Record" buttons={(
            <Fragment>
              <Button icon="print" onClick={() => act("print_record")}>Print Full Record</Button>
              <Button icon="trash" color="bad"
                onClick={() => act("delete_general_record_and_security")}>
                Delete Both Records
              </Button>
              <Button icon="sign-out-alt" color="bad" onClick={() => act("log_out")}>
                Log Out
              </Button>
              <Button icon="backward" onClick={() => act("back")}>Back</Button>
            </Fragment>
          )}>
            {active_general_record && (
              <Flex>
                <LabeledList>
                  <LabeledList.Item label="Name">
                    <Button onClick={() => act("edit_field", {
                      field: "name",
                    })}>
                      {data.active_record.name}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="ID">
                    <Button onClick={() => act("edit_field", {
                      field: "id",
                    })}>
                      {data.active_record.id}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Gender">
                    <Button onClick={() => act("edit_field", {
                      field: "gender",
                    })}>
                      {data.active_record.gender}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Age">
                    <NumberInput value={data.active_record.age} minValue={min_age}
                      maxValue={max_age}
                      onChange={(e, value) => act("edit_field", {
                        field: "age",
                        field_value: value,
                      })} />
                  </LabeledList.Item>
                  <LabeledList.Item label="Species">
                    <Button onClick={() => act("edit_field", {
                      field: "species",
                    })}>
                      {data.active_record.species}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Rank">
                    <Button onClick={() => act("edit_field", {
                      field: "rank",
                    })}>
                      {data.active_record.rank}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Fingerprint">
                    <Button onClick={() => act("edit_field", {
                      field: "fingerprint",
                    })}>
                      {data.active_record.fingerprint}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Physical Status">
                    {data.active_record.p_stat}
                  </LabeledList.Item>
                  <LabeledList.Item label="Mental Status">
                    {data.active_record.m_stat}
                  </LabeledList.Item>
                </LabeledList>
                <Box>
                  <img src={data.active_record.front_image}
                    width="180px" height="200px"
                    style={`-ms-interpolation-mode: nearest-neighbor`} />
                  <Button icon="print" mr="2px" fluid onClick={() => act("edit_field", {
                    field: "print_photo_front",
                  })}>
                    Print
                  </Button>
                </Box>
                <Box>
                  <img src={data.active_record.side_image}
                    width="180px" height="200px"
                    style={`-ms-interpolation-mode: nearest-neighbor`} />
                  <Button icon="print" ml="2px" fluid onClick={() => act("edit_field", {
                    field: "print_photo_side",
                  })}>
                    Print
                  </Button>
                </Box>


              </Flex>
            ) || (
              <NoticeBox>General Record Lost!</NoticeBox>
            )}

          </Section>
          <Section title="Security Record" buttons={(
            <Fragment>
              <Button icon="print" onClick={() => act("print_poster")}>Print Wanted Poster</Button>
              <Button icon="print" onClick={() => act("print_missing")}>
                Print Missing Poster
              </Button>
              <Button icon="trash" color="bad" onClick={() => act("delete_security_record")}>
                Delete Security Record
              </Button>
            </Fragment>
          )}>
            {data.active_record.criminal_status && (
              <Fragment>
                <LabeledList>
                  <LabeledList.Item label="Criminal Status">
                    <Button backgroundColor={data.active_record.recordColor}
                      onClick={() => act("edit_field", {
                        field: "criminal_status",
                      })}>

                      {data.active_record.criminal_status}
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
                <Section title="Citations" buttons={(
                  <Button color="good" icon="plus" onClick={() => act("edit_field", {
                    field: "citation_add",
                  })}>
                    Add Citation
                  </Button>
                )}>
                  <Table>
                    <TableRow color="label">
                      <TableCell>
                        Crime
                      </TableCell>
                      <TableCell>
                        Fine
                      </TableCell>
                      <TableCell>
                        Author
                      </TableCell>
                      <TableCell>
                        Time Added
                      </TableCell>
                      <TableCell>
                        Amount Due
                      </TableCell>
                      <TableCell collapsing>
                        Delete
                      </TableCell>
                    </TableRow>
                    {data.active_record.citations
                    && data.active_record.citations.map(crime => (
                      <TableRow key={crime.id}>
                        <TableCell>
                          {crime.name}
                        </TableCell>
                        <TableCell>
                          {crime.fine} credits
                        </TableCell>
                        <TableCell>
                          {crime.author}
                        </TableCell>
                        <TableCell>
                          {crime.time}
                        </TableCell>
                        <TableCell>
                          {crime.status}
                        </TableCell>
                        <TableCell collapsing>
                          <Button color="bad" onClick={() => act("edit_field", {
                            field: "citation_delete",
                            id: crime.id,
                          })}>Delete
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </Table>
                </Section>
                <Section title="Major Crimes" buttons={(
                  <Button color="good" icon="plus" onClick={() => act("edit_field", {
                    field: "major_crime_add",
                  })}>
                    Add Crime
                  </Button>
                )}>
                  <Table>
                    <TableRow color="label">
                      <TableCell>
                        Crime
                      </TableCell>
                      <TableCell>
                        Details
                      </TableCell>
                      <TableCell>
                        Author
                      </TableCell>
                      <TableCell>
                        Time Added
                      </TableCell>
                      <TableCell collapsing>
                        Delete
                      </TableCell>
                    </TableRow>
                    {data.active_record.major_crimes
                    && data.active_record.major_crimes.map(crime => (
                      <TableRow key={crime.id}>
                        <TableCell>
                          {crime.name}
                        </TableCell>
                        <TableCell>
                          {crime.details}
                        </TableCell>
                        <TableCell>
                          {crime.author}
                        </TableCell>
                        <TableCell>
                          {crime.time}
                        </TableCell>
                        <TableCell collapsing>
                          <Button color="bad" onClick={() => act("edit_field", {
                            field: "major_crime_delete",
                            id: crime.id,
                          })}>Delete
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </Table>
                </Section>
                <Section title="Minor Crimes" buttons={(
                  <Button color="good" icon="plus" onClick={() => act("edit_field", {
                    field: "minor_crime_add",
                  })}>
                    Add Crime
                  </Button>
                )}>
                  <Table>
                    <TableRow color="label">
                      <TableCell>
                        Crime
                      </TableCell>
                      <TableCell>
                        Details
                      </TableCell>
                      <TableCell>
                        Author
                      </TableCell>
                      <TableCell>
                        Time Added
                      </TableCell>
                      <TableCell collapsing>
                        Delete
                      </TableCell>
                    </TableRow>
                    {data.active_record.minor_crimes
                    && data.active_record.minor_crimes.map(crime => (
                      <TableRow key={crime.id}>
                        <TableCell>
                          {crime.name}
                        </TableCell>
                        <TableCell>
                          {crime.details}
                        </TableCell>
                        <TableCell>
                          {crime.author}
                        </TableCell>
                        <TableCell>
                          {crime.time}
                        </TableCell>
                        <TableCell collapsing>
                          <Button color="bad" onClick={() => act("edit_field", {
                            field: "minor_crime_delete",
                            id: crime.id,
                          })}>Delete
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </Table>
                </Section>

                <LabeledList>
                  <LabeledList.Item label="Important Notes">
                    <Button onClick={() => act("edit_field", {
                      field: "edit_note",
                    })}>
                      {data.active_record.notes}
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              </Fragment>
            ) || (
              <Fragment>
                <NoticeBox>Security Record Lost!</NoticeBox>
                <Button icon="plus" color="good" onClick={() => act("new_record")}>
                  Create Security Record
                </Button>
              </Fragment>
            )}
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window resizable width={775} height={500} theme={theme}>
      <Window.Content scrollable>
        {data.special_message && (
          <NoticeBox>
            {data.special_message}
          </NoticeBox>
        )}
        <Section title="Security Records" buttons={(
          <Fragment>
            <Button color="good" icon="plus" onClick={() => act("new_record_general")}>
              New Record
            </Button>
            <Button icon="wrench" onClick={() => act("record_maint")}>Record Maintenance</Button>
            <Button color="bad" icon="sign-out-alt" onClick={() => act("log_out")}>Log Out</Button>
          </Fragment>
        )}>
          <Input
            autoFocus
            fluid
            value={searchText}
            onInput={(e, value) => setSearchText(value)} />
          <br />
          <Table lineHeight="17px">
            <Table.Row color="label">
              <Table.Cell>
                Name
              </Table.Cell>
              <Table.Cell>
                ID
              </Table.Cell>
              <Table.Cell>
                Rank
              </Table.Cell>
              <Table.Cell>
                Fingerprints
              </Table.Cell>
              <Table.Cell collapsing>
                Criminal Status
              </Table.Cell>
            </Table.Row>
            {searchText.length >= 3 && (
              <div>
                {data.records.filter(record => {
                  let searchTerms = searchText.toLowerCase();
                  let allTerms = [];
                  allTerms.push(String(record.name).toLowerCase());
                  allTerms.push(String(record.id).toLowerCase());
                  allTerms.push(String(record.fingerprint).toLowerCase());
                  allTerms.push(String(record.rank).toLowerCase());

                  return (allTerms.some(v => { return v.indexOf(searchTerms) >= 0; }));
                }).map(record => (
                  <Table.Row key={record.id} backgroundColor={record.recordColor} >
                    <Table.Cell pl="3px" pt="3px">
                      <Button onClick={() => {
                        act("browse_record", {
                          record: record.reference,
                        });
                      }}>
                        {record.name}
                      </Button>
                    </Table.Cell>
                    <Table.Cell>
                      {record.id}
                    </Table.Cell>
                    <Table.Cell>
                      {record.rank}
                    </Table.Cell>
                    <Table.Cell>
                      {record.fingerprint}
                    </Table.Cell>
                    <Table.Cell>
                      <Box textAlign="center" bold>
                        {record.crime_status}
                      </Box>
                      {record.recordIcon && (
                        <Box textAlign="center" bold>
                          <Icon name={record.recordIcon} size="1.25" />
                        </Box>
                      )}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </div>
            ) || (
              <div>
                {data.records.map(record => (
                  <Table.Row key={record.id} backgroundColor={record.recordColor} >
                    <Table.Cell pl="3px" pt="3px">
                      <Button textAlign="center" onClick={() => {
                        act("browse_record", {
                          record: record.reference,
                        });
                      }}>
                        {record.name}
                      </Button>
                    </Table.Cell>
                    <Table.Cell>
                      {record.id}
                    </Table.Cell>
                    <Table.Cell>
                      {record.rank}
                    </Table.Cell>
                    <Table.Cell>
                      {record.fingerprint}
                    </Table.Cell>
                    <Table.Cell>
                      <Box textAlign="center" bold>
                        {record.crime_status}
                      </Box>
                      {record.recordIcon && (
                        <Box textAlign="center" bold>
                          <Icon name={record.recordIcon} size="1.25" />
                        </Box>
                      )}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </div>
            )}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
