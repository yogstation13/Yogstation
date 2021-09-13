import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const SkillMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    admin_mode,
    is_living,
    disable_skills,
    experience_mod,
    skills = [],
  } = data;
  return (
    <Window
      title="Skill Menu"
      width={700}
      height={600}
      resizable>
      <Window.Content scrollable>
        <Section title="Skills">
          <LabeledList>
            {skills.map(skill => (
              <LabeledList.Item
                key={skill.name}
                label={skill.name}
                buttons={(
                  <Fragment>
                    {!!is_living && (
                      <Button
                      content="Hi"
                      />
                    )}
                    {!!admin_mode && (
                      <Fragment>
                        <Button
                          content="Increase"
                          onClick={() => act('raise_skill', {
                            skill_id: skill.name,
                          })} />
                        <Button
                          content="Decrease"
                          onClick={() => act('lower_skill', {
                            skill_id: skill.name,
                          })} />
                      </Fragment>
                    )}
                  </Fragment>
                )}>
                {skill.desc}
                {' '}
                Key: ,{skill.level}
                {' '}
                {skill.experience}
                {' '}
                {language.level_desc}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        {!!admin_mode && (
          <Section
            title="Admin Tools"
            buttons={(
              <Button
                content={'Disable Skills '
                  + (disable_skills ? 'Enabled' : 'Disabled')}
                selected={disable_skills}
                onClick={() => act('toggle_omnitongue')} />
            )}>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
