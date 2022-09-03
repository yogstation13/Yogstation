import { useBackend } from '../backend';
import { LabeledList, ProgressBar, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosChem = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    out,
    len,
    chems,
  } = data;
  return (
    <NtosWindow
      width={300}
      height={350}
      resizable>
      <NtosWindow.Content scrollable>
        <Section>
          {len ? (
            <LabeledList label={out + " (" + { len } + ") Chemicals"}>
              {chems.map(chem => (
                <LabeledList.Item key={chem}>
                  {chem}
                </LabeledList.Item>
              ))}
              </LabeledList>
              ) : (
                <LabeledList >No Chemicals Found</LabeledList>
              )}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
