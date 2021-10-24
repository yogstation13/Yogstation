import { Fragment } from 'inferno';
import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Button, NoticeBox, Section, Flex, Tabs, Box, Input } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPortraitPrinter = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [listIndex, setListIndex] = useLocalState(context, 'listIndex', 0);
  const [searchterms, setSearchText] = useLocalState(context, 'searchterms', '');
  const {
    public_paintings,
  } = data;
  const TABS = [
    {
      name: 'Public Portraits',
      asset_prefix: "public",
      list: public_paintings,
    },
  ];


  const tab2list = TABS[0].list;
  const current_portrait_title = tab2list[listIndex]["title"];
  const current_portrait_asset_name = TABS[0].asset_prefix + "_" + tab2list[listIndex]["md5"];
  return (
    <NtosWindow
      width={400}
      height={406}>
      <NtosWindow.Content>
        <Flex direction="column" height="100%">
          <Flex.Item>
            <Section fitted>
              <Tabs fluid textAlign="center">
                {TABS.map((tabObj, i) => !!tabObj.list && (
                  <Tabs.Tab
                    key={i}
                    selected={i === tabIndex}
                    onClick={() => {
                      setListIndex(0);
                      setTabIndex(i);
                    }}>
                    {tabObj.name}
                  </Tabs.Tab>
                ))}
                <Tabs.Tab
                  key={TABS.length + 1}
                  selected={(TABS.length + 1 === tabIndex)}
                  onClick={() => {
                    setListIndex(0);
                    setTabIndex(TABS.length + 1);
                  }}>
                  Search
                </Tabs.Tab>
              </Tabs>
            </Section>
          </Flex.Item>
          {tabIndex !== (TABS.length + 1) && (
            <Fragment>
              <Flex.Item grow={2}>
                <Section fill>
                  <Flex
                    height="100%"
                    align="center"
                    justify="center"
                    direction="column">
                    <Flex.Item>
                      <img
                        src={resolveAsset(current_portrait_asset_name)}
                        height="128px"
                        width="128px"
                        style={{
                          'vertical-align': 'middle',
                          '-ms-interpolation-mode': 'nearest-neighbor',
                        }} />
                    </Flex.Item>
                    <Flex.Item className="Section__titleText">
                      {current_portrait_title}
                    </Flex.Item>
                  </Flex>
                </Section>
              </Flex.Item>
              <Flex.Item>
                <Flex>
                  <Flex.Item grow={3}>
                    <Section height="100%">
                      <Flex justify="space-between">
                        <Flex.Item grow={1}>
                          <Button
                            icon="angle-double-left"
                            disabled={listIndex === 0}
                            onClick={() => setListIndex(0)}
                          />
                        </Flex.Item>
                        <Flex.Item grow={3}>
                          <Button
                            disabled={listIndex === 0}
                            icon="chevron-left"
                            onClick={() => setListIndex(listIndex-1)}
                          />
                        </Flex.Item>
                        <Flex.Item grow={3}>
                          <Button
                            icon="check"
                            content="Print Portrait"
                            onClick={() => act("select", {
                              tab: tabIndex+1,
                              selected: listIndex+1,
                            })}
                          />
                        </Flex.Item>
                        <Flex.Item grow={1}>
                          <Button
                            icon="chevron-right"
                            disabled={listIndex === tab2list.length-1}
                            onClick={() => setListIndex(listIndex+1)}
                          />
                        </Flex.Item>
                        <Flex.Item>
                          <Button
                            icon="angle-double-right"
                            disabled={listIndex === tab2list.length-1}
                            onClick={() => setListIndex(tab2list.length-1)}
                          />
                        </Flex.Item>
                      </Flex>
                    </Section>
                  </Flex.Item>
                </Flex>
                <Flex.Item mt={1} mb={-1}>
                  <NoticeBox info>
                    Printing a canvas costs 10 paper from
                    the printer installed in your machine.
                  </NoticeBox>
                </Flex.Item>
              </Flex.Item>
            </Fragment>
          ) || (
            <Flex.Item grow={2}>
              <Section>
                <Flex
                  direction="column">
                  <Flex.Item align="center" mb={1}>
                    <Input
                      value={searchterms}
                      width="300px"
                      placeholder="Search.."
                      onInput={(e, value) => setSearchText(value)} />
                  </Flex.Item>
                  {tab2list.map((painting, index) => {
                    return {
                      painting: painting,
                      index: index,
                    };
                  }).filter(painting => {
                    const searchTerm = searchterms.toLowerCase();
                    const searchableString = String(painting.painting.title + " " + painting.painting.ckey).toLowerCase();
                    return (searchterms.length < 2 ? (
                      null
                    ) : (
                      (searchableString.match(new RegExp(searchterms, "i")))
                    ));
                  }).map(painting => (
                    <Flex.Item mb={0.5} key={painting.index}>
                      <Button
                        onClick={() => {
                          setListIndex(painting.index);
                          setTabIndex(0);
                        }}
                        width="100%">
                        <Box bold inline>
                          {painting.painting.title}
                        </Box>
                        (by {painting.painting.ckey})
                      </Button>
                    </Flex.Item>
                  ))}
                </Flex>
              </Section>
            </Flex.Item>
          )}
        </Flex>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
