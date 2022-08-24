import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Grid, NumberInput, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

MaxMultiplier = (metalamount, glassamount, metalrequired, glassrequired) => {
  var maxmulti = []
  if((data.metal_amount < design.metalrequired*5) || (data.glass_amount < design.glassrequired*5))
    return maxmulti
  maxmulti += 5
  if((data.metal_amount < design.metalrequired*10) || (data.glass_amount < design.glassrequired*10))
    return maxmulti
  maxmulti += 10
  if((data.metal_amount < design.metalrequired*15) || (data.glass_amount < design.glassrequired*15))
    return maxmulti
  maxmulti += 15
  if((data.metal_amount < design.metalrequired*25) || (data.glass_amount < design.glassrequired*25))
    return maxmulti
  maxmulti += 25
  return maxmulti
}

export const Autolathe = (props, context) => {

  const [
    searchterms,
    setSearchText,
  ] = useLocalState(context, 'searchterms', '');
  const [
    sheetnumberglass,
    setGlassSheetCount,
  ] = useLocalState(context, 'sheetnumberglass', 0);
  const [
    sheetnumbermetal,
    setMetalSheetCount,
  ] = useLocalState(context, 'sheetnumbermetal', 0);
  const [
    setcategory,
    setCategory,
  ] = useLocalState(context, 'setcategory', 'Tools');

  const { act, data } = useBackend(context);
  return (
    <Window width={1116} height={703} resizable>
      <Window.Content scrollable>
        <Section
          title={("Autolathe")}
          buttons={(
            <Box inline ml={80}>
              Search:
              <Input
                value={searchterms}
                width="250px"
                onInput={(e, value) => setSearchText(value)}
                ml={2}
                mr={5} />
            </Box>
          )}>
          <Grid>
            <Grid.Column size={3.0}>
              <div>
                <font color={(data.total_amount > 0 ? '#c9b971' : 'red')}>
                  <Box inline mr={1} mb={1} ml={1} mt={1}>
                    <b>Total amount: </b>
                  </Box>
                  {data.total_amount} / {data.max_amount} cm³
                </font>
                <br />
                <font color={(data.metal_amount > 0 ? '#c9b971' : 'red')}>
                  <Box inline mr={1} mb={1} ml={1}>
                    <b>Metal amount: </b>
                  </Box>
                  {data.metal_amount} cm³
                </font>
                <br />
                <font color={(data.glass_amount > 0 ? '#c9b971' : 'red')}>
                  <Box inline mr={1} ml={1}>
                    <b>Glass amount:</b>
                  </Box>
                  {data.glass_amount} cm³
                </font>
              </div>
            </Grid.Column>
            <Grid.Column size={1.7}>
              <div align="right">
                Print Location:
                <Button
                  mr={10}
                  ml={2}
                  mb={1}
                  disabled={data.abovewall}
                  color={data.printdir === 1 ? ("green"):("yellow")}
                  icon={"chevron-up"}
                  onClick={() => act('printdir', { direction: '1' })}
                />
                <br /><Button
                  ml={1}
                  disabled={data.leftwall}
                  color={data.printdir === 8 ? ("green"):("yellow")}
                  icon={"chevron-left"}
                  onClick={() => act('printdir', { direction: '8' })}
                />
                <Button
                  ml={1}
                  icon="print"
                  color={data.printdir === 0 ? ("green"):("yellow")}
                  onClick={() => act('printdir', { direction: '0' })}
                />
                <Button
                  ml={1}
                  mr={5}
                  disabled={data.rightwall}
                  color={data.printdir === 4 ? ("green"):("yellow")}
                  icon={"chevron-right"}
                  onClick={() => act('printdir', { direction: '4' })}
                />
                <br />
                <Button
                  ml={0.7}
                  mt={0.8}
                  mr={10}
                  disabled={data.belowwall}
                  color={data.printdir === 2 ? ("green"):("yellow")}
                  icon={"chevron-down"}
                  onClick={() => act('printdir', { direction: '2' })}
                />
              </div>
            </Grid.Column>
            <Grid.Column size={1.5}>
              <Box mb={-1.75}>
                <b>Material Eject:</b>
              </Box>
              <br />
              <Box mr={1} inline>
                <b>Metal</b>
              </Box>
              <NumberInput
                animated
                value={Math.round(sheetnumbermetal - 0.5)}
                ml={5}
                width="100px"
                unit="Sheets"
                minValue={0}
                maxValue={Math.round((data.metal_amount / 2000) - 0.5)}
                onChange={(e, value) => setMetalSheetCount(value)} />

              <Button
                inline
                content={"Eject"}
                ml={1}
                mr={1}
                disabled={(data.metal_amount < 2000 ? 1 : 0)}
                onClick={() => act('eject', {
                  item_id: 'metal',
                  multiplier: sheetnumbermetal,
                })}
              /><br />
              <Box inline mr={1.15}>
                <b>Glass</b>
              </Box>
              <NumberInput
                animated
                value={Math.round(sheetnumberglass - 0.5)}
                ml={5}
                width="100px"
                unit="Sheets"
                minValue={0}
                maxValue={Math.round((data.glass_amount / 2000) - 0.5)}
                onChange={(e, value) => setGlassSheetCount(value)} />
              <Button
                content={"Eject"}
                ml={1}
                mr={1}
                disabled={(data.glass_amount < 2000 ? 1 : 0)}
                onClick={() => act('eject', {
                  item_id: 'glass',
                  multiplier: sheetnumberglass,
                })}
              />
              <div><br /></div>
            </Grid.Column>
          </Grid>
          <Flex>
            <Flex.Item>
              <Section title="Categories">
                {data.categories.map((categoryName, i) => (
                  <Button
                    key={categoryName}
                    fluid
                    mr={2}
                    selected={
                      (searchterms.length > 1 ? (
                        (categoryName === 'Search' ? 1 : 0)
                      ):(
                        setcategory === categoryName
                      ))
                    }
                    color="transparent"
                    content={categoryName}
                    onClick={(!searchterms ? (
                      () => setCategory(categoryName)
                    ):(
                      () => setSearchText("")))}
                  />
                ))}
              </Section>
            </Flex.Item>
            <Flex.Item>
              {searchterms.length > 1 ? (
                <Section fluid title="Search Results" width={50}>
                  <div>
                    <Flex.Item>
                      {data.designs.filter(design => {
                        const searchTerm = searchterms.toLowerCase();
                        const searchableString = String(design.name).toLowerCase();
                        return (searchterms.length < 2 ? (
                          null
                        ) : (
                          (searchableString.match(new RegExp(searchterms, "i")))
                        ));
                      }).map(design => (
                        <div key={data.designs}>
                          <Grid>
                            <Grid.Column size={2.5}>
                              <Button
                                key={design.name}
                                content={design.name}
                                disabled={design.disabled}
                                title={design.name}
                                icon="print"
                                onClick={() => act('make', {
                                  item_id: design.id,
                                  multiplier: 1,
                                })} />
                              {design.max_multiplier.map(max => (
                                <Button
                                  key={max}
                                  disabled={design.disabled}
                                  content={max + "x"}
                                  onClick={() => act('make', {
                                    item_id: design.id,
                                    multiplier: max,
                                  })}
                                />
                              ))}

                            </Grid.Column>
                            <Grid.Column size={1}>
                              {design.materials_metal === 0 ? (
                                ''
                              ):(
                                <Box ml={0} mr={0} inline
                                  color={(
                                    data.metal_amount > design.materials_metal ? 'white' : 'bad'
                                  )}>
                                  {data.metal_amount > design.materials_metal ? (
                                    <div>Metal: {design.materials_metal}</div>
                                  ) : (
                                    <b>Metal: {design.materials_metal}</b>
                                  )}
                                </Box>

                              )}
                            </Grid.Column>
                            <Grid.Column size={1}>
                              {design.materials_glass === 0 ? (
                                ""
                              ):(
                                <Box ml={0} mr={0} inline
                                  color={(
                                    data.glass_amount >= design.materials_glass ? 'white' : 'bad'
                                  )}>
                                  {data.glass_amount >= design.materials_glass ? (
                                    <div>Glass: {design.materials_glass}</div>
                                  ) : (
                                    <b>Glass: {design.materials_metal}</b>
                                  )}
                                </Box>

                              )}

                            </Grid.Column>
                          </Grid>
                        </div>
                      ))}

                    </Flex.Item>
                  </div>
                </Section>
              ) : (
                <Section fluid title="Known Designs" width={50}>
                  <div>
                    <Flex.Item>
                      {data.designs.filter(design => {
                        return (design.category.includes(setcategory));
                      }).map(design => (
                        <div key={data.designs}>
                          <Grid>
                            <Grid.Column size={2.5}>
                              <Button
                                inline
                                key={design.name}
                                content={design.name}
                                disabled={(data.metal_amount < design.materials_metal) || (data.glass_amount < design.materials_glass)}
                                title={design.name}
                                mr={1}
                                icon="print"
                                onClick={() => act('make', {
                                  item_id: design.id,
                                  multiplier: 1,
                                })} />

                              {MaxMultiplier(data.metal_amount, data.glass_amount. design.materials_metal, design.materials_glass).map(max => (
                                <Button
                                  inline
                                  key={max}
                                  disabled={design.disabled}
                                  content={max + "x"}
                                  onClick={() => act('make', {
                                    item_id: design.id,
                                    multiplier: max,
                                  })}
                                />
                              ))}
                            </Grid.Column>
                            <Grid.Column size={1}>
                              {design.materials_metal === 0 ? (
                                ""
                              ):(
                                <Box ml={0} mr={0} inline
                                  color={(
                                    data.metal_amount >= design.materials_metal ? 'white' : 'bad'
                                  )}>
                                  {data.metal_amount >= design.materials_metal ? (
                                    <div>Metal: {design.materials_metal}</div>
                                  ) : (
                                    <b>Metal: {design.materials_metal}</b>
                                  )}
                                </Box>

                              )}

                            </Grid.Column>
                            <Grid.Column size={1}>
                              {!design.materials_glass > 0 ? (
                                ""
                              ):(
                                <Box ml={0} mr={0} inline
                                  color={(
                                    data.glass_amount >= design.materials_glass ? 'white' : 'bad'
                                  )}>
                                  {data.glass_amount >= design.materials_glass ? (
                                    <div>Glass: {design.materials_glass}</div>
                                  ) : (
                                    <b>Glass: {design.materials_glass}</b>
                                  )}
                                </Box>

                              )}
                            </Grid.Column>
                          </Grid>
                        </div>
                      ))}
                    </Flex.Item>
                  </div>

                </Section>

              )}
            </Flex.Item>
            <Flex.Item>
              <Section title="Autolathe Queue" width="100vw">
                <NoticeBox ml={1} mr={1} mt={1} mb={1}>
                  {data.isprocessing ? (
                    <font size="3">Processing: {data.processing}</font>
                  ) : (
                    <font size="3">
                      {data.queuelength > 0 ? "Ready to Start" : "Empty"}
                    </font>
                  )}
                </NoticeBox>
                <div><br /></div>
                <font size="2">
                  {data.queue.map(build => (
                    <div key={data.queue.len}>
                      <Grid>
                        <Grid.Column size={0.1} />
                        <Grid.Column size={1.5}>
                          {build.name}
                          {"  x  " + build.multiplier + "   "}
                        </Grid.Column>
                        <Grid.Column>
                          <Button
                            disabled={(build.index === 1)}
                            icon="chevron-up"
                            onClick={() => act('queue_move',
                              { queue_move: -1, index: build.index })}
                          />
                          <Button
                            disabled={(build.index === data.queuelength)}
                            icon="chevron-down"
                            onClick={() => act('queue_move',
                              { queue_move: +1, index: build.index })}
                          />
                          <Button
                            content="Remove"
                            onClick={() => act('remove_from_queue', { index: build.index })}
                          />
                        </Grid.Column>
                        <Grid.Column size={5} />
                      </Grid><br />
                    </div>
                  ))}
                </font>
                <Button
                  disabled={!data.queuelength}
                  content={!data.isprocessing ? ("Process Queue"):("Stop Processing")}
                  onClick={() => act('process_queue')}
                />
                <Button
                  disabled={data.isprocessing}
                  content={"Clear Queue"}
                  onClick={() => act('clear_queue')}
                />
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>

  );
};
