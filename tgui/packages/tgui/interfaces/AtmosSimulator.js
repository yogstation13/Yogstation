import { useBackend } from '../backend';
import { formatSiUnit } from '../format';
import { Button, LabeledList, NumberInput, Section, Tabs } from '../components';
import { getGasColor, getGasLabel } from './common/AtmosControls';
import { Window } from '../layouts';

export const AtmosSimulator = (props, context) => {
  const { act, data } = useBackend(context);
  const { mode } = data;

  // Ideally we'd display a large window for it all...
  const idealWidth = 420, // nice
    idealHeight = 760;

  // ...but we should check for small screens, to play nicely with eg laptops.
  const winWidth = window.screen.availWidth;
  const winHeight = window.screen.availHeight;

  // Make sure we don't start larger than 50%/80% of screen width/height.
  const width = Math.min(idealWidth, winWidth * 0.5);
  const height = Math.min(idealHeight, winHeight * 0.8);

  return (
    <Window
      title="Atmospheric Simulator"
      width={width}
      height={height}
      >
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={mode === 1}
            onClick={() => act('set_mode', { mode: 1 })}>
            Bomb Simulator
          </Tabs.Tab>
          <Tabs.Tab
            selected={mode === 2}
            onClick={() => act('set_mode', { mode: 2 })}>
            Tank Reaction
          </Tabs.Tab>
        </Tabs>
        { mode === 1 && <BombSimulator /> }
        { mode === 2 && <TankReactor /> }
      </Window.Content>
    </Window>
  );
};

const BombSimulator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    bomb_1,
    bomb_2,

    bomb_1_pressure,
    bomb_1_moles,
    bomb_1_volume,
    bomb_1_temperature,
    bomb_1_gases,

    bomb_2_pressure,
    bomb_2_moles,
    bomb_2_volume,
    bomb_2_temperature,
    bomb_2_gases,

    bomb_result_pressure,
    bomb_result_moles,
    bomb_result_volume,
    bomb_result_temperature,
    bomb_result_gases,

    bomb_explosion_size,
    gas_data,
  } = data;
  return (
    <>
      <SimulatorTank
        title="Tank 1"
        volume={bomb_1_volume}
        pressure={bomb_1_pressure}
        temperature={bomb_1_temperature}
        total_moles={bomb_1_moles}
        gases={bomb_1_gases}
        tank={bomb_1}
        />
      <SimulatorTank
        title="Tank 2"
        volume={bomb_2_volume}
        pressure={bomb_2_pressure}
        temperature={bomb_2_temperature}
        total_moles={bomb_2_moles}
        gases={bomb_2_gases}
        tank={bomb_2}
        />
      <Section title='Results'>
        <LabeledList>
          <LabeledList.Item label='Explosion Size'>
            {bomb_explosion_size ? (bomb_explosion_size[0]+'/'+bomb_explosion_size[1]+'/'+bomb_explosion_size[2]) : 'None'}
          </LabeledList.Item>
          <LabeledList.Item label='Temperature'>
            {bomb_result_temperature} K
          </LabeledList.Item>
          <LabeledList.Item label='Pressure'>
            {formatSiUnit(bomb_result_pressure * 1000, 1, 'Pa')}
          </LabeledList.Item>
          {bomb_result_gases.map(gas => (
            <LabeledList.Item
              key={gas.id}
              label={getGasLabel(gas.id, gas_data)}
              labelColor={getGasColor(gas.id, gas_data)}
              color={getGasColor(gas.id, gas_data)}>
                {gas.moles} moles
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    </>
  );
};

const TankReactor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    tank_mix,

    tank_mix_pressure,
    tank_mix_moles,
    tank_mix_volume,
    tank_mix_temperature,
    tank_mix_gases,
  } = data;

  return (
    <SimulatorTank
      title='Reaction'
      volume={tank_mix_volume}
      pressure={tank_mix_pressure}
      temperature={tank_mix_temperature}
      total_moles={tank_mix_moles}
      gases={tank_mix_gases}
      tank={tank_mix}
      can_react
    />
  );
};

const SimulatorTank = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    title,
    volume,
    pressure,
    temperature,
    total_moles,
    gases: raw_gases,
    tank,
    can_react,
  } = props;

  const gas_data = data.gas_data;

  const gases = (raw_gases || []);

  return (
    <Section title={title}>
      <LabeledList>
        <LabeledList.Item label='Volume'>
          <NumberInput
            animated
            minValue={0}
            value={volume}
            unit="L"
            onChange={(e, value) => act('set_volume', {
              volume: value,
              tank: tank,
            })}
          />
        </LabeledList.Item>
        <LabeledList.Item label='Temperature'>
          <NumberInput
            animated
            minValue={0}
            value={temperature}
            unit="K"
            onChange={(e, value) => act('set_temperature', {
                temperature: value,
                tank: tank,
            })}
          />
        </LabeledList.Item>
        {gases.map(gas => (
          <LabeledList.Item
            key={gas.id}
            label={getGasLabel(gas.id, gas_data)}
            labelColor={getGasColor(gas.id, gas_data)}>
            <Button
              icon="minus"
              disabled={gas.moles<=0}
              onClick={() => act('set_moles', {
                gas: gas.id,
                moles: Math.max(gas.moles - 1, 0),
                tank: tank,
              })} />
            <NumberInput
              animated
              value={gas.moles}
              unit="mol"
              minValue={0}
              onChange={(e, value) => act('set_moles', {
                gas: gas.id,
                moles: value,
                tank: tank,
              })} />
            <Button
              icon="plus"
              onClick={() => act('set_moles', {
                gas: gas.id,
                moles: gas.moles + 1,
                tank: tank,
              })} />
            <Button
              icon="minus"
              disabled={gas.moles<=0}
              onClick={() => act('set_pressure', {
                gas: gas.id,
                pressure: Math.max(gas.pressure - 1, 0),
                tank: tank,
              })} />
            <NumberInput
              animated
              value={gas.pressure}
              unit="kPa"
              minValue={0}
              onChange={(e, value) => act('set_pressure', {
                gas: gas.id,
                pressure: value,
                tank: tank,
              })} />
            <Button
              icon="plus"
              onClick={() => act('set_pressure', {
                gas: gas.id,
                pressure: gas.pressure + 1,
                tank: tank,
              })} />
          </LabeledList.Item>
          ))}
        {total_moles ? (
          <LabeledList.Item label='Pressure'>
            {pressure} kPa
          </LabeledList.Item>
        ) : ''}
        <LabeledList.Item>
          <Button
            icon="plus"
            color="green"
            content="Add"
            onClick={() => act('add_gas', {
              tank: tank,
            })} />
            <Button
            ml={1}
            icon="cancel"
            color="blue"
            content="Clear"
            onClick={() => act('clear', {
              tank: tank,
            })} />
            {can_react ? (
              <Button
                ml={1}
                icon='undo'
                color='purple'
                content='React'
                onClick={() => act('react', {
                  tank: tank,
                })} />
            ) : ""}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
