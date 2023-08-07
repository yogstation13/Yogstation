import { NtosWindow } from '../layouts';
import { ReactorStatsSection } from './ReactorComputer';

export const NtosReactorStats = (props, context) => {
  return (
    <NtosWindow
      resizable
      width={440}
      height={650}>
      <NtosWindow.Content>
        <ReactorStatsSection />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
