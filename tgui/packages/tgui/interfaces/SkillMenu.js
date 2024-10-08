import { useBackend } from '../backend';
import { formatSiUnit } from '../format';
import { Box, Button, Icon, LabeledList, NumberInput, Section, Tabs, Tooltip } from '../components';
import { Window } from '../layouts';

export const SkillMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { skill_points, allocated_points } = data;

  return (
    <Window
      title="Skills"
      width={204}
      height={262}
      >
      <Window.Content>
        <Section title={"Points Available: " + (skill_points - allocated_points)}>
          <LabeledList>
            <AdjustSkill
              skill="physiology"
              name="Physiology"
              index={0}
              tooltip="Medical knowledge and surgical precision."
            />
            <AdjustSkill
              skill="mechanics"
              name="Mechanics"
              index={1}
              tooltip="Construction and repair of structures, machinery, and exosuits."
            />
            <AdjustSkill
              skill="technical"
              name="Technical"
              index={2}
              tooltip="Electrical work, robot maintenance, and piloting exosuits or ships."
            />
            <AdjustSkill
              skill="science"
              name="Science"
              index={3}
              tooltip="Knowledge of biology, chemistry, or other scientific fields."
            />
            <AdjustSkill
              skill="fitness"
              name="Fitness"
              index={4}
              tooltip="Physical prowess and accuracy with weapons."
            />
          </LabeledList>
          <Button
            fluid
            bold
            mt="8px"
            content=" Confirm"
            color="green"
            textAlign="center"
            fontSize="24px"
            lineHeight="30px"
            disabled={allocated_points === 0}
            onClick={() => act('confirm')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

const AdjustSkill = (props, context) => {
  const { act, data } = useBackend(context);
  const { skill, name, index, tooltip } = props;
  const { skills, skill_points, allocated_points, exceptional_skill } = data;
  const { base, allocated } = skills[index];

  return (
    <LabeledList.Item label={name}>
      <Tooltip content={tooltip}>
        <Icon name="question-circle" width="12px" mr="6px" />
      </Tooltip>
      <Button
        icon="minus"
        disabled={allocated <= 0 || allocated_points <= 0}
        onClick={() => act('allocate', {
          skill: skill,
          amount: -1,
        })}
      />
      {base + allocated} / {exceptional_skill ? 5 : 4}
      <Button
        ml="2px"
        icon="plus"
        disabled={(base + allocated) >= (exceptional_skill ? 5 : 4) || allocated_points >= skill_points}
        onClick={() => act('allocate', {
          skill: skill,
          amount: 1,
        })}
      />
    </LabeledList.Item>
  );
};
