import { useBackend } from '../backend';
import { LabeledList, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosBudgetMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    budgets,
  } = data;
  return (
    <NtosWindow
      width={400}
      height={480}
      resizable>
      <NtosWindow.Content>
        <Section title="Budgets">
          <LabeledList>
            {budgets.map((budget, index) =>
            (
              <LabeledList.Item label={budget["name"]} key={index}>
                {budget["money"] + "cr"}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
