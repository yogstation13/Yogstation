import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Button, ProgressBar, Section, Table } from '../components';
import { ReactorHistory, ReactorStats } from './ReactorComputer';

export const NtosReactorStats = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <NtosWindow
      resizable
      width={400}
      height={528}
      theme={data.theme}>
      <NtosWindow.Content>
        <NtosReactorMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosReactorMonitorContent = (props, context) => {
  const { act, data } = useBackend(context);
  if(!data.selected) {
    return (
      <ReactorList />
    );
  }
  return (
    <>
      <ReactorStats
        section_buttons={(
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => act('PRG_clear')} />
        )} />
      <ReactorHistory />
    </>
  );
};

const ReactorList = (props, context) => {
  const { act, data } = useBackend(context);
  const { reactors = [] } = data;
  return (
    <Section
      title="Detected Reactors"
      buttons={(
        <Button
          icon="sync"
          content="Refresh"
          onClick={() => act('PRG_refresh')} />
      )}>
      <Table>
        {reactors.map(reactor => (
          <Table.Row key={reactor.uid}>
            <Table.Cell>
              {reactor.uid + '. ' + reactor.area_name}
            </Table.Cell>
            <Table.Cell collapsing color="label">
              Integrity:
            </Table.Cell>
            <Table.Cell collapsing width="120px">
              <ProgressBar
                value={reactor.integrity / 100}
                ranges={{
                  good: [0.90, Infinity],
                  average: [0.5, 0.90],
                  bad: [-Infinity, 0.5],
                }} />
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                content="Details"
                onClick={() => act('PRG_set', {
                  target: reactor.uid,
                })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
