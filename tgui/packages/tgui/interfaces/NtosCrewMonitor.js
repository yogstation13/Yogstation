import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { CrewConsoleContent } from './CrewConsole';

export const NtosCrewMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <NtosWindow
      width={775}
      height={415}
      resizable>
      <NtosWindow.Content scrollable>
        <CrewConsoleContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
