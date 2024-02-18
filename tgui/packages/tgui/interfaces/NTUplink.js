import { GenericUplink } from './Uplink';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export const NTUplink = (props, context) => {
  const { data } = useBackend(context);
  const { telecrystals } = data;
  return (
    <Window
      width={620}
      height={580}
      theme="ntos"
      resizable>
      <Window.Content scrollable>
        <GenericUplink
          currencyAmount={telecrystals}
          currencySymbol="WC" />
      </Window.Content>
    </Window>
  );
};
