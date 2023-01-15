import { useBackend, useSharedState } from '../backend';
import { Button, Dropdown, LabeledList, Section, Table, Input, Tabs, NumberInput, Divider, Box } from '../components';
import { Window } from '../layouts';

let width = 500;
let height = 200;

export const LibraryConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const {
    state,
    librarianconsole,
  } = data;
  return (
    <Window resizeable width={width} height={height}>
      <Window.Content>
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
              Librarian Access
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
  width = 350;
  height = 250;
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
  ); };

export const BookDB = (props, context) => {
  width = 600;
  height = 550;
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 2);
  const {
    result,
    librarianconsole,
    page,
    totalpages,
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
          {Object.keys(result).map(key => (
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
        <Section textAlign="center">
          <Button
            content={1}
            width={3}
            onClick={() => act('setpage', {
              page: 0,
            })} mx={1} />

          {(!(page-3<0))
            && <Button
              width={3}
              content={page-1}
              onClick={() => act('setpage', {
                page: page-2,
              })} />}

          {(!(page-2<0) && !(page===totalpages))
            && <Button
              content={page}
              width={3}
              onClick={() => act('setpage', {
                page: page-1,
              })} />}

          {(!(page===0) && !(page===totalpages))
            && <Button
              content={page+1}
              width={3}
              selected
              onClick={() => act('setpage', {
                page: page,
              })} mx={1} />}

          {(!(page+2>=totalpages))
            && <Button
              content={page+2}
              width={3}
              onClick={() => act('setpage', {
                page: page+1,
              })} />}

          {(!(page+3>=totalpages))
            && <Button
              content={page+3}
              width={3}
              onClick={() => act('setpage', {
                page: page+2,
              })} />}

          {(!(totalpages===0))
            && <Button
              content={totalpages}
              width={3}
              onClick={() => act('setpage', {
                page: totalpages,
              })} mx={1} />}
        </Section>
      </Box>
    </Section>
  ); };

export const LibraryMangement = (props, context) => {
  width = 600;
  height = 380;
  const { act, data } = useBackend(context);
  const [tab2, setTab2] = useSharedState(context, 'tab2', 1);
  let [checkoutTime, setTime] = useSharedState(context, "checkoutTime", 5);
  let [category, setcategory] = useSharedState(context, "category", "Fiction");
  let [type, setType] = useSharedState(context, "type", "Bible");
  const validcategorys=["Fiction", "Non-Fiction", "Adult", "Reference", "Religion"];
  const {
    emagged,
    scanner,
    checkouts,
    corpmaterials,
    newscast,
  } = data;
  return (
    <Box>
      <Box>
        <Divider />
        <Tabs py={1.5} mx={1}>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(1)}
            selected={tab2 === 1}>
            Checked Out
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(2)}
            selected={tab2 === 2}>
            Book Check Out
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(3)}
            selected={tab2 === 3}>
            Upload to Archive
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(4)}
            selected={tab2 === 4}>
            Upload to Newscaster
          </Tabs.Tab>
          <Tabs.Tab
            lineHeight="23px"
            onClick={() => setTab2(5)}
            selected={tab2 === 5}>
            Print Corporate Materials
          </Tabs.Tab>
        </Tabs>
        <Divider />
      </Box>
      <Section>
        {tab2 === 1 && (
          <Box>
            <h3>Checked Out Books</h3>
            {Object.keys(checkouts).map(user => (
              <Box key={user}>
                {Object.keys(checkouts[user]["books"]).map(book => (
                  <Box key={book}>
                    {!checkouts[user]["books"][book]["overdue"]
                      ?(
                        <Box>
                          {checkouts[user]["books"][book]["title"]} by {checkouts[user]["books"][book]["author"]}<br />
                          <Box pl={0.5}>
                            &nbsp;&nbsp;Borrowed By: {checkouts[user]["books"][book]["borrower"]}<br />
                            &nbsp;&nbsp;Due in {checkouts[user]["books"][book]["due"]} Minutes
                          </Box>
                        </Box>
                      ):(
                        <Box>
                          <Section>
                            {checkouts[book]["books"]["title"]} by {checkouts[book]["books"]["author"]}
                            {checkouts[book]["books"]["borrower"]}: Overdue!!!
                          </Section>
                        </Box>
                      )}
                  </Box>
                ))}
                <Divider />
              </Box>
            ))}
          </Box>
        )}
        {tab2 === 2 && (
          <Box>
            <h3>Check Out a Book</h3>
            {scanner
              ?(
                <Box>
                  Book: {scanner["title"]} by {scanner["author"]}<br />
                  {!!scanner["idname"] && (
                    <Box>
                      &nbsp;&nbsp;Loan To: {scanner["idname"]} ({scanner["assignment"]})
                    </Box>
                  )}
                  <br /><br />
                  Checkout Time:&nbsp;
                  <NumberInput
                    minValue={5}
                    maxValue={60}
                    value={checkoutTime}
                    unit={"Minutes"}
                    onChange={(e, value) => setTime(value)}
                  />
                  <br />
                  <br />
                  <Button
                    content="Check Out"
                    onClick={() => act('checkoutbook', {
                      id: scanner["id"],
                      time: checkoutTime,
                      title: scanner["title"],
                      author: scanner["author"],
                    })} />
                </Box>
              ):(
                <Box>
                  No book loaded in the scanner
                </Box>
              )}
          </Box>
        )}
        {tab2 === 3 && (
          <Box>
            <h3>Upload a New Title</h3>
            {scanner
              ?(
                <Section>
                  {scanner.title} by {scanner.author}
                  <Dropdown
                    options={validcategorys}
                    selected={category}
                    onSelected={value => setcategory(value)}
                  />
                  <br />
                  <Button
                    content="Upload"
                    onClick={() => act('uploadbook', {
                      id: scanner["id"],
                      category: category,
                    })} />
                </Section>
              ):(
                <Box>
                  Scanner info not found
                </Box>
              )}
          </Box>
        )}
        {tab2 === 4 && (
          <Box>
            <h3>Post Title to Newscaster</h3>
            {newscast ? (
              <Box>
                {scanner ? (
                  <Box>
                    {scanner.title} by {scanner.author}
                    <br />
                    <br />
                    <Button
                      content="Post"
                      onClick={() => act('newsupload', {
                        id: scanner["id"],
                        category: category,
                      })} />
                  </Box>
                ) : (
                  <Box>
                    Scanner info not found
                  </Box>
                )}
              </Box>
            ) : (
              <Box>
                No Newscaster Network Found
              </Box>
            )}
          </Box>
        )}
        {tab2 === 5 && (
          <Box>
            <h3>Universal Printing Module</h3>
            <Dropdown
              options={corpmaterials}
              selected={type}
              onSelected={
                value => setType(value)
              }
            />
            <br />
            <br />
            <Button
              content="Print"
              onClick={() => act('printtype', {
                type: type,
              })} />
          </Box>
        )}
      </Section>
    </Box>
  ); };
