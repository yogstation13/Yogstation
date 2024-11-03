import hljs from 'highlight.js/lib/core';
import { Box, Button, Modal, Section } from '../../components';
import { sanitizeText } from '../../sanitize';
import { LuaEditorModal } from './types';

type ChunkViewModalProps = {
  setModal: (modal: LuaEditorModal) => void;
  viewedChunk: string;
  setViewedChunk: (chunk: string | undefined) => void;
};

export const ChunkViewModal = (props: ChunkViewModalProps) => {
  const { setModal, viewedChunk, setViewedChunk } = props;

  return (
    <Modal position="absolute" width="50%" height="80%" top="10%" left="25%">
      <Section
        fill
        scrollable
        scrollableHorizontal
        title="Chunk"
        buttons={
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(undefined);
              setViewedChunk(undefined);
            }}
          >
            Close
          </Button>
        }
      >
        <Box
          as="pre"
          dangerouslySetInnerHTML={{
            __html: hljs.highlight(sanitizeText(viewedChunk), {
              language: 'lua',
            }).value,
          }}
        />
      </Section>
    </Modal>
  );
};
