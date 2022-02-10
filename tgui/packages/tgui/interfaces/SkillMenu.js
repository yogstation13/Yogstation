import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, LabeledList, ProgressBar, Icon, Input, Section, Tabs } from '../components';
import { COLORS } from '../constants';
import { Window } from '../layouts';

const skillLevelToColor = skillLevel => {
  if (skillLevel <= 1) {
    return COLORS.skills.unskilled;
  }
  if (skillLevel <= 2) {
    return COLORS.skills.basic;
  }
  if (skillLevel <= 3) {
    return COLORS.skills.trained;
  }
  if (skillLevel <= 4) {
    return COLORS.skills.experienced;
  }
  if (skillLevel <= 5) {
    return COLORS.skills.master;
  }
};

const skillLevelToText = skillLevel => {
  if (skillLevel === 1) {
    return "Unskilled";
  }
  if (skillLevel === 2) {
    return "Basic";
  }
  if (skillLevel === 3) {
    return "Trained";
  }
  if (skillLevel === 4) {
    return "Experienced";
  }
  if (skillLevel === 5) {
    return "Master";
  }
};

const difficultyLevelToColor = skillLevel => {
  if (skillLevel <= 1) {
    return "good";
  }
  if (skillLevel <= 2) {
    return "average";
  }
  if (skillLevel <= 3) {
    return "bad";
  }
};

const difficultyLevelToText = skillLevel => {
  if (skillLevel === 1) {
    return "Easy";
  }
  if (skillLevel === 2) {
    return "Medium";
  }
  if (skillLevel === 3) {
    return "Hard";
  }
};

export const SkillMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    admin_mode,
    is_living,
    disable_skills,
    experience_mod,
    skill_freeze,
    name,
    job,
    job_title,
    gender,
    species,
    age,
    current_name,
    current_id,
    current_icon,
    current_desc,
    current_level,
    current_experience,
    current_difficulty,
    current_level_desc,
  } = data;
  const skills = data.skills || [];
  const current_skill = data.current_skill || [];
  return (
    <Window
      title="Skill Menu"
      width={700}
      height={400}>
      <Window.Content>
        <Section
          title="Skills"
          buttons={(
            <Fragment >
              <Button.Checkbox
                content="Dont Use Skills"
                checked={disable_skills}
                onClick={() => act('toggle_use_skills')} />
              <Button.Checkbox
                content="Max Skills"
                checked={disable_skills} />
              <Button
                icon="list-ul"
                onClick={() => act('debug_variables_skillset')} />
              <Button
                icon="clone" />
              <Button
                icon="save" />
            </Fragment>
          )}>
          <Flex>
            <Flex.Item>
              <Section
                height="310px"
                width="180px"
                overflowY="auto">
                <Tabs vertical>
                  {skills.map(skill => (
                    <Tabs.Tab
                      key={skill.id}
                      icon={skill.icon}
                      color="security"
                      selected={skill.selected}
                      onClick={() => act('change_current_skill', {
                        id: skill.id })}>
                      {skill.name}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Section>
            </Flex.Item>
            <Flex.Item>
              <Section
                height="75px"
                width="500px">
                <Flex>
                  <Flex.Item>
                    <Fragment>
                      <Icon name="user-circle"
                        verticalAlign="middle" size="4.5" mr="1rem" mt=".5rem" ml={1} />
                    </Fragment>
                  </Flex.Item>
                  <Flex.Item>
                    <LabeledList>
                      <LabeledList.Item
                        label="Name">
                        {name}
                      </LabeledList.Item>
                      {(job_title === job ? (
                        (<LabeledList.Item
                          label="Job">

                          {job_title}

                        </LabeledList.Item>)
                      ):(
                        <LabeledList.Item
                          label="Job">

                          {job_title} ({job})

                        </LabeledList.Item>))}
                      <LabeledList.Item
                        label="Gender">
                        {gender[0].toUpperCase() + gender.substring(1)}
                      </LabeledList.Item>
                    </LabeledList>
                  </Flex.Item>
                  <Flex.Item>
                    <LabeledList>
                      <LabeledList.Item
                        label="Race">
                        {species}
                      </LabeledList.Item>
                      <LabeledList.Item
                        label="Age">
                        {age}
                      </LabeledList.Item>
                    </LabeledList>
                  </Flex.Item>
                </Flex>
              </Section>
              <Section
                title={current_name}
                height="230px"
                width="500px"
                overflowY="auto"
                buttons={!!admin_mode && (
                  <Fragment>
                    <Button
                      icon="level-up-alt"
                      onClick={() => act('increase_level')} />
                    <Button
                      icon="level-down-alt"
                      onClick={() => act('decrease_level')} />
                    <Button
                      icon="undo-alt"
                      onClick={() => act('decrease_level')} />
                    <Button
                      icon="list-ul"
                      onClick={() => act('debug_variables_skill')} />
                    <Button
                      icon="clone"
                      onClick={() => act('decrease_level')} />
                  </Fragment>)}>
                <LabeledList ml={5}>
                  <LabeledList.Item
                    label="Description"
                    ml={5}>
                    {current_desc}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label=" Difficulty"
                    color={difficultyLevelToColor(current_difficulty)}>
                    {difficultyLevelToText(current_difficulty)} ({current_difficulty})
                  </LabeledList.Item>
                  <LabeledList.Item
                    label=" Skill Level"
                    color={skillLevelToColor(current_level)}>
                    {skillLevelToText(current_level)} ({current_level})
                  </LabeledList.Item>
                  <LabeledList.Item
                    label=" Skill Level Description"
                    color={skillLevelToColor(current_level)}>
                    {current_level_desc}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

