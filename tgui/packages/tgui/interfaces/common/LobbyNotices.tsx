import { Fragment } from 'inferno';
import { Box, NoticeBox } from '../../components';

export type LobbyNoticesType = (
  | string
  | { TGUI_SAFE?: string | string[]; CHATBOX_SAFE?: string }
)[];

export const LobbyNotices = (props: { notices?: LobbyNoticesType }) => {
  if (!props.notices || props.notices.length === 0) return null;
  const filteredLobbyNotices = props.notices.filter(
    (warning) =>
      typeof warning === 'string' ||
      (typeof warning === 'object' && warning.TGUI_SAFE),
  );

  if (filteredLobbyNotices.length === 0) return null;

  return (
    <>
      {filteredLobbyNotices.map((notice, index) => (
        <NoticeBox danger key={index}>
          {typeof notice === 'string' ? (
            <Box key={index + '_'}>{notice}</Box>
          ) : Array.isArray(notice.TGUI_SAFE) ? (
            notice.TGUI_SAFE.map((notice, index) => (
              <Box
                key={index + '__'}
                dangerouslySetInnerHTML={{ __html: notice }}
              />
            ))
          ) : (
            notice.TGUI_SAFE && (
              <Box
                key={index + '___'}
                dangerouslySetInnerHTML={{ __html: notice.TGUI_SAFE }}
              />
            )
          )}
        </NoticeBox>
      ))}
    </>
  );
};
