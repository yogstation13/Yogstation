import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const CompsciMissionSelect = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
      width={500}
      height={600}>
      <Window.Content>
        {!!data.ongoing && (
          <Section title="Join Ongoing Mission">
            <Button icon="search" onClick={() => act("join_ongoing")}>Join Ongoing Mission</Button>
          </Section>
        ) || (
          <Section title="Available Missions">
            {data.missions.map((mission, index) => {
              return (
                <Section buttons={(<Button icon="search" onClick={() => act("start_mission", { mission_id: mission.id })}>Explore</Button>)} title={mission.name} key={index}>
                  {mission.desc}
                </Section>
              );
            })}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
