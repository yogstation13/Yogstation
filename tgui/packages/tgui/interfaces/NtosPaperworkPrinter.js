import { useBackend } from '../backend';
import { Button, NoticeBox, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPaperworkPrinter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    have_printer,
    printable_papers,
  } = data;
  if (have_printer) {
    return (
      <NtosWindow
        width={400}
        height={480}
        resizable>
        <NtosWindow.Content scrollable>
          <Section title="NTOS Paperwork Printer">
            {printable_papers.map(paper => (
              <Button
                key={paper}
                icon="print"
                content={"Print " + paper.name}
                width="100%"
                onClick={() => act('PRG_print', {
                  paperworkID: paper.id,
                })} />
            ))}
          </Section>
        </NtosWindow.Content>
      </NtosWindow>
    );
  } else {
    return (
      <NtosWindow
        width={400}
        height={480}
        resizable>
        <NtosWindow.Content scrollable>
          <Section title="NTOS Paperwork Printer" />
          <NoticeBox>
            There is no printer installed. Program halted.
          </NoticeBox>
        </NtosWindow.Content>
      </NtosWindow>
    );
  }

};
