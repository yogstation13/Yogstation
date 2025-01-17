import { useBackend } from "../backend";
import { Button, Flex, Section } from "../components";
import { Window } from "../layouts";

type Data = {
  dead_keyloop: boolean;
  ghost_zoom_tray: boolean;
  runechat: boolean;
  icon2html: boolean;
  observerjobs: boolean;
  slowmodesay: boolean;
  parallax: boolean;
  footsteps: boolean;
}

/* Credit to Xoxeyos who ported a port of the Ghost Pool Protection interface (PR #11139), which this follows the same design for the most part. */
export const LagSwitchPanel = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { dead_keyloop, ghost_zoom_tray, runechat, icon2html, observerjobs, slowmodesay, parallax, footsteps } = data;
  return (
    <Window title="Lag Switch Panel" width={400} height={270}>
      <Window.Content>
        <Flex>
          <Flex.Item grow={1}>
            <Section title="Options"
              buttons={
                <>
                  <Button
                    color="good"
                    icon="plus-circle"
                    content="Enable Everything"
                    onClick={() => act("enable_all")} />
                  <Button
                    color="bad"
                    icon="minus-circle"
                    content="Disable Everything"
                    onClick={() => act("disable_all")} />
                </>
              }>
              <Button
                fluid
                textAlign="center"
                color={dead_keyloop ? "good" : "bad"}
                icon="ghost"
                content="Disable ghost freelook (Staff exempted)"
                onClick={() => act("toggle_keyloop")} />
              <Button
                fluid
                textAlign="center"
                color={ghost_zoom_tray ? "good" : "bad"}
                icon="magnifying-glass"
                content="Disable ghost view/T-ray (Staff exempted)"
                onClick={() => act("toggle_zoomtray")} />
              <Button
                fluid
                textAlign="center"
                color={runechat ? "good" : "bad"}
                icon="comment"
                content="Disable runechat"
                onClick={() => act("toggle_runechat")} />
              <Button
                fluid
                textAlign="center"
                color={icon2html ? "good" : "bad"}
                icon="image"
                content="Disable icon2html"
                onClick={() => act("toggle_icon2html")} />
              <Button
                fluid
                textAlign="center"
                color={observerjobs ? "good" : "bad"}
                icon="hammer"
                content="Prevent new player joining"
                onClick={() => act("toggle_observerjobs")} />
              {/* Commented out since we don't have an implementation of this and I haven't figured out an alternative yet
              <Button
                fluid
                textAlign="center"
                color={slowmodesay ? "good" : "bad"}
                icon="stopwatch"
                content="Enable IC/dsay slowmode"
                onClick={() => act("toggle_slowmodesay")} />
              */}
              <Button
                fluid
                textAlign="center"
                color={parallax ? "good" : "bad"}
                icon="map"
                content="Disable parallax"
                onClick={() => act("toggle_parallax")} />
              <Button
                fluid
                textAlign="center"
                color={footsteps ? "good" : "bad"}
                icon="shoe-prints"
                content="Disable footsteps"
                onClick={() => act("toggle_footsteps")} />
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
