'use strict'

module.exports = {
  config: {
    updateChannel: 'stable',
    fontSize: 13,
    fontFamily: '"Source Han Code JP", monospace',
    uiFontFamily: '-apple-system, BlinkMacSystemFont',
    fontWeight: 'normal',
    fontWeightBold: 'bold',
    cursorColor: '#f18260',
    cursorAccentColor: '#000000',
    cursorShape: 'BLOCK',
    cursorBlink: true,
    foregroundColor: '#dddddd',
    backgroundColor: '',
    selectionColor: '#656565',
    borderColor: '',
    css: '',
    padding: '8px',
    colors: {
      black: '#232323',
      red: '#c42d29',
      green: '#b4d388',
      yellow: '#ffd949',
      blue: '#92bfbf',
      magenta: '#f18260',
      cyan: '#92bfbf',
      white: '#eeeeee',
      lightBlack: '#797979',
      lightRed: '#ff2606',
      lightGreen: '#cdefa5',
      lightYellow: '#ede480',
      lightBlue: '#b2eeef',
      lightMagenta: '#f49d62',
      lightCyan: '#b2eeef',
      lightWhite: '#ffffff',
    },
    shell: '/opt/homebrew/bin/fish',
    shellArgs: ['--login'],
    env: {},
    windowSize: [],
    scrollback: 1000,
    copyOnSelect: false,
    quickEdit: false,
    defaultSSHApp: true,
    modifierKeys: {},
    showHamburgerMenu: false,
    showWindowControls: '',
    summon: {
      hotkey: 'Option+Space',
    },
    hyperTransparent: {
      backgroundColor: '#232323',
      opacity: 0.8,
      vibrancy: '',
    },
  },
  plugins: [
    'hyperterm-summon',
    'hyperfull',
    'hyperminimal',
    'hyper-reorderable-tabs',
    'hyper-transparent',
  ],
}
