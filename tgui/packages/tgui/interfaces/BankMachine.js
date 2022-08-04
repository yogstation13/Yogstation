import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Slider } from '../components';
import { Window } from '../layouts';

export const BankMachine = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    current_balance,
    siphoning,
    ui_siphon_request,
    siphon_percent,
    station_name,
  } = data;
  return (
    <Window
      width={335}
      height={200}>
      <Window.Content>
        <Section title={station_name + ' Vault'}>
          <LabeledList>
            <LabeledList.Item
              label="Balance"
              buttons={(
                <Button
                  icon={siphoning ? 'times' : 'sync'}
                  content={siphoning ? 'Stop Withdrawal' : 'Withdraw Credits'}
                  selected={siphoning}
                  onClick={() => act(siphoning ? 'halt' : 'siphon')} />
              )}>
              {current_balance + ' cr'}
            </LabeledList.Item>
          </LabeledList>
          <br></br>
          <Slider
            unit={siphoning ? '%' : 'cr'}
            ranges={{
              green: [-Infinity, current_balance/300],
              good: [current_balance/300, current_balance*2/300],
              average: [current_balance*2/300, Infinity],
            }}
            minValue={1}
            maxValue={siphoning ? 100 : Math.floor(current_balance/100)}
            value={siphoning ? siphon_percent : ui_siphon_request}
            step={siphoning ? 1 : current_balance/31100}
            format={value => Math.floor(value)}
            onDrag={(e, value) => act('siphon_amt', {amount: value})}
          />
        </Section>
        <NoticeBox textAlign="center">
          99% of credits are lost when withdrawing!
        </NoticeBox>
        <NoticeBox textAlign="center">
          Alarm will sound!
        </NoticeBox>
      </Window.Content>
    </Window>
  );
};
