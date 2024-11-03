import { useBackend } from '../../backend';
import { Button, Modal, Section } from '../../components';
import { ListMapper } from './ListMapper';
import { CallInfo, LuaEditorData, LuaEditorModal } from './types';

type CallModalProps = {
  setModal: (modal: LuaEditorModal) => void;
  toCall: CallInfo;
  setToCall: (toCall: CallInfo | undefined) => void;
};

export const CallModal = (props: CallModalProps) => {
  const { act, data } = useBackend<LuaEditorData>();
  const { callArguments } = data;
  const { setModal, toCall, setToCall } = props;
  const { type, params } = toCall || {};

  return (
    <Modal
      height={`${window.innerHeight * 0.8}px`}
      width={`${window.innerWidth * 0.5}px`}
    >
      <Section
        fill
        scrollable
        scrollableHorizontal
        title="Call Function/Task"
        buttons={
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(undefined);
              setToCall(undefined);
              act('clearArgs');
            }}
          >
            Cancel
          </Button>
        }
      >
        <ListMapper name="Arguments" list={callArguments} editable />
        <Button
          onClick={() => {
            setModal(undefined);
            setToCall(undefined);
            act(type, params);
          }}
        >
          Call
        </Button>
      </Section>
    </Modal>
  );
};

/*
export class CallModal extends Component<CallModalProps> {
  static defaultProps = {
    toCall: undefined,
    setToCall: () => {},
  };

  render() {
    const { act, data } = useBackend<LuaEditorData>();
    const { callArguments } = data;
    const { setModal, toCall, setToCall } = this.props;
    const { type, params } = toCall || {};

    return (
      <Modal
        height={`${window.innerHeight * 0.8}px`}
        width={`${window.innerWidth * 0.5}px`}
      >
        <Section
          fill
          scrollable
          scrollableHorizontal
          title="Call Function/Task"
          buttons={
            <Button
              color="red"
              icon="window-close"
              onClick={() => {
                setModal(undefined);
                setToCall(undefined);
                act('clearArgs');
              }}
            >
              Cancel
            </Button>
          }
        >
          <ListMapper name="Arguments" list={callArguments} editable />
          <Button
            onClick={() => {
              setModal(undefined);
              setToCall(undefined);
              act(type, params);
            }}
          >
            Call
          </Button>
        </Section>
      </Modal>
    );
  }
}
*/
