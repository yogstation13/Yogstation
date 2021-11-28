import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { CrewConsoleContent } from './CrewConsole';

export const NtosCrewMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <NtosWindow
      width={1000}
      height={800}
      resizable>
      <NtosWindow.Content scrollable>
        <CrewConsoleContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
