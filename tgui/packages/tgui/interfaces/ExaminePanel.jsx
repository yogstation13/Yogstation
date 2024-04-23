// THIS IS A NOVA SECTOR UI FILE -- borrowed by yogstation, the very best!
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { ByondUi, Section, Stack } from '../components';
import { Window } from '../layouts';

const formatURLs = (text) => {
  if (!text) return;
  const parts = [];
  let regex = /https?:\/\/[^\s/$.?#].[^\s]*/gi;
  let lastIndex = 0;

  text.replace(regex, (url, index) => {
    parts.push(text.substring(lastIndex, index));
    parts.push(
      <a
        style={{
          color: '#0591e3',
          'text-decoration': 'none',
        }}
        href={url}
      >
        {url}
      </a>,
    );
    lastIndex = index + url.length;
    return url;
  });

  parts.push(text.substring(lastIndex));

  return <div>{parts}</div>;
};

export const ExaminePanel = (props) => {
  const { act, data } = useBackend();
  const {
    character_name,
    obscured,
    assigned_map,
    flavor_text,
    ooc_notes,
    custom_species,
    custom_species_lore,
    headshot,
    ideal_antag_optin_status,
    current_antag_optin_status,
    opt_in_colors = { optin, color },
  } = data;
  return (
    <Window title="Examine Panel" width={900} height={670} theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item width="30%">
            {!headshot ? (
              <Section fill title="Character Preview">
                <ByondUi
                  height="100%"
                  width="100%"
                  className="ExaminePanel__map"
                  params={{
                    id: assigned_map,
                    type: 'map',
                  }}
                />
              </Section>
            ) : (
              <>
                <Section height="310px" title="Character Preview">
                  <ByondUi
                    height="260px"
                    width="100%"
                    className="ExaminePanel__map"
                    params={{
                      id: assigned_map,
                      type: 'map',
                    }}
                  />
                </Section>
                <Section height="310px" title="Headshot">
                  <img
                    src={resolveAsset(headshot)}
                    height="250px"
                    width="250px"
                  />
                </Section>
              </>
            )}
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <Section
                  scrollable
                  fill
                  title={character_name + "'s Flavor Text:"}
                  preserveWhitespace
                >
                  {formatURLs(flavor_text)}
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  <Stack.Item grow basis={0}>
                    <Section
                      scrollable
                      fill
                      title="OOC Notes"
                      preserveWhitespace
                    >
                      {ideal_antag_optin_status && (
                        <Stack.Item>
                          Current Antag Opt-In Status:{' '}
                          <span
                            style={{
                              fontWeight: 'bold',
                              color: opt_in_colors[current_antag_optin_status],
                            }}
                          >
                            {current_antag_optin_status}
                          </span>
                          {'\n'}
                          Antag Opt-In Status {'(Preferences)'}:{' '}
                          <span
                            style={{
                              color: opt_in_colors[ideal_antag_optin_status],
                            }}
                          >
                            {ideal_antag_optin_status}
                          </span>
                          {'\n\n'}
                        </Stack.Item>
                      )}
                      {formatURLs(ooc_notes)}
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <Section
                      scrollable
                      fill
                      title={
                        custom_species
                          ? 'Species: ' + custom_species
                          : 'No Custom Species!'
                      }
                      preserveWhitespace
                    >
                      {custom_species
                        ? formatURLs(custom_species_lore)
                        : 'Just a normal space dweller.'}
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
