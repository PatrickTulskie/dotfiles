module.exports = {
  config: {
    // default font size in pixels for all tabs
    fontSize: 12,

    // font family with optional fallbacks
    fontFamily: 'Menlo, "DejaVu Sans Mono", "Lucida Console", monospace',

    // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
    cursorColor: 'rgba(248,28,229,0.75)',

    // `BEAM` for |, `UNDERLINE` for _, `BLOCK` for █
    cursorShape: 'BLOCK',

    // color of the text
    foregroundColor: '#F8F8F0',

    // terminal background color
    backgroundColor: '#181818',
    // backgroundColor: 'black',

    // border color (window, tabs)
    borderColor: '#272727',

    // custom css to embed in the main window
    css: `
      .hyperterm_main {
        border: none !important;
      }
      .header_header {
        background: #272727 !important;
      }
      .tab_tab {
        border: 0;
      }
      .tab_active span.tab_textActive {
        border-bottom: 2px solid #FD971F;
      }
    `,

    // custom css to embed in the terminal window
    termCSS: `
      ::selection {
        /* background-color: #ccc; */
        background-color: rgba(248,28,229,0.50);
      }
      [style*="background-color: rgb(248, 248, 240)"] {
        background-color: rgba(248, 28, 229, 0.50) !important;
      }
    `,

    // custom padding (css format, i.e.: `top right bottom left`)
    padding: '12px 14px',

    // the full list. if you're going to provide the full color palette,
    // including the 6 x 6 color cubes and the grayscale map, just provide
    // an array here instead of a color map object
    colors: {
      black: '#272727',
      red: '#F92672',
      green: '#A6E22E',
      yellow: '#FD971F',
      blue: '#66D9EF',
      magenta: '#AE81FF',
      cyan: '#38CCD1',
      white: '#ffffff',
      lightBlack: '#808080',
      lightRed: '#F92672',
      lightGreen: '#A6E22E',
      lightYellow: '#FD971F',
      lightBlue: '#66D9EF',
      lightMagenta: '#AE81FF',
      lightCyan: '#38CCD1',
      lightWhite: '#ffffff'
    },

    // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
    // if left empty, your system's login shell will be used by default
    shell: ''

    // for advanced config flags please refer to https://hyperterm.org/#cfg
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hyperpower`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: ['hyper-blink'],

  // in development, you can create a directory under
  // `~/.hyperterm_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: []
};
