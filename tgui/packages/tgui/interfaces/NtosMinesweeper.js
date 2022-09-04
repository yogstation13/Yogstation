import { MinesweeperContent } from './Minesweeper.js';
import { NtosWindow } from '../layouts';

export const NtosMinesweeper = (props, context) => {
  return (
    <NtosWindow
      width={600}
      height={540}>
      <NtosWindow.Content>
        <MinesweeperContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
