/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';
import './styles/themes/abductor.scss';
import './styles/themes/clockwork.scss';
import './styles/themes/cardtable.scss';
import './styles/themes/hackerman.scss';
import './styles/themes/malfunction.scss';
import './styles/themes/ntos.scss';
import './styles/themes/ntos_cat.scss';
import './styles/themes/ntos_darkmode.scss';
import './styles/themes/ntos_lightmode.scss';
import './styles/themes/ntOS95.scss';
import './styles/themes/ntos_synth.scss';
import './styles/themes/ntos_terminal.scss';
import './styles/themes/ntos_spooky.scss';
import './styles/themes/paper.scss';
import './styles/themes/retro.scss';
import './styles/themes/syndicate.scss';
import './styles/themes/admintickets.scss';

import { perf } from 'common/perf';
import { setupHotReloading } from 'tgui-dev-server/link/client';
import { setupHotKeys } from './hotkeys';
import { captureExternalLinks } from './links';
import { createRenderer } from './renderer';
import { configureStore, StoreProvider } from './store';
import { setupGlobalEvents } from './events';

perf.mark('inception', window.performance?.timing?.navigationStart);
perf.mark('init');

const store = configureStore();

const renderApp = createRenderer(() => {
  const { getRoutedComponent } = require('./routes');
  const Component = getRoutedComponent(store);
  return (
    <StoreProvider store={store}>
      <Component />
    </StoreProvider>
  );
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setupGlobalEvents();
  setupHotKeys();
  captureExternalLinks();

  // Subscribe for state updates
  store.subscribe(renderApp);

  // Dispatch incoming messages
  window.update = msg => store.dispatch(Byond.parseJson(msg));

  // Process the early update queue
  while (true) {
    const msg = window.__updateQueue__.shift();
    if (!msg) {
      break;
    }
    window.update(msg);
  }

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept([
      './components',
      './layouts',
      './routes',
    ], () => {
      renderApp();
    });
  }
};

setupApp();
