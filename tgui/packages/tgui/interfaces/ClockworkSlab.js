import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const ClockworkSlab = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window theme="clockwork">
      <Window.Content>
        <Section>
          <Button
            content={data.recollection ? "Recital" : "Recollection"}
            onClick={() => act('toggle')} />
        </Section>
        {data.recollection && (

          <Section>
            {data.rec_text}
            {data.recollection_categories.map(recollection => (
              <Button key={recollection.name}
                content={recollection.name + " - " + recollection.desc}
                onClick={() => act('rec_category', {
                  category: recollection.name,
                })} />
            ))}
            {data.rec_section}
            {data.rec_binds}
          </Section>
        ) || (
          <Fragment>
            <Section title="Power">
              <LabeledList>
                <LabeledList.Item>
                    {data.power}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section>
              <LabeledList>
                <LabeledList.Item>
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
                  {data.tier_info}
                </LabeledList.Item>
                <LabeledList.Item>
                  {data.scripturecolors}
                </LabeledList.Item>
                <LabeledList.Item>
                  {data.scripture.map(script => (
                    <Fragment key={script.type}>
                      <Button
                        tooltip={script.tooltip}
                        tooltipPosition="right"
                        content={"Recite " + script.required}
                        onClick={() => act('recite', {
                          category: script.type,
                        })} />
                      {script.quickbind && (
                        <div>
                          {script.bound && (
                            <Button
                              content={"Unbind " + script.bound}
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
                      {script.name} {script.descname} {script.invokers}
                    </Fragment>
                  ))}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Fragment>
        )}
      </Window.Content>
    </Window>
  );
};
