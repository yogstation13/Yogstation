import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Button, LabeledList, Section, Divider, Flex } from '../components';
import { Window } from '../layouts';

export const ClockworkSlab = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window theme="clockwork" resizeable>
      <Window.Content>
        <Section>
          <Button
            content={data.recollection ? "Recital" : "Recollection"}
            onClick={() => act('toggle')} />
        </Section>
        {data.recollection && (

          <Section>
            <div dangerouslySetInnerHTML={{ __html: data.rec_text }} />
            <br />
            {data.recollection_categories.map(recollection => (
              <Button key={recollection.name}
                content={recollection.name + " - " + recollection.desc}
                onClick={() => act('rec_category', {
                  category: recollection.name,
                })} />
            ))}
            <div dangerouslySetInnerHTML={{ __html: data.rec_section }} />
            <div dangerouslySetInnerHTML={{ __html: data.rec_binds }} />
          </Section>
        ) || (
          <Fragment>
            <Section title="Power">
                  <div dangerouslySetInnerHTML={{ __html: data.power }} />
            </Section>
            <Section>
              <Fragment>
                <Fragment>
                  <Button
                    content="Driver"
                    selected={data.selected === "Driver"}
                    onClick={() => act('select', {
                      category: "Driver",
                    })} />
                  <Button
                    content="Script"
                    selected={data.selected === "Script"}
                    onClick={() => act('select', {
                      category: "Script",
                    })} />
                  <Button
                    content="Application"
                    selected={data.selected === "Application"}
                    onClick={() => act('select', {
                      category: "Application",
                    })} />
                  <br />
                  <div dangerouslySetInnerHTML={{ __html: data.tier_info }} />
                </Fragment>
                <Fragment>
                  <div dangerouslySetInnerHTML={{ __html: data.scripturecolors }} />
                </Fragment>
                <Divider />
                <Fragment>

                  {data.scripture.map(script => (
                    <Flex key={script.type}>
                      <Button
                        tooltip={script.tip}
                        tooltipPosition="right"
                        content={"Recite " + script.required}
                        onClick={() => act('recite', {
                          category: script.type,
                        })} />

                      {script.quickbind && (
                        <div>
                          {script.bound && (
                            <Button
                              dangerouslySetInnerHTML={{ __html: "Unbind " + script.bound }}
                              onClick={() => act('bind', {
                                category: script.type,
                              })} />
                          ) || (
                            <Button
                              content="Quickbind"
                              onClick={() => act('bind', {
                                category: script.type,
                              })} />
                          )}
                        </div>
                      )}
                      {script.invokers && (
                        <div style="padding-left: 4px;" dangerouslySetInnerHTML={{ __html: script.name + " " + script.descname + " " + script.invokers }} />
                      ) || (
                        <div style="padding-left: 4px;" dangerouslySetInnerHTML={{ __html: script.name + " " + script.descname }} />
                      )}


                    </Flex>
                  ))}

                </Fragment>
              </Fragment>
            </Section>
          </Fragment>
        )}
      </Window.Content>
    </Window>
  );
};
