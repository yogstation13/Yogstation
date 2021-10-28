import { useBackend, useSharedState } from '../backend';
import { Button, Dropdown, LabeledList, Section, Table, Input, Tabs, NumberInput, Divider, Box } from '../components';
import { Window } from '../layouts';

export const LibraryConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const {
    state,
    librarianconsole,
  } = data;
  return (
    <Window resizable theme="hackerman">
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Search
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Book DB
          </Tabs.Tab>
          {!!librarianconsole && (
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 3}
              onClick={() => setTab(3)}>
              Libriarian Access
            </Tabs.Tab>
          )}
        </Tabs>
        {tab === 1 && (
          <Search />
        )}
        {tab === 2 && (
          <BookDB />
        )}
        {tab === 3 && (
          <LibraryMangement />
        )}

      </Window.Content>
    </Window>
  );
};

export const Search = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const {
    title,
    category,
    author,
    validcategorys,
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Title">
          <Input
            value={title}
            onChange={(e, value) => act('settitle', { name: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Author">
          <Input
            value={author}
            onChange={(e, value) => act('setauthor', { name: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Category">
          <Dropdown
            options={validcategorys}
            selected={category}
            onSelected={value => act('setcategory', {
              category: value,
            })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Search">
          <Button
            content="Search"
            onClick={() => setTab(2)}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );};

export const BookDB = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 2);
  const {
    result,
    librarianconsole
  } = data;
  return (
    <Section>
      <Button
        content="Back"
        onClick={() => setTab(1)} />
      <Box>
        <Table cellpadding="10" textAlign="center" my={1} border>
          <Table.Row header>
            <Table.Cell py={2} textAlign="center">ID</Table.Cell>
            <Table.Cell textAlign="center">Title</Table.Cell>
            <Table.Cell textAlign="center">Category</Table.Cell>
            <Table.Cell textAlign="center">Author</Table.Cell>
            {!!librarianconsole && (
              <Table.Cell textAlign="center">Print</Table.Cell>
            )}
          </Table.Row>
          {Object.keys(result).map((key) => (
            <Table.Row key={key}>
              <Table.Cell py={1.5} textAlign="center">{key}</Table.Cell>
              <Table.Cell textAlign="center">{result[key]["title"]}</Table.Cell>
              <Table.Cell textAlign="center">{result[key]["category"]}</Table.Cell>
              <Table.Cell textAlign="center">{result[key]["author"]}</Table.Cell>
              {!!librarianconsole && (
                <Table.Cell textAlign="center">
                  <Button
                    content="Print"
                    onClick={() => act('vendbook', {
                      book: key,
                    })} />
                </Table.Cell>
              )}
              <br />
            </Table.Row>
        ))}
        </Table>
      </Box>
    </Section>
  )}

  export const LibraryMangement = (props, context) => {
    const { act, data } = useBackend(context);
    const [tab2, setTab2] = useSharedState(context, 'tab2', 1);
    var [checkoutTime, setTime] = useSharedState(context, "checkoutTime", 5)
    var [category, setcategory] = useSharedState(context, "category", "Fiction")
    const validcategorys=["Fiction", "Non-Fiction", "Adult", "Reference", "Religion"]
    const {
      emagged,
      scanner,
      checkouts,
    } = data;
    return (
    <Box>
      <Box>
        <Divider />
        <Tabs fontSize="11px" py={1.5} mx={1}>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(1)}
            selected={tab2 === 1}
            >
            General Inventory
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(2)}
            selected={tab2 === 2}
            >
            Checked Out
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(3)}
            selected={tab2 === 3}
            >
            Book Check Out
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(4)}
            selected={tab2 === 4}
            >
            External Archive
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(5)}
            selected={tab2 === 5}
            >
            Upload to Archive
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(6)}
            selected={tab2 === 6}
            >
            Upload to Newscaster
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(7)}
            selected={tab2 === 7}
            >
            Print Corporate Materials
          </Tabs.Tab>
          {!!emagged && (
            <Tabs.Tab
              lineHeight="23px"
              onClick={() => setTab2(8)}
              selected={tab2 === 8}
              >
              Access the Forbidden Lore Vault
            </Tabs.Tab>
          )}
          </Tabs>
          <Divider />
        </Box>
        <Section>
        {tab2 === 1 && (
          <Section>
            <h3>Inventory</h3><br />
            ERR 404: Inventory Not Found
          </Section>
        )}
        {tab2 === 2 && (
          <Section>
            <h3>Checked Out Books</h3>
            {Object.keys(checkouts).map((user) => (
              <Section>
                {Object.keys(checkouts[user]["books"]).map((book) => (
                  <Box>
                    {!checkouts[user]["books"][book]["overdue"] ?
                    <Box>
                      {checkouts[user]["books"][book]["title"]} by {checkouts[user]["books"][book]["author"]}<br />
                      <Box style="padding-left: 10px;">
                        Borrowed By: {checkouts[user]["books"][book]["borrower"]}<br />
                        Due in {checkouts[user]["books"][book]["due"]} Minutes
                        </Box>
                    </Box>
                    :
                    <Box>
                      <Section>
                        {checkouts[book]["books"]["title"]} by {checkouts[book]["books"]["author"]}
                          {checkouts[book]["books"]["borrower"]}: Overdue!!!
                      </Section>
                    </Box>
                    }
                  </Box>
                ))}
                <Divider />
              </Section>
            ))}
          </Section>
        )}
        {tab2 === 3 && (
          <Section>
            <h3>Check Out a Book</h3>
            {!!scanner ?
            <Section>
              Book: {scanner["title"]} by {scanner["author"]}<br /><br />
              Checkout Time <br />
              <NumberInput
                minValue = {5}
                maxValue = {60}
                value = {checkoutTime}
                unit = {"Minutes"}
                onChange={(e, value) => setTime(value)}
              />
              <Button
                  content="Check Out"
                  onClick={() => act('checkoutbook', {
                    id: scanner["id"],
                    time: checkoutTime,
                    title: scanner["title"],
                    author: scanner["author"]
              })} />
            </Section> :
            <Section>No book loaded in the scanner</Section>
            }
          </Section>
        )}
        {tab2 === 4 && (
          <Box>
            <BookDB />
          </Box>
        )}
        {tab2 === 5 && (
          <Box>
            <h3>Upload a New Title</h3>
            {!!scanner ?
              <Section>
                {scanner.title} by {scanner.author}
                <Dropdown
                  options={validcategorys}
                  selected={category}
                  onSelected={value => setcategory(value)
                  }
                />
                <br />
                <Button
                  content="Upload"
                  onClick={() => act('uploadbook', {
                    id: scanner["id"],
                    category: category
              })} />
              </Section>
              :
              <Box>
                Scanner not found
              </Box>
          }
          </Box>
        )}
        {tab2 === 6 && (
          <Section>
            <h3>Post Title to Newscaster</h3>
          </Section>
        )}
        {tab2 === 7 && (
          <Section>
          <h3>Universal Printing Module</h3>
          <Dropdown
              options={["A", "B"]}
              selected={"A"}
              onSelected={value => act('printtype', {
                type: value
              })}
            />
          </Section>
        )}
        {tab2 === 8 && (
          <h3></h3>
        )}
      </Section>
    </Box>
  )}
