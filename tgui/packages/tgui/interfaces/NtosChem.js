import { useBackend } from '../backend';
import { Box, LabeledList, ProgressBar, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosChem = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    chems,
  } = data;
  return (
    <NtosWindow
      width={350}
      height={350}
      resizable>
      <NtosWindow.Content scrollable>
        <Section>
          {chems ? (
            <div>
              {chems.length} {chems.length === 1 ? "Chemical" : "Chemicals"} Detected
              <ul>
                {chems.map(chem => (
                  <li key={chem}>
                    {chem}
                  </li>
                ))}
              </ul>
            </div>
          ) : (
            <ul>No Chemicals Found</ul>
          )}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
