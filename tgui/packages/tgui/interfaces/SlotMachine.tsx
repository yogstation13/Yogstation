import { useBackend } from '../backend';
import { Button, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

type IconInfo = {
  value: number;
  colour: string;
  icon_name: string;
};

type BackendData = {
  icons: IconInfo[];
  state: any[];
  balance: number;
  working: boolean;
  money: number;
  cost: number;
  plays: number;
  jackpots: number;
  jackpot: number;
  paymode: number;
};

type SlotsTileProps = {
  icon: string;
  color?: string;
  background?: string;
};

type SlotsReelProps = {
  reel: IconInfo[];
};

const pluralS = (amount: number) => {
  return amount === 1 ? '' : 's';
};

const SlotsReel = (props: SlotsReelProps) => {
  const { reel } = props;
  return (
    <div
      style={{
        display: 'inline-flex',
        'flex-direction': 'column',
      }}
    >
      {reel.map((slot, i) => (
        <SlotsTile key={i} icon={slot.icon_name} color={slot.colour} />
      ))}
    </div>
  );
};

const SlotsTile = (props: SlotsTileProps) => {
  return (
    <div
      style={{
        'text-align': 'center',
        padding: '1rem',
        margin: '0.5rem',
        display: 'inline-block',
        width: '5rem',
        background: props.background || 'rgba(62, 97, 137, 1)',
      }}
    >
      <Icon className={`color-${props.color}`} size={2.5} name={props.icon} />
    </div>
  );
};

export const SlotMachine = (props) => {
  const { act, data } = useBackend<BackendData>();
  // icons: The list of possible icons, including colour and name
  // backendState: the current state of the slots according to the backend
  const {
    plays,
    jackpots,
    money,
    cost,
    state,
    balance,
    jackpot,
    working: rolling,
    paymode,
  } = data;

  return (
    <Window width={400} height={540}>
      <Window.Content>
        <Section
          title="Slots!"
          style={{ 'justify-content': 'center', 'text-align': 'center' }}
        >
          <Section style={{ 'text-align': 'left' }}>
            <p>
              Only <b>{cost}</b> credit{pluralS(cost)} for a chance to win big!
            </p>
            <p>
              Available prize money:{' '}
              <b>
                {money} credit{pluralS(money)}
              </b>{' '}
            </p>
            {paymode === 1 && (
              <p>
                Current jackpot:{' '}
                <b>
                  {money + jackpot} credit{pluralS(money + jackpot)}!
                </b>
              </p>
            )}
            <p>
              So far people have spun{' '}
              <b>
                {plays} time{pluralS(plays)},
              </b>{' '}
              and won{' '}
              <b>
                {jackpots} jackpot{pluralS(jackpots)}!
              </b>
            </p>
          </Section>
          <hr />
          <Section
            style={{
              'flex-direction': 'row',
              display: 'flex',
              'justify-content': 'center',
            }}
          >
            {state.map((reel, i) => {
              return <SlotsReel key={i} reel={reel} />;
            })}
          </Section>
          <hr />
          <Section>
            <Stack vertical>
              <Stack.Item>
                <Button
                  onClick={() => act('spin')}
                  disabled={rolling || balance < cost}
                >
                  Spin!
                </Button>
              </Stack.Item>
              <Stack.Item>
                <b>Balance: {balance}</b>
              </Stack.Item>
              <Stack.Item>
                <Button onClick={() => act('payout')} disabled={!(balance > 0)}>
                  Refund balance
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
