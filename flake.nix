# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
# This is an empty nixCats config.
# you may import this template directly into your nvim folder
# and then add plugins to categories here,
# and call the plugins with their default functions
# within your lua, rather than through the nvim package manager's method.
# Use the help, and the example config github:BirdeeHub/nixCats-nvim?dir=templates/example
# It allows for easy adoption of nix,
# while still providing all the extra nix features immediately.
# Configure in lua, check for a few categories, set a few settings,
# output packages with combinations of those categories and settings.
# All the same options you make here will be automatically exported in a form available
# in home manager and in nixosModules, as well as from other flakes.
# each section is tagged with its relevant help section.
{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };

    # see :help nixCats.flake.inputs
    # If you want your plugin to be loaded by the standard overlay,
    # i.e. if it wasnt on nixpkgs, but doesnt have an extra build step.
    # Then you should name it "plugins-something"
    # If you wish to define a custom build step not handled by nixpkgs,
    # then you should name it in a different format, and deal with that in the
    # overlay defined for custom builds in the overlays directory.
    # for specific tags, branches and commits, see:
    # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples
  };

  # see :help nixCats.flake.outputs
  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    # the following extra_pkg_config contains any values
    # which you want to pass to the config set of nixpkgs
    # import nixpkgs { config = extra_pkg_config; inherit system; }
    # will not apply to module imports
    # as that will have your system values
    extra_pkg_config = {
      # allowUnfree = true;
    };
    # management of the system variable is one of the harder parts of using flakes.

    # so I have done it here in an interesting way to keep it out of the way.
    # It gets resolved within the builder itself, and then passed to your
    # categoryDefinitions and packageDefinitions.

    # this allows you to use ${pkgs.system} whenever you want in those sections
    # without fear.

    # see :help nixCats.flake.outputs.overlays
    dependencyOverlays =
      /*
      (import ./overlays inputs) ++
      */
      [
        # This overlay grabs all the inputs named in the format
        # `plugins-<pluginName>`
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a set of our plugins.
        (utils.standardPluginOverlay inputs)
        # add any other flake overlays here.

        # when other people mess up their overlays by wrapping them with system,
        # you may instead call this function on their overlay.
        # it will check if it has the system in the set, and if so return the desired overlay
        # (utils.fixSystemizedOverlay inputs.codeium.overlays
        #   (system: inputs.codeium.overlays.${system}.default)
        # )
      ];

    # see :help nixCats.flake.outputs.categories
    # and
    # :help nixCats.flake.outputs.categoryDefinitions.scheme
    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkPlugin,
      ...
    } @ packageDef: {
      # to define and use a new category, simply add a new list to a set here,
      # and later, you will include categoryname = true; in the set you
      # provide when you build the package using this builder function.
      # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

      # lspsAndRuntimeDeps:
      # this section is for dependencies that should be available
      # at RUN TIME for plugins. Will be available to PATH within neovim terminal
      # this includes LSPs
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          universal-ctags
          ripgrep
          zls
          fd
          rust-analyzer
          cargo
          lua-language-server
          nodePackages_latest.bash-language-server
          pyright
          black
          mypy
          ruff
          nixd
          alejandra
          lldb_20
        ];
      };

      neonixdev = {
        # also you can do this.
        inherit (pkgs) nix-doc nil lua-language-server nixd;
        # nix-doc tags will make your tags much better in nix but only if you have nil as well for some reason
      };
      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [];
        general = {
          vimPlugins = {
            # you can make a subcategory
            tree-sitterALL = with pkgs.vimPlugins; [
              nvim-treesitter.withAllGrammars
            ];
            tree-sitterPlugins = with pkgs.vimPlugins; [
              nvim-treesitter-parsers.awk
              nvim-treesitter-parsers.bash
              nvim-treesitter-parsers.bibtex
              nvim-treesitter-parsers.css
              nvim-treesitter-parsers.csv
              nvim-treesitter-parsers.go
              nvim-treesitter-parsers.html
              nvim-treesitter-parsers.hyprlang
              nvim-treesitter-parsers.json
              nvim-treesitter-parsers.kdl
              nvim-treesitter-parsers.lua
              nvim-treesitter-parsers.markdown
              nvim-treesitter-parsers.nix
              nvim-treesitter-parsers.nu
              nvim-treesitter-parsers.powershell
              nvim-treesitter-parsers.python
              nvim-treesitter-parsers.rasi
              nvim-treesitter-parsers.regex
              nvim-treesitter-parsers.rust
              nvim-treesitter-parsers.scss
              nvim-treesitter-parsers.slint
              nvim-treesitter-parsers.ssh_config
              nvim-treesitter-parsers.toml
              nvim-treesitter-parsers.xml
              nvim-treesitter-parsers.yaml
              nvim-treesitter-parsers.yuck
              nvim-treesitter-parsers.zig
              nvim-treesitter-textobjects
            ];
            cmp = with pkgs.vimPlugins; [
              # cmp stuff
              nvim-cmp
              luasnip
              friendly-snippets
              cmp_luasnip
              cmp-buffer
              cmp-path
              cmp-nvim-lua
              cmp-nvim-lsp
              cmp-cmdline
              cmp-nvim-lsp-signature-help
              cmp-cmdline-history
              lspkind-nvim
              crates-nvim
              null-ls-nvim
            ];
            debugging = with pkgs.vimPlugins; [
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
              nvim-dap-python
            ];
            git = with pkgs.vimPlugins; [
              gitsigns-nvim
              vim-sleuth
              vim-fugitive
            ];
            ui = with pkgs.vimPlugins; [
              renamer-nvim
              alpha-nvim
              neo-tree-nvim
              fidget-nvim
              lualine-nvim
              nvim-notify
              nui-nvim
              noice-nvim
            ];
            beautify = with pkgs.vimPlugins; [
              nvim-autopairs
              nvim-highlight-colors
              rainbow-delimiters-nvim
              tokyonight-nvim
              catppuccin-nvim
              nvim-web-devicons
            ];
            otherlsp = with pkgs.vimPlugins; [
              nvim-nu
              nvim-lspconfig
              rustaceanvim
            ];
            core = with pkgs.vimPlugins; [
              telescope-fzf-native-nvim
              telescope-nvim
              undotree
              nvim-surround
              indent-blankline-nvim
              better-escape-nvim
              comment-nvim
              todo-comments-nvim
              zellij-nav-nvim
            ];
            general = with pkgs.vimPlugins; [
              plenary-nvim
              which-key-nvim
              oil-nvim
              twilight-nvim
            ];
          };
        };
        neonixdev = with pkgs.vimPlugins; [
          neodev-nvim
          neoconf-nvim
        ];
        markdown = with pkgs.vimPlugins; [
          markdown-preview-nvim
          markview-nvim
        ];
        texlive = with pkgs; [
          vimPlugins.vimtex
          texliveFull
        ];
      };

      # not loaded automatically at startup.
      # use with packadd and an autocommand in config to achieve lazy loading
      optionalPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [];
        general = with pkgs.vimPlugins; [];
      };

      # shared libraries to be added to LD_LIBRARY_PATH
      # variable available to nvim runtime
      sharedLibraries = {
        general = with pkgs; [
          # libgit2
        ];
      };

      # environmentVariables:
      # this section is for environmentVariables that should be available
      # at RUN TIME for plugins. Will be available to path within neovim terminal
      environmentVariables = {
        test = {
          CATTESTVAR = "It worked!";
        };
      };

      # If you know what these are, you can provide custom ones by category here.
      # If you dont, check this link out:
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      extraWrapperArgs = {
        test = [
          ''--set CATTESTVAR2 "It worked again!"''
        ];
      };

      # lists of the functions you would have passed to
      # python.withPackages or lua.withPackages
      # do not forget to set `hosts.python3.enable` in package settings

      # get the path to this python environment
      # in your lua config via
      # vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      python3.libraries = {
        test = _: [];
      };
      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {
        test = [(_: [])];
      };
    };

    # And then build a package with specific categories from above here:
    # All categories you wish to include must be marked true,
    # but false may be omitted.
    # This entire set is also passed to nixCats for querying within the lua.

    # see :help nixCats.flake.outputs.packageDefinitions
    packageDefinitions = {
      # These are the names of your packages
      # you can include as many as you wish.
      nvim = {
        pkgs,
        name,
        ...
      }: {
        # they contain a settings set defined above
        # see :help nixCats.flake.outputs.settings
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = true;
          # IMPORTANT:
          # your alias may not conflict with your other packages.
          aliases = ["v"];
          # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
        };
        # and a set of categories that you want
        # (and other information to pass to lua)
        categories = {
          general.vimPlugins = {
            tree-sitterPlugins = true;
            tree-sitterALL = false;
            debugging = true;
            git = true;
            ui = true;
            beautify = true;
            cmp = true;
            otherlsp = true;
            core = true;
            general = true;
          };
          markdown = true;
          # NOTE: true for vimtex
          texlive = false;
          startupPlugins = true;
          lspsAndRuntimeDeps = {
            general = true;
            neonixdev = true;
          };
        };
      };
    };
    # In this section, the main thing you will need to do is change the default package name
    # to the name of the packageDefinitions entry you wish to use as the default.
    defaultPackageName = "nvim";
  in
    # see :help nixCats.flake.outputs.exports
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
      # this is just for using utils such as pkgs.mkShell
      # The one used to build neovim is resolved inside the builder
      # and is passed to our categoryDefinitions and packageDefinitions
      pkgs = import nixpkgs {inherit system;};
    in {
      # these outputs will be wrapped with ${system} by utils.eachSystem

      # this will make a package out of each of the packageDefinitions defined above
      # and set the default package to the one passed in here.
      packages = utils.mkAllWithDefault defaultPackage;

      # choose your package for devShell
      # and add whatever else you want in it.
      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
          shellHook = ''
          '';
        };
      };
    })
    // (let
      # we also export a nixos module to allow reconfiguration from configuration.nix
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      # and the same for home manager
      homeModule = utils.mkHomeModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
    in {
      # these outputs will be NOT wrapped with ${system}

      # this will make an overlay out of each of the packageDefinitions defined above
      # and set the default overlay to the one named here.
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });
}
