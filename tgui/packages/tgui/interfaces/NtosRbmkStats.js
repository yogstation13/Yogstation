import { NtosWindow } from '../layouts';
import { RbmkStatsSection } from './RbmkComputer';

export const NtosRbmkStats = (props, context) => {
  return (
    <NtosWindow
      resizable
      width={440}
      height={650}>
      <NtosWindow.Content>
        <RbmkStatsSection />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
