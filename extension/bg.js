/*** data ***/

const HOST_NAME = 'io.github.tcode2k16.rofi.chrome';

let state = {
  port: null,
  lastTabId: [0, 0],
};

/*** utils ***/

function goToTab(id) {
  chrome.tabs.get(id, function (tabInfo) {
    chrome.windows.update(tabInfo.windowId, { focused: true }, function () {
      chrome.tabs.update(id, { active: true, highlighted: true });
    });
  });
}

function openUrlInNewTab(url) {
  chrome.tabs.create({ url });
}

function refreshHistory(callback) {
  chrome.history.search({
    text: '',
    startTime: 0,
    maxResults: 2147483647,
  }, function (results) {
    callback(results);
  });
}

/*** commands ***/

const CMDS = {
  switchTab() {
    chrome.tabs.query({}, function (tabs) {
      state.port.postMessage({
        'cmd': 'dmenu',
        'info': 'switchTab',
        'param': {
          'rofi-opts': ['-i', '-p', 'tab'],
          'opts': tabs.map(e => (e.id) + ': ' + e.title + ' ::: ' + e.url),
        }
      });
    });
  },

  openHistory() {
    refreshHistory(function (results) {
      state.port.postMessage({
        'cmd': 'dmenu',
        'info': 'openHistory',
        'param': {
          'rofi-opts': ['-matching', 'normal', '-i', '-p', 'history'],
          'opts': results.map(e => e.title + ' ::: ' + e.url),
        }
      });
    });
  },
  
  goLastTab() {
    goToTab(state.lastTabId[1]);
  },

  pageFunc() {
    chrome.tabs.query({ active: true, currentWindow: true }, async function (tabInfo) {
      if (tabInfo.length < 1) return;
      const pageOrigin = (new URL(tabInfo[0].url)).origin;

      refreshHistory(function (results) {
        state.port.postMessage({
          'cmd': 'dmenu',
          'info': 'changeToPage',
          'param': {
            'rofi-opts': ['-matching', 'normal', '-i', '-p', 'page'],
            'opts': results.filter(e => e.url.indexOf(pageOrigin) === 0).map(e => e.title + ' ::: ' + e.url),
          }
        });
      });
    });
  },
};

/*** listeners ***/

function onNativeMessage(message) {
  if (message.info === 'switchTab' && message.result !== '') {
    goToTab(parseInt(message.result.split(': ')[0]));
  } else if (message.info === 'openHistory' && message.result !== '') {
    let parts = message.result.split(' ::: ');

    openUrlInNewTab(parts[parts.length - 1]);
  } else if (message.info === 'changeToPage' && message.result !== '') {
    let parts = message.result.split(' ::: ');
    chrome.tabs.query({ active: true, currentWindow: true }, function (tabInfo) {
      chrome.tabs.update(tabInfo[0].id, {
        url: parts[parts.length - 1],
      });
    });
  } else if (message.result === '') {
    // do nothing
  } else {
    alert(JSON.stringify(message));
  }

  // console.log("Received message: " + JSON.stringify(message));
}

function onDisconnected() {
  alert("Failed to connect: " + chrome.runtime.lastError.message);
  state.port = null;
}

function addChromeListeners() {
  const listeners = {
    commands: {
      onCommand: function (command) {
        if (command in CMDS) {
          CMDS[command]();
        } else {
          alert('unknown command: ' + command)
        }
      }
    },
    tabs: {
      onActivated: function (activeInfo) {
        state.lastTabId[1] = state.lastTabId[0];
        state.lastTabId[0] = activeInfo.tabId;
      }
    }
  };

  for (let api in listeners) {
    for (let method in listeners[api]) {
      chrome[api][method].addListener(listeners[api][method]);
    }
  }
}

/*** main ***/

function main() {
  state.port = chrome.runtime.connectNative(HOST_NAME);
  state.port.onMessage.addListener(onNativeMessage);
  state.port.onDisconnect.addListener(onDisconnected);

  addChromeListeners();
};

main();