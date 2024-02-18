/**
 * @file
 * @copyright 2023 Kaithyl (https://github.com/kaithyl)
 * @license MIT
 */

import { Fragment, Component } from 'inferno';
import { useBackend } from '../backend';
import { UI_INTERACTIVE } from '../constants';

export class Draggable extends Component {
  constructor(props) {
    super(props);
    this.state = {
      center: props.center ?? false,
      // eslint-disable-next-line react/no-unused-state
      dragging: false,
      dX: props.x ?? 0,
      dY: props.y ?? 0,
      pX: 0,
      pY: 0,
      z: props.z ?? 0,
    };
    this.trueZ = props.z ?? 0;
    this.debug = props.debug;
    this.dropShadow = props.dropShadow ?? {};

    // Necessary in ES6
    this.initRef = this.initRef.bind(this);
    this.startDrag = this.startDrag.bind(this);
    this.duringDrag = this.duringDrag.bind(this);
    this.stopDrag = this.stopDrag.bind(this);
  }

  initRef(ref) {
    this.self = ref;
    if (this.self) {
      let pos = this.self.getBoundingClientRect();
      this.setState({
        initX: 100*pos.left/window.innerWidth,
        initY: 100*pos.top/window.innerHeight,
      });
    }
  }

  startDrag(e) {
    const { config } = useBackend(this.context);
    // Ignore if user is not allowed to interact
    if (config.status < UI_INTERACTIVE) return;
    // Ignore if not left click
    if (e.button !== 0) return;
    this.setState({
      pX: e.clientX,
      pY: e.clientY,
      // eslint-disable-next-line react/no-unused-state
      dragging: true,
    });
    window.addEventListener("mousemove", this.duringDrag, false);
    window.addEventListener("mouseup", this.stopDrag, false);
    // if(this.props.startDrag && typeof this.props.startDrag === 'function') { this.props.startDrag(e, this); }
  }

  duringDrag(e) {
    const { config } = useBackend(this.context);
    // Ignore if user is not allowed to interact
    if (config.status < UI_INTERACTIVE) return;
    const { center, initX, initY } = this.state;
    let maxX, maxY, clientWidth, clientHeight = 0;
    if (this.self) {
      let bounds = this.self.getBoundingClientRect();
      maxX = 100*(1-bounds.width/window.outerWidth);
      maxY = 100*(1-bounds.height/window.outerHeight);
      clientWidth = this.self.clientWidth;
      clientHeight = this.self.clientHeight;
    }
    if (!center) {
      this.setState(prev => ({
        // Multiply by 100/window size to convert from px to vw/vh
        dX: clamp(initX + 100*(e.clientX - prev.pX)/window.outerWidth, 0, maxX),
        dY: clamp(initY + 100*(e.clientY - prev.pY)/window.outerHeight, 0, maxY),
      }));
    } else {
      this.setState({
        dX: clamp(100*(e.clientX - clientWidth/2)/window.outerWidth, 0, maxX),
        dY: clamp(100*(e.clientY - clientHeight/2)/window.outerHeight, 0, maxY),
      });
    }
    // if(this.props.duringDrag && typeof this.props.duringDrag === 'function') { this.props.duringDrag(e, this); }
  }

  // remove event listeners when the component is not being dragged
  stopDrag() {
    let left, top = 0;
    if (this.self) {
      left = this.self.getBoundingClientRect().left;
      top = this.self.getBoundingClientRect().top;
    }
    this.setState({
      initX: 100*left/window.outerWidth,
      initY: 100*top/window.outerHeight,
      // eslint-disable-next-line react/no-unused-state
      dragging: false,
    });
    window.removeEventListener("mousemove", this.duringDrag, false);
    window.removeEventListener("mouseup", this.stopDrag, false);
    // if(this.props.stopDrag && typeof this.props.stopDrag === 'function') { this.props.stopDrag(this); }
  }

  render() {
    const { dX, dY, z } = this.state;
    const style = {
      position: "absolute",
      transform: `translate(${dX}vw, ${dY}vh)`,
      border: this.debug ? "2px solid rgba(255, 0, 0, 1)" : "none",
      width: "fit-content",
      "max-width": "100%",
      display: "table",
      "z-index": z,
    };
    const debug = {
      position: "absolute",
      transform: `translate(${dX}vw, ${dY - 2.5}vh)`,
      color: "red",
    };
    let pos = null;
    if (this.debug && this.self) {
      pos = this.self.getBoundingClientRect();
    }
    return (
      <Fragment>
        { this.renderOuter && (this.renderOuter()) }
        <div style={style}
        // eslint-disable-next-line react/jsx-handler-names
        onMouseDown={this.startDrag} ref={this.initRef} >
          { this.renderChildren && (this.renderChildren()) }
          {/* this.props.children */}
        </div>
        {pos && <div style={debug}> x: {pos.left}, y: {pos.top}, z: {z} </div>}
      </Fragment>
    );
  }
}

const clamp = (val, min, max) => {
  return val > max ? max : val < min ? min : val;
};
